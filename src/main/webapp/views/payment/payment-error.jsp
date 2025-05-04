<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Payment Error" />
</jsp:include>

<div class="container payment-error">
    <div class="error-card">
        <div class="error-header">
            <h1>Payment Failed</h1>
            <p>We're sorry, but there was an issue processing your payment.</p>
        </div>

        <div class="error-details">
            <c:if test="${not empty error}">
                <div class="error-message">
                    <p>${error}</p>
                </div>
            </c:if>

            <div class="order-details">
                <h2>Order Details</h2>
                <div class="detail-row">
                    <span class="label">Order Number:</span>
                    <span class="value">${order.orderId.substring(0,8)}</span>
                </div>
                <div class="detail-row">
                    <span class="label">Total Amount:</span>
                    <span class="value">$${order.totalAmount}</span>
                </div>
            </div>
        </div>

        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/order/payment" class="btn btn-primary">
                Try Again
            </a>
            <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-secondary">
                Back to Cart
            </a>
        </div>
    </div>
</div>

<style>
.payment-error {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 70vh;
    padding: 20px;
}

.error-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    max-width: 500px;
    width: 100%;
    padding: 30px;
}

.error-header {
    text-align: center;
    margin-bottom: 30px;
    border-bottom: 1px solid var(--dark-surface-hover);
    padding-bottom: 20px;
}

.error-details {
    margin-bottom: 30px;
}

.error-message {
    background-color: rgba(244, 67, 54, 0.1);
    color: var(--danger);
    padding: 15px;
    border-radius: var(--border-radius);
    margin-bottom: 20px;
    text-align: center;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    padding: 10px 0;
    border-bottom: 1px solid var(--dark-surface-hover);
}

.detail-row .label {
    font-weight: bold;
    color: var(--light-text);
}

.error-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}
</style>

<jsp:include page="/views/common/footer.jsp" />