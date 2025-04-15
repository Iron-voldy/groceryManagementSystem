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
                            <form action="${pageContext.request.contextPath}/cart/update" method="post" class="update-form">
                                <input type="hidden" name="productId" value="${item.productId}">
                                <button type="button" onclick="decrementQuantity(this.form)">-</button>
                                <input type="number" name="quantity" value="${item.quantity}" min="1" class="quantity-input">
                                <button type="button" onclick="incrementQuantity(this.form)">+</button>
                                <button type="submit" class="btn btn-sm">Update</button>
                            </form>
                        </div>
                        <div class="item-total">
                            $<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                        </div>
                        <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="remove-form">
                            <input type="hidden" name="productId" value="${item.productId}">
                            <button type="submit" class="btn btn-sm btn-danger">Remove</button>
                        </form>
                    </div>
                </c:forEach>
            </div>

            <div class="cart-summary">
                <h2>Cart Total: $<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></h2>
                <div class="cart-actions">
                    <form action="${pageContext.request.contextPath}/cart/clear" method="post" onsubmit="return confirm('Are you sure you want to clear your cart?')">
                        <button type="submit" class="btn btn-secondary">Clear Cart</button>
                    </form>
                    <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary">Proceed to Checkout</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.cart-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.cart-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 15px;
    margin-bottom: 15px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    flex-wrap: wrap;
}

.item-details {
    flex: 2;
    min-width: 200px;
}

.item-details h3 {
    margin-bottom: 5px;
    font-size: 18px;
}

.item-quantity {
    flex: 2;
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 150px;
}

.update-form {
    display: flex;
    align-items: center;
}

.quantity-input {
    width: 50px;
    text-align: center;
    padding: 5px;
    margin: 0 5px;
}

.item-total {
    flex: 1;
    font-weight: bold;
    font-size: 18px;
    text-align: right;
    min-width: 100px;
}

.remove-form {
    margin-left: 15px;
}

.cart-summary {
    background-color: var(--dark-surface);
    padding: 20px;
    border-radius: var(--border-radius);
    margin-top: 20px;
}

.cart-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 15px;
}

.empty-cart {
    text-align: center;
    padding: 40px 0;
}

@media (max-width: 768px) {
    .cart-item {
        flex-direction: column;
        text-align: center;
    }

    .item-details, .item-quantity, .item-total {
        width: 100%;
        margin: 10px 0;
    }

    .item-total {
        text-align: center;
    }

    .cart-actions {
        flex-direction: column;
        gap: 10px;
    }

    .cart-actions form, .cart-actions a {
        width: 100%;
    }
}
</style>

<script>
function decrementQuantity(form) {
    var input = form.querySelector('.quantity-input');
    var currentValue = parseInt(input.value);
    if (currentValue > 1) {
        input.value = currentValue - 1;
    }
}

function incrementQuantity(form) {
    var input = form.querySelector('.quantity-input');
    input.value = parseInt(input.value) + 1;
}
</script>

<jsp:include page="/views/common/footer.jsp" />