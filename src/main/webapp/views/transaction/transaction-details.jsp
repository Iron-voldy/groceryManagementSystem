<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Transaction Details" />
    <jsp:param name="active" value="transactions" />
</jsp:include>

<div class="transaction-details-container">
    <div class="transaction-header">
        <h1 class="page-title">Transaction Details</h1>
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/index.jsp">Home</a> &gt;
            <c:choose>
                <c:when test="${sessionScope.user.role == 'ADMIN'}">
                    <a href="${pageContext.request.contextPath}/transaction/list">Transactions</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/user/profile">My Profile</a>
                </c:otherwise>
            </c:choose>
            &gt; <span>Transaction ${transaction.transactionId}</span>
        </div>
    </div>

    <div class="transaction-content">
        <div class="transaction-main-details">
            <div class="transaction-card">
                <div class="transaction-summary">
                    <div class="transaction-id">
                        <strong>Transaction ID:</strong> ${transaction.transactionId}
                    </div>
                    <div class="transaction-status">
                        <span class="status-badge status-${transaction.status.toLowerCase()}">
                            ${transaction.status}
                        </span>
                    </div>
                </div>

                <div class="transaction-details">
                    <div class="detail-section">
                        <h3>Payment Information</h3>
                        <div class="detail-item">
                            <strong>Payment Method:</strong>
                            <span class="payment-method">
                                ${transaction.paymentMethod.replace('_', ' ')}
                            </span>
                        </div>
                        <div class="detail-item">
                            <strong>Amount:</strong>
                            $<fmt:formatNumber value="${transaction.amount}" pattern="#,##0.00"/>
                        </div>
                        <div class="detail-item">
                            <strong>Date:</strong>
                            <fmt:formatDate value="${transaction.transactionDate}" pattern="MMMM d, yyyy 'at' h:mm a"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="transaction-order-details">
            <c:if test="${not empty order}">
                <div class="order-card">
                    <h3>Related Order Details</h3>
                    <div class="order-summary">
                        <div class="detail-item">
                            <strong>Order ID:</strong> ${order.orderId}
                        </div>
                        <div class="detail-item">
                            <strong>Status:</strong>
                            <span class="status-badge status-${order.status.toLowerCase()}">
                                ${order.status}
                            </span>
                        </div>
                        <div class="detail-item">
                            <strong>Total Items:</strong> ${order.getTotalItemCount()}
                        </div>
                        <div class="detail-item">
                            <strong>Total Amount:</strong>
                            $<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                        </div>
                        <div class="detail-actions">
                            <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}"
                               class="btn btn-sm">View Order Details</a>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${transaction.status == 'REFUNDED'}">
                <div class="refund-details">
                    <h3>Refund Information</h3>
                    <div class="detail-section">
                        <div class="detail-item">
                            <strong>Refund Date:</strong>
                            <fmt:formatDate value="${transaction.transactionDate}" pattern="MMMM d, yyyy 'at' h:mm a"/>
                        </div>
                        <div class="detail-item">
                            <strong>Refund Method:</strong>
                            Original Payment Method
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <div class="transaction-actions">
        <c:if test="${sessionScope.user.role == 'ADMIN' && transaction.status == 'SUCCESSFUL'}">
            <a href="${pageContext.request.contextPath}/transaction/refund?transactionId=${transaction.transactionId}"
               class="btn btn-danger">Process Refund</a>
        </c:if>
        <button onclick="window.print()" class="btn btn-secondary">Print Receipt</button>
    </div>
</div>

<style>
.transaction-details-container {
    padding: 20px 0;
}

.transaction-header {
    margin-bottom: 30px;
}

.page-title {
    margin-bottom: 10px;
    color: var(--dark-text);
}

.breadcrumbs {
    color: var(--light-text);
    font-size: 14px;
}

.transaction-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.transaction-main-details, .transaction-order-details {
    flex: 1;
    min-width: 300px;
}

.transaction-card, .order-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 20px;
    box-shadow: var(--card-shadow);
}

.transaction-summary, .order-summary {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #333;
}

.detail-section {
    margin-bottom: 20px;
}

.detail-item {
    margin-bottom: 10px;
    color: var(--light-text);
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.transaction-actions {
    display: flex;
    justify-content: flex-end;
    gap: 15px;
    margin-top: 30px;
}

@media (max-width: 768px) {
    .transaction-content {
        flex-direction: column;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />