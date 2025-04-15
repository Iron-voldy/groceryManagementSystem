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
            <div class="cart-table">
                <table>
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Total</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody class="cart-items">
                        <c:forEach var="item" items="${cart.items}">
                            <tr class="cart-item" data-product-id="${item.productId}">
                                <td class="item-name">${item.productName}</td>
                                <td class="item-price">$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></td>
                                <td class="item-quantity">
                                    <div class="quantity-control">
                                        <button type="button" class="decrement" onclick="updateCartItemQuantity('${item.productId}', ${item.quantity - 1})">-</button>
                                        <input type="number" class="cart-quantity-input" value="${item.quantity}" min="1"
                                               data-product-id="${item.productId}"
                                               onchange="updateCartItemQuantity('${item.productId}', this.value)">
                                        <button type="button" class="increment" onclick="updateCartItemQuantity('${item.productId}', ${item.quantity + 1})">+</button>
                                    </div>
                                </td>
                                <td class="item-total">$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/></td>
                                <td class="item-actions">
                                    <button type="button" class="remove-from-cart btn btn-sm btn-danger"
                                            onclick="removeFromCart('${item.productId}')">Remove</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <div class="cart-summary">
                <div class="summary-item subtotal">
                    <span>Subtotal:</span>
                    <span class="cart-subtotal">$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-item">
                    <span>Shipping:</span>
                    <span>Calculated at checkout</span>
                </div>
                <div class="summary-item total">
                    <span>Total:</span>
                    <span class="cart-total">$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></span>
                </div>
                <div class="cart-actions">
                    <button type="button" class="btn btn-secondary clear-cart" onclick="clearCart()">Clear Cart</button>
                    <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary checkout-btn">Proceed to Checkout</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.cart-container {
    max-width: 1100px;
    margin: 0 auto;
    padding: 20px 0;
}

.cart-table {
    overflow-x: auto;
    margin-bottom: 30px;
}

.cart-table table {
    width: 100%;
    border-collapse: collapse;
}

.cart-table th, .cart-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #333;
}

.cart-table th {
    background-color: var(--dark-surface);
    color: var(--dark-text);
}

.item-name {
    font-weight: 600;
}

.item-price, .item-total {
    color: var(--secondary);
}

.quantity-control {
    display: flex;
    align-items: center;
    max-width: 120px;
}

.quantity-control button {
    width: 35px;
    height: 35px;
    background-color: var(--dark-surface);
    border: 1px solid #333;
    color: var(--dark-text);
    cursor: pointer;
}

.quantity-control input {
    width: 50px;
    height: 35px;
    text-align: center;
    border: 1px solid #333;
    border-left: none;
    border-right: none;
    background-color: var(--dark-surface);
    color: var(--dark-text);
}

.cart-summary {
    background-color: var(--dark-surface);
    padding: 20px;
    border-radius: var(--border-radius);
    margin-bottom: 30px;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
}

.summary-item.total {
    font-size: 20px;
    font-weight: 600;
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #333;
}

.cart-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 30px;
}

.empty-cart {
    text-align: center;
    padding: 50px 0;
}

.empty-cart p {
    margin-bottom: 20px;
    font-size: 18px;
}

/* Notification styles */
.notification {
    position: fixed;
    bottom: -100px;
    right: 20px;
    padding: 15px 25px;
    border-radius: var(--border-radius);
    color: white;
    font-weight: 500;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    z-index: 1000;
    opacity: 0;
    transition: all 0.3s ease;
}

.notification.show {
    bottom: 20px;
    opacity: 1;
}

.notification-success {
    background-color: var(--success);
}

.notification-error {
    background-color: var(--danger);
}

.notification-warning {
    background-color: var(--warning);
}

@media (max-width: 768px) {
    .cart-actions {
        flex-direction: column;
        gap: 15px;
    }

    .cart-actions button,
    .cart-actions a {
        width: 100%;
    }
}
</style>

<script>
// Set contextPath for JavaScript
const contextPath = '${pageContext.request.contextPath}';

// Function to update cart item quantity
function updateCartItemQuantity(productId, quantity) {
    // Convert to integer
    quantity = parseInt(quantity);

    // Validate quantity
    if (isNaN(quantity) || quantity < 0) {
        showNotification('Invalid quantity', 'error');
        return;
    }

    // If quantity is 0, confirm removal
    if (quantity === 0) {
        if (confirm('Remove this item from your cart?')) {
            removeFromCart(productId);
        } else {
            // Reset to 1 if user cancels
            document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`).value = 1;
        }
        return;
    }

    // Send update request
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
            showNotification('Cart updated');
            updateCartUI(data);

            // Update specific item's total
            const itemRow = document.querySelector(`.cart-item[data-product-id="${productId}"]`);
            if (itemRow) {
                const priceElement = itemRow.querySelector('.item-price');
                const totalElement = itemRow.querySelector('.item-total');

                if (priceElement && totalElement) {
                    // Extract price value
                    const price = parseFloat(priceElement.textContent.replace('$', ''));
                    // Calculate new total
                    const total = price * quantity;
                    // Update total display
                    totalElement.textContent = `$${total.toFixed(2)}`;
                }
            }
        } else {
            showNotification(data.message || 'Failed to update cart', 'error');

            // Revert to available quantity if specified
            if (data.availableQuantity) {
                document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`).value = data.availableQuantity;
                showNotification(`Only ${data.availableQuantity} items available`, 'warning');
            }
        }
    })
    .catch(error => {
        console.error('Error updating cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Function to remove item from cart
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
            // Remove the item row from UI
            const itemRow = document.querySelector(`.cart-item[data-product-id="${productId}"]`);
            if (itemRow) {
                itemRow.remove();
            }

            // Update cart UI with new totals
            updateCartUI(data);

            // Show empty cart message if cart is empty
            if (data.cartItemCount === 0) {
                const cartTable = document.querySelector('.cart-table');
                const cartSummary = document.querySelector('.cart-summary');
                const cartContainer = document.querySelector('.cart-container');

                if (cartTable) cartTable.remove();
                if (cartSummary) cartSummary.remove();

                const emptyCartDiv = document.createElement('div');
                emptyCartDiv.className = 'empty-cart';
                emptyCartDiv.innerHTML = `
                    <p>Your cart is empty</p>
                    <a href="${contextPath}/product/list" class="btn btn-primary">Continue Shopping</a>
                `;

                cartContainer.appendChild(emptyCartDiv);
            }

            showNotification('Item removed from cart');
        } else {
            showNotification(data.message || 'Failed to remove item from cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error removing from cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Function to clear entire cart
function clearCart() {
    if (!confirm('Are you sure you want to clear your cart?')) {
        return;
    }

    fetch(`${contextPath}/cart/clear`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Redirect to the cart page to show empty cart
            window.location.href = `${contextPath}/cart/view`;
        } else {
            showNotification(data.message || 'Failed to clear cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error clearing cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Function to update cart UI elements
function updateCartUI(data) {
    // Update subtotal and total displays
    if (data.cartTotal !== undefined) {
        const subtotalElements = document.querySelectorAll('.cart-subtotal');
        const totalElements = document.querySelectorAll('.cart-total');

        subtotalElements.forEach(el => {
            el.textContent = '$' + parseFloat(data.cartTotal).toFixed(2);
        });

        totalElements.forEach(el => {
            el.textContent = '$' + parseFloat(data.cartTotal).toFixed(2);
        });
    }

    // Update cart count in header
    updateCartCount(data.cartItemCount || 0);

    // Disable checkout button if cart is empty
    const checkoutBtn = document.querySelector('.checkout-btn');
    if (checkoutBtn && data.cartItemCount === 0) {
        checkoutBtn.setAttribute('disabled', 'disabled');
    }
}

// Function to update cart count in header
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

// Function to show notification
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 10);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}
</script>

<jsp:include page="/views/common/footer.jsp" />