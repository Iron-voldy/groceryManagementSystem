<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Shopping Cart" />
    <jsp:param name="active" value="cart" />
    <jsp:param name="scripts" value="cart" />
</jsp:include>

<div class="cart-page-container">
    <h1 class="page-title">Shopping Cart</h1>

    <c:choose>
        <c:when test="${empty cart || empty cart.items || cart.items.size() == 0}">
            <div class="empty-cart">
                <div class="empty-cart-icon">🛒</div>
                <h2>Your Cart is Empty</h2>
                <p>Looks like you haven't added any products to your cart yet.</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary">Continue Shopping</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="cart-container">
                <div class="cart-items-container">
                    <table class="cart-table">
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
                            <c:forEach var="item" items="${cart.items}" varStatus="status">
                                <c:set var="product" value="${cartProducts[status.index]}" />
                                <tr class="cart-item" data-product-id="${item.productId}">
                                    <td class="cart-product">
                                        <div class="cart-product-info">
                                            <div class="cart-product-image">
                                                <!-- Product image placeholder -->
                                                <div class="product-img-placeholder">
                                                    <c:choose>
                                                        <c:when test="${product.category == 'Fresh Products'}">🥩</c:when>
                                                        <c:when test="${product.category == 'Dairy'}">🥛</c:when>
                                                        <c:when test="${product.category == 'Vegetables'}">🥦</c:when>
                                                        <c:when test="${product.category == 'Fruits'}">🍎</c:when>
                                                        <c:when test="${product.category == 'Pantry Items'}">🥫</c:when>
                                                        <c:otherwise>🛒</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="cart-product-details">
                                                <h3 class="cart-product-name">${product.name}</h3>
                                                <div class="cart-product-category">${product.category}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="cart-price">
                                        <c:choose>
                                            <c:when test="${empty item.price}">$0.00</c:when>
                                            <c:otherwise>$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="cart-quantity">
                                        <div class="quantity-control">
                                            <button type="button" class="decrement" aria-label="Decrease quantity">-</button>
                                            <input type="number" class="quantity-input cart-quantity-input"
                                                   value="${item.quantity}" min="1" max="${product.stockQuantity}"
                                                   data-product-id="${item.productId}">
                                            <button type="button" class="increment" aria-label="Increase quantity">+</button>
                                        </div>
                                    </td>
                                    <td class="cart-item-total">
                                        <c:choose>
                                            <c:when test="${empty item.price}">
                                                $0.00
                                            </c:when>
                                            <c:otherwise>
                                                $<fmt:formatNumber value="${item.price.multiply(java.math.BigDecimal.valueOf(item.quantity))}" pattern="#,##0.00"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="cart-actions">
                                        <button class="btn btn-sm btn-danger remove-from-cart" data-product-id="${item.productId}">
                                            Remove
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="cart-summary">
                    <h2 class="summary-title">Order Summary</h2>

                    <div class="summary-item">
                        <span>Subtotal</span>
                        <span class="cart-subtotal">
                            <c:choose>
                                <c:when test="${empty cartTotal}">$0.00</c:when>
                                <c:otherwise>$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <div class="summary-item">
                        <span>Shipping</span>
                        <span>Calculated at checkout</span>
                    </div>

                    <div class="summary-item summary-total">
                        <span>Total</span>
                        <span class="cart-total">
                            <c:choose>
                                <c:when test="${empty cartTotal}">$0.00</c:when>
                                <c:otherwise>$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <div class="cart-actions">
                        <a href="${pageContext.request.contextPath}/cart/checkout" class="btn btn-primary checkout-btn">
                            Proceed to Checkout
                        </a>
                        <button class="btn btn-secondary clear-cart">Clear Cart</button>
                    </div>

                    <div class="continue-shopping">
                        <a href="${pageContext.request.contextPath}/product/list">Continue Shopping</a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.cart-page-container {
    padding: 20px 0;
}

.page-title {
    margin-bottom: 30px;
    color: var(--dark-text);
}

.empty-cart {
    text-align: center;
    padding: 60px 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.empty-cart-icon {
    font-size: 5rem;
    margin-bottom: 20px;
    color: var(--light-text);
}

.empty-cart h2 {
    margin-bottom: 15px;
    color: var(--dark-text);
}

.empty-cart p {
    margin-bottom: 30px;
    color: var(--light-text);
}

.cart-container {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.cart-items-container {
    flex: 2;
    min-width: 300px;
}

.cart-table {
    width: 100%;
    border-collapse: collapse;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--card-shadow);
}

.cart-table th, .cart-table td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #333;
}

.cart-table th {
    background-color: var(--darker-bg);
    color: var(--dark-text);
    font-weight: 600;
}

.cart-product-info {
    display: flex;
    align-items: center;
}

.cart-product-image {
    width: 60px;
    height: 60px;
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 15px;
}

.product-img-placeholder {
    font-size: 1.5rem;
}

.cart-product-name {
    margin-bottom: 5px;
    font-size: 16px;
    color: var(--dark-text);
}

.cart-product-category {
    font-size: 12px;
    color: var(--light-text);
}

.cart-price, .cart-item-total {
    font-weight: 600;
    color: var(--secondary);
}

.quantity-control {
    display: flex;
    width: 100px;
}

.quantity-control button {
    width: 30px;
    height: 34px;
    background-color: var(--dark-surface-hover);
    border: none;
    color: var(--dark-text);
    font-size: 16px;
    cursor: pointer;
}

.quantity-input {
    width: 40px;
    height: 34px;
    text-align: center;
    border: none;
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
}

.cart-summary {
    flex: 1;
    min-width: 250px;
    height: fit-content;
    padding: 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.summary-title {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    color: var(--light-text);
}

.summary-total {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #333;
    font-weight: 600;
    font-size: 18px;
    color: var(--dark-text);
}

.cart-actions {
    margin-top: 30px;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.continue-shopping {
    margin-top: 20px;
    text-align: center;
}

.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: var(--border-radius);
    background-color: var(--success);
    color: white;
    max-width: 300px;
    z-index: 1000;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.3);
    transform: translateX(110%);
    transition: transform 0.3s ease;
}

.notification.show {
    transform: translateX(0);
}

.notification-error {
    background-color: var(--danger);
}

.notification-warning {
    background-color: var(--warning);
}

@media (max-width: 768px) {
    .cart-table {
        display: block;
        overflow-x: auto;
    }

    .quantity-control {
        width: 90px;
    }

    .cart-actions {
        flex-direction: column;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />