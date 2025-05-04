<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.grocerymanagement.model.Payment" %>

<%!
    // Helper method to convert LocalDateTime to Date
    private static Date convertToDate(LocalDateTime localDateTime) {
        return localDateTime == null ? null :
            Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
    }
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Payment Confirmation" />
</jsp:include>

<div class="container payment-confirmation">
    <div class="confirmation-card">
        <div class="confirmation-header">
            <h1>Payment Successful</h1>
            <p>Thank you for your purchase!</p>
        </div>

        <div class="payment-details">
            <h2>Payment Information</h2>
            <div class="detail-row">
                <span class="label">Transaction ID:</span>
                <span class="value">${payment.paymentId}</span>
            </div>
            <div class="detail-row">
                <span class="label">Payment Method:</span>
                <span class="value">${payment.paymentMethod}</span>
            </div>
            <div class="detail-row">
                <span class="label">Amount Paid:</span>
                <span class="value">
                    $<fmt:formatNumber value="${payment.amount}" pattern="#,##0.00"/>
                </span>
            </div>
            <div class="detail-row">
                <span class="label">Payment Date:</span>
                <span class="value">
                    <%
                        Payment payment = (Payment)request.getAttribute("payment");
                        Date paymentDate = convertToDate(payment.getPaymentDate());
                    %>
                    <fmt:formatDate value="<%= paymentDate %>" pattern="MMM dd, yyyy HH:mm:ss"/>
                </span>
            </div>
        </div>

        <div class="order-details">
            <h2>Order Summary</h2>
            <div class="detail-row">
                <span class="label">Order Number:</span>
                <span class="value">${order.orderId.substring(0,8)}</span>
            </div>
            <div class="detail-row">
                <span class="label">Order Status:</span>
                <span class="value">${order.status}</span>
            </div>
            <div class="order-items">
                <table>
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Price</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${order.items}">
                            <tr>
                                <td>${item.productName}</td>
                                <td>${item.quantity}</td>
                                <td>$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></td>
                                <td>$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="3">Total</td>
                            <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <div class="confirmation-actions">
            <a href="${pageContext.request.contextPath}/order/user-orders" class="btn btn-primary">
                View My Orders
            </a>
            <a href="${pageContext.request.contextPath}/product/list" class="btn btn-secondary">
                Continue Shopping
            </a>
        </div>
    </div>
</div>

<style>
.payment-confirmation {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 70vh;
    padding: 20px;
}

.confirmation-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    max-width: 700px;
    width: 100%;
    padding: 30px;
}

.confirmation-header {
    text-align: center;
    margin-bottom: 30px;
    border-bottom: 1px solid var(--dark-surface-hover);
    padding-bottom: 20px;
}

.payment-details, .order-details {
    margin-bottom: 30px;
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

.order-items table {
    width: 100%;
    border-collapse: collapse;
}

.order-items th, .order-items td {
    border: 1px solid var(--dark-surface-hover);
    padding: 10px;
    text-align: left;
}

.confirmation-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}
</style>

<jsp:include page="/views/common/footer.jsp" />