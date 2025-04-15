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
function updateQuantity(productId, change) {
    // If change is an input value, convert to integer
    const quantity = typeof change === 'number' ? change :
        (change > 0 ? parseInt(change) : 1);

    fetch('${pageContext.request.contextPath}/cart/update', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}&quantity=${quantity}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Reload the page to show updated cart
            location.reload();
        } else {
            alert(data.message || 'Failed to update cart');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred');
    });
}

function removeFromCart(productId) {
    fetch('${pageContext.request.contextPath}/cart/remove', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Reload the page to show updated cart
            location.reload();
        } else {
            alert(data.message || 'Failed to remove item');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred');
    });
}
</script>

<jsp:include page="/views/common/footer.jsp" />