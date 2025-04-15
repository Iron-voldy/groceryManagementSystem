<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Shopping Cart" />
    <jsp:param name="active" value="cart" />
</jsp:include>

<div class="cart-container">
    <h1>Your Shopping Cart</h1>

    <c:choose>
        <c:when test="${empty cart.items}">
            <div class="empty-cart">
                <p>Your cart is empty</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary">Continue Shopping</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="cart-items">
                <c:forEach var="item" items="${cart.items}">
                    <div class="cart-item">
                        <div class="item-details">
                            <h3>${item.productName}</h3>
                            <p>Price: $<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></p>
                        </div>
                        <div class="item-quantity">
                            <button onclick="updateQuantity('${item.productId}', -1)">-</button>
                            <input type="number" value="${item.quantity}" min="1"
                                   onchange="updateQuantity('${item.productId}', this.value)">
                            <button onclick="updateQuantity('${item.productId}', 1)">+</button>
                        </div>
                        <div class="item-total">
                            $<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                        </div>
                        <button onclick="removeFromCart('${item.productId}')">Remove</button>
                    </div>
                </c:forEach>
            </div>

            <div class="cart-summary">
                <h2>Cart Total: $<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></h2>
                <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary">Proceed to Checkout</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>

document.addEventListener('DOMContentLoaded', function() {
    initCartFunctionality();
});

function initCartFunctionality() {
    // Update quantity in cart
    const quantityInputs = document.querySelectorAll('.cart-quantity-input');
    if (quantityInputs.length > 0) {
        quantityInputs.forEach(input => {
            input.addEventListener('change', function() {
                const productId = this.getAttribute('data-product-id');
                const quantity = parseInt(this.value);
                updateCartItemQuantity(productId, quantity);
            });
        });
    }

    // Remove items from cart
    const removeButtons = document.querySelectorAll('.remove-from-cart');
    if (removeButtons.length > 0) {
        removeButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const productId = this.getAttribute('data-product-id');
                removeFromCart(productId);
            });
        });
    }

    // Clear cart button
    const clearCartButton = document.querySelector('.clear-cart');
    if (clearCartButton) {
        clearCartButton.addEventListener('click', function(e) {
            e.preventDefault();
            if (confirm('Are you sure you want to clear your cart?')) {
                clearCart();
            }
        });
    }
}

function updateCartItemQuantity(productId, quantity) {
    if (quantity < 0) {
        alert('Quantity cannot be negative');
        // Reset to 1 or previous value
        document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`).value = 1;
        return;
    }

    fetch(`${contextPath}/cart/update`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}&quantity=${quantity}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Update UI or reload page
            if (data.cartItemCount === 0) {
                // Cart is empty, refresh page or show empty cart message
                location.reload();
            } else {
                // Recalculate totals
                updateCartUI(data);
            }
        } else {
            // Handle error (e.g., not enough stock)
            alert(data.message);

            // Reset quantity to available stock or previous value
            const input = document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`);
            input.value = data.cartItemCount || 1;
        }
    })
    .catch(error => {
        console.error('Error updating cart:', error);
        alert('An error occurred. Please try again.');
    });
}

function removeFromCart(productId) {
    fetch(`${contextPath}/cart/remove`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Remove the item row
            const itemRow = document.querySelector(`.cart-item[data-product-id="${productId}"]`);
            if (itemRow) {
                itemRow.remove();
            }

            // Update cart UI
            updateCartUI(data);

            // If cart is empty, show empty cart message or reload
            if (data.cartItemCount === 0) {
                location.reload();
            }
        } else {
            alert(data.message || 'Failed to remove item from cart');
        }
    })
    .catch(error => {
        console.error('Error removing from cart:', error);
        alert('An error occurred. Please try again.');
    });
}

function clearCart() {
    fetch(`${contextPath}/cart/clear`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Reload the page to show empty cart
            location.reload();
        } else {
            alert(data.message || 'Failed to clear cart');
        }
    })
    .catch(error => {
        console.error('Error clearing cart:', error);
        alert('An error occurred. Please try again.');
    });
}

function updateCartUI(data) {
    // Update cart total
    if (data.cartTotal !== undefined) {
        const cartSubtotalElements = document.querySelectorAll('.cart-subtotal');
        const cartTotalElements = document.querySelectorAll('.cart-total');

        cartSubtotalElements.forEach(el => {
            el.textContent = formatCurrency(data.cartTotal);
        });

        cartTotalElements.forEach(el => {
            el.textContent = formatCurrency(data.cartTotal);
        });
    }

    // Update cart count in header
    updateCartCount(data.cartItemCount || 0);

    // Disable checkout button if cart is empty
    const checkoutBtn = document.querySelector('.checkout-btn');
    if (checkoutBtn) {
        checkoutBtn.disabled = data.cartItemCount === 0;
    }
}

function formatCurrency(amount) {
    return '$' + parseFloat(amount).toFixed(2);
}

function updateCartCount(count) {
    const cartCountElements = document.querySelectorAll('.cart-count');
    cartCountElements.forEach(element => {
        element.textContent = count;
        if (count > 0) {
            element.classList.add('has-items');
        } else {
            element.classList.remove('has-items');
        }
    });
}
</script>

<jsp:include page="/views/common/footer.jsp" />