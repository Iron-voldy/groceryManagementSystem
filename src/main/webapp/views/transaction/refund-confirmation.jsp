<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Refund Confirmation" />
    <jsp:param name="active" value="transactions" />
</jsp:include>

<div class="refund-confirmation-container">
    <div class="confirmation-header">
        <h1 class="page-title">Refund Processed Successfully</h1>
        <p class="confirmation-message">The transaction has been refunded.</p>
    </div>

    <div class="refund-details">
        <div class="detail-card">
            <h2>Refund Information</h2>
            <div class="detail-section">
                <div class="detail-item">
                    <strong>Transaction ID:</strong>
                    ${transaction.transactionId}
                </div>
                <div class="detail-item">
                    <strong>Original Amount:</strong>
                    $<fmt:formatNumber value="${transaction.amount}" pattern="#,##0.00"/>
                </div>
                <div class="detail-item">
                    <strong>Refund Date:</strong>
                    <fmt:formatDate value="${refundTransaction.transactionDate}" pattern="MMMM d, yyyy 'at' h:mm a"/>
                </div>
                <div class="detail-item">
                    <strong>Refund Method:</strong>
                    ${refundTransaction.paymentMethod.replace('_', ' ')}
                </div>
                <div class="detail-item">
                    <strong>Refund Reason:</strong>
                    ${refundReason}
                </div>
            </div>
        </div>

        <div class="order-details">
            <div class="detail-card">
                <h2>Order Details</h2>
                <div class="detail-section">
                    <div class="detail-item">
                        <strong>Order ID:</strong>
                        ${order.orderId}
                    </div>
                    <div class="detail-item">
                        <strong>Order Date:</strong>
                        <fmt:formatDate value="${order.orderDate}" pattern="MMMM d, yyyy 'at' h:mm a"/>
                    </div>
                    <div class="detail-item">
                        <strong>Order Status:</strong>
                        <span class="status-badge status-${order.status.toLowerCase()}">
                            ${order.status}
                        </span>
                    </div>
                    <div class="detail-item">
                        <strong>Total Order Amount:</strong>
                        $<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="confirmation-actions">
        <a href="${pageContext.request.contextPath}/transaction/list" class="btn btn-primary">
            Back to Transactions
        </a>
        <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-secondary">
            View Order Details
        </a>
        <button onclick="window.print()" class="btn btn-secondary">
            Print Refund Receipt
        </button>
    </div>
</div>

<style>
.refund-confirmation-container {
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

.refund-details {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    justify-content: center;
    margin-bottom: 30px;
}

.detail-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    width: 100%;
    max-width: 500px;
    box-shadow: var(--card-shadow);
}

.detail-card h2 {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
}

.detail-section {
    display: flex;
    flex-direction: column;
}

.detail-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: var(--light-text);
    padding: 10px 0;
    border-bottom: 1px solid #333;
}

.detail-item:last-child {
    border-bottom: none;
}

.detail-item strong {
    color: var(--dark-text);
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.confirmation-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}

@media print {
    .confirmation-actions,
    header,
    footer {
        display: none;
    }
}

@media (max-width: 768px) {
    .refund-details {
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

<jsp:include page="/views/common/admin-footer.jsp" />