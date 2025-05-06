<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.Date" %>

<%!
    // Helper method to convert LocalDateTime to Date
    private static Date convertToDate(LocalDateTime localDateTime) {
        return localDateTime == null ? null :
            Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
    }
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Track Order" />
</jsp:include>

<div class="container track-order">
    <div class="track-order-card">
        <div class="order-header">
            <h1>Track Your Order</h1>
            <div class="order-meta">
                <span class="order-number">Order #${fn:substring(order.orderId, 0, 8)}</span>
                <span class="order-date">
                    <%
                        LocalDateTime orderDate = ((com.grocerymanagement.model.Order)request.getAttribute("order")).getOrderDate();
                        Date convertedDate = convertToDate(orderDate);
                    %>
                    <fmt:formatDate value="<%= convertedDate %>" pattern="MMM dd, yyyy HH:mm"/>
                </span>
            </div>
        </div>

        <div class="tracking-info">
            <div class="tracking-steps">
                <div class="tracking-step ${order.status == 'PENDING' || order.status == 'PROCESSING' ||
                                            order.status == 'SHIPPED' || order.status == 'DELIVERED' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-shopping-cart"></i>
                    </div>
                    <div class="step-content">
                        <h3>Order Placed</h3>
                        <p>Your order has been placed successfully</p>
                    </div>
                </div>

                <div class="tracking-step ${order.status == 'PROCESSING' ||
                                            order.status == 'SHIPPED' || order.status == 'DELIVERED' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-box"></i>
                    </div>
                    <div class="step-content">
                        <h3>Processing</h3>
                        <p>Your order is being prepared</p>
                    </div>
                </div>

                <div class="tracking-step ${order.status == 'SHIPPED' || order.status == 'DELIVERED' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-truck"></i>
                    </div>
                    <div class="step-content">
                        <h3>Shipped</h3>
                        <p>Your order is on the way</p>
                    </div>
                </div>

                <div class="tracking-step ${order.status == 'DELIVERED' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-home"></i>
                    </div>
                    <div class="step-content">
                        <h3>Delivered</h3>
                        <p>Your order has been delivered</p>
                    </div>
                </div>

                <c:if test="${order.status == 'CANCELLED'}">
                    <div class="tracking-step cancelled">
                        <div class="step-icon">
                            <i class="fas fa-times-circle"></i>
                        </div>
                        <div class="step-content">
                            <h3>Cancelled</h3>
                            <p>Your order has been cancelled</p>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

        <div class="order-details">
            <h2>Order Details</h2>

            <div class="order-items">
                <c:forEach var="item" items="${order.items}">
                    <div class="order-item">
                        <div class="item-details">
                            <h3>${item.productName}</h3>
                            <p>Quantity: ${item.quantity}</p>
                        </div>
                        <div class="item-price">
                            $<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="order-summary">
                <div class="summary-row">
                    <span>Subtotal</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row">
                    <span>Shipping</span>
                    <span>$<fmt:formatNumber value="5.00" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row">
                    <span>Tax</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount * 0.1}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row total">
                    <span>Total</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount * 1.1 + 5.00}" pattern="#,##0.00"/></span>
                </div>
            </div>
        </div>

        <div class="order-actions">
            <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-secondary">
                View Order Details
            </a>
            <c:if test="${order.status == 'PENDING'}">
                <form action="${pageContext.request.contextPath}/order/cancel" method="post">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <button type="submit" class="btn btn-danger">Cancel Order</button>
                </form>
            </c:if>
        </div>
    </div>
</div>

<style>
.track-order {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.track-order-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 30px;
    box-shadow: var(--card-shadow);
}

.order-header {
    margin-bottom: 30px;
    border-bottom: 1px solid var(--dark-surface-hover);
    padding-bottom: 15px;
}

.order-meta {
    display: flex;
    justify-content: space-between;
    margin-top: 10px;
}

.tracking-info {
    margin-bottom: 30px;
}

.tracking-steps {
    display: flex;
    flex-direction: column;
    gap: 30px;
    position: relative;
}

.tracking-steps::before {
    content: '';
    position: absolute;
    top: 20px;
    bottom: 0;
    left: 25px;
    width: 2px;
    background-color: var(--dark-surface-hover);
    z-index: 1;
}

.tracking-step {
    display: flex;
    align-items: flex-start;
    position: relative;
    z-index: 2;
}

.step-icon {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background-color: var(--dark-surface-hover);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    margin-right: 20px;
    color: var(--light-text);
    transition: var(--transition);
}

.step-content {
    flex: 1;
}

.step-content h3 {
    margin-bottom: 5px;
    color: var(--light-text);
    transition: var(--transition);
}

.step-content p {
    color: var(--light-text);
    font-size: 0.9em;
}

.tracking-step.completed .step-icon {
    background-color: var(--primary-color);
    color: white;
}

.tracking-step.completed .step-content h3 {
    color: var(--dark-text);
}

.tracking-step.cancelled .step-icon {
    background-color: var(--danger);
    color: white;
}

.tracking-step.cancelled .step-content h3 {
    color: var(--danger);
}

.order-details {
    margin-top: 40px;
    border-top: 1px solid var(--dark-surface-hover);
    padding-top: 20px;
}

.order-details h2 {
    margin-bottom: 20px;
}

.order-items {
    margin-bottom: 30px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    padding: 15px 0;
    border-bottom: 1px solid var(--dark-surface-hover);
}

.order-item:last-child {
    border-bottom: none;
}

.order-summary {
    background-color: var(--dark-surface-hover);
    padding: 20px;
    border-radius: var(--border-radius);
    margin-bottom: 30px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
}

.summary-row.total {
    margin-top: 15px;
    padding-top: 15px;
    border-top: 1px solid #444;
    font-weight: bold;
    font-size: 1.1em;
}

.order-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 30px;
}

.btn {
    display: inline-block;
    padding: 10px 20px;
    border-radius: var(--border-radius);
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition);
    border: none;
    font-size: 1em;
}

.btn-secondary {
    background-color: var(--secondary);
    color: white;
}

.btn-danger {
    background-color: var(--danger);
    color: white;
}

@media (max-width: 768px) {
    .order-actions {
        flex-direction: column;
        gap: 10px;
    }

    .order-actions .btn,
    .order-actions form {
        width: 100%;
    }

    .order-actions form button {
        width: 100%;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />