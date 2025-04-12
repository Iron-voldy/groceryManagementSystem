<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Process Refund" />
    <jsp:param name="active" value="transactions" />
</jsp:include>

<div class="refund-container">
    <div class="refund-header">
        <h1 class="page-title">Process Refund</h1>
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a> &gt;
            <a href="${pageContext.request.contextPath}/transaction/list">Transactions</a> &gt;
            <span>Refund</span>
        </div>
    </div>

    <div class="refund-content">
        <div class="transaction-details">
            <div class="detail-card">
                <h2>Transaction Information</h2>
                <div class="detail-item">
                    <strong>Transaction ID:</strong>
                    ${transaction.transactionId}
                </div>
                <div class="detail-item">
                    <strong>Amount:</strong>
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

        <div class="refund-form-container">
            <form action="${pageContext.request.contextPath}/transaction/refund" method="post" class="refund-form">
                <input type="hidden" name="transactionId" value="${transaction.transactionId}">

                <div class="form-group">
                    <label for="refund-reason">Reason for Refund</label>
                    <select id="refund-reason" name="refundReason" required>
                        <option value="">Select Reason</option>
                        <option value="PRODUCT_DEFECTIVE">Defective Product</option>
                        <option value="WRONG_PRODUCT">Wrong Product Received</option>
                        <option value="CUSTOMER_REQUEST">Customer Request</option>
                        <option value="SHIPPING_DELAY">Shipping Delay</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>

                <div id="other-reason-group" class="form-group" style="display: none;">
                    <label for="other-reason">Specify Other Reason</label>
                    <textarea id="other-reason" name="otherReason" rows="4"></textarea>
                </div>

                <div class="form-group">
                    <label for="refund-method">Refund Method</label>
                    <select id="refund-method" name="refundMethod" required>
                        <option value="ORIGINAL_PAYMENT">Original Payment Method</option>
                        <option value="STORE_CREDIT">Store Credit</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-danger">Process Refund</button>
                    <a href="${pageContext.request.contextPath}/transaction/details?transactionId=${transaction.transactionId}"
                       class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
.refund-container {
    padding: 20px 0;
}

.refund-header {
    margin-bottom: 30px;
}

.page-title {
    color: var(--dark-text);
    margin-bottom: 10px;
}

.breadcrumbs {
    color: var(--light-text);
    font-size: 14px;
}

.refund-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.transaction-details, .refund-form-container {
    flex: 1;
    min-width: 300px;
}

.detail-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
}

.detail-card h2 {
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

.refund-form {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
}

.form-group {
    margin-bottom: 20px;
}

.form-actions {
    display: flex;
    justify-content: space-between;
    gap: 15px;
}

@media (max-width: 768px) {
    .refund-content {
        flex-direction: column;
    }

    .form-actions {
        flex-direction: column;
    }

    .form-actions .btn {
        width: 100%;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const refundReasonSelect = document.getElementById('refund-reason');
    const otherReasonGroup = document.getElementById('other-reason-group');

    refundReasonSelect.addEventListener('change', function() {
        if (this.value === 'OTHER') {
            otherReasonGroup.style.display = 'block';
            document.getElementById('other-reason').required = true;
        } else {
            otherReasonGroup.style.display = 'none';
            document.getElementById('other-reason').required = false;
        }
    });
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />