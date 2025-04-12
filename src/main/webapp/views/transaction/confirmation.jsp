<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Payment Confirmation" />
    <jsp:param name="active" value="cart" />
</jsp:include>

<div class="transaction-confirmation-container">
    <div class="confirmation-header">
        <h1 class="page-title">Payment Successful</h1>
        <p class="confirmation-message">Thank you for your purchase!</p>
    </div>

    <div class="confirmation-content">
        <div class="transaction-summary">
            <div class="summary-card">
                <h2>Transaction Details</h2>
                <div class="detail-item">
                    <strong>Transaction ID:</strong>
                    ${transaction.transactionId}
                </div>
                <div class="detail-item">
                    <strong>Amount Paid:</strong>
                    $<fmt:formatNumber value="${transaction.amount}" pattern="#,##0.00"/>
                </div>
                <div class="detail-item">
                    <strong>Payment Method:</strong>
                    ${transaction.paymentMethod.replace('_', ' ')}
                </div>
                <div class="detail-item">
                    <strong>Date:</strong>
                    <fmt:formatDate value="${transaction.transactionDate}" pattern="MMMM d, yyyy 'at' h:mm a"/>
                </div>
            </div>
        </div>

        <div class="order-summary">
            <div class="summary-card">
                <h2>Order Summary</h2>
                <div class="order-items">
                    <c:forEach var="item" items="${order.items}">
                        <div class="order-item">
                            <div class="item-details">
                                <strong>${item.productName}</strong>
                                <span>
                                    $<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>
                                    x ${item.quantity}
                                </span>
                            </div>
                            <div class="item-total">
                                $<fmt:formatNumber value="${item.price.multiply(java.math.BigDecimal.valueOf(item.quantity))}" pattern="#,##0.00"/>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="order-totals">
                    <div class="total-item">
                        <span>Subtotal</span>
                        <span>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></span>
                    </div>
                    <div class="total-item">
                        <span>Tax</span>
                        <span>$<fmt:formatNumber value="${taxAmount}" pattern="#,##0.00"/></span>
                    </div>
                    <div class="total-item total-final">
                        <strong>Total</strong>
                        <strong>$<fmt:formatNumber value="${order.totalAmount.add(taxAmount)}" pattern="#,##0.00"/></strong>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="confirmation-actions">
        <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-primary">
            View Order Details
        </a>
        <a href="${pageContext.request.contextPath}/product/list" class="btn btn-secondary">
            Continue Shopping
        </a>
    </div>

    <div class="print-section">
        <button onclick="window.print()" class="btn btn-secondary">
            Print Receipt
        </button>
    </div>
</div>

<style>
.transaction-confirmation-container {
    padding: 20px 0;
    text-align: center;
}

.confirmation-header {
    margin-bottom: 30px;
}

.page-title {
    color: var(--primary);
    margin-bottom: 10px;
}

.confirmation-message {
    color: var(--light-text);
    font-size: 18px;
}

.confirmation-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    justify-content: center;
    margin-bottom: 30px;
}

.summary-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    width: 100%;
    max-width: 500px;
    box-shadow: var(--card-shadow);
}

.summary-card h2 {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
}

.detail-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: var(--light-text);
}

.order-items {
    margin-bottom: 20px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid #333;
}

.order-item:last-child {
    border-bottom: none;
}

.item-details {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.item-total {
    font-weight: 600;
    color: var(--secondary);
}

.order-totals {
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    padding: 15px;
}

.total-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: var(--light-text);
}

.total-final {
    margin-top: 15px;
    padding-top: 10px;
    border-top: 1px solid #333;
    font-size: 18px;
    color: var(--dark-text);
}

.confirmation-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-bottom: 30px;
}

.print-section {
    text-align: center;
}

@media print {
    .confirmation-actions,
    .print-section,
    header,
    footer {
        display: none;
    }
}

@media (max-width: 768px) {
    .confirmation-content {
        flex-direction: column;
    }

    .confirmation-actions {
        flex-direction: column;
    }

    .confirmation-actions .btn {
        width: 100%;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />