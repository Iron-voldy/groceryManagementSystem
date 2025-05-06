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
    <jsp:param name="title" value="Order Confirmation" />
</jsp:include>

<div class="container order-confirmation">
    <div class="confirmation-card">
        <div class="confirmation-header">
            <h1>Order Placed Successfully!</h1>
            <p>Thank you for your purchase.</p>
        </div>

        <div class="order-details">
            <h2>Order Summary</h2>
            <div class="order-info">
                <p><strong>Order Number:</strong> ${fn:substring(order.orderId, 0, 8)}</p>
                <p><strong>Order Date:</strong>
                    <%
                        LocalDateTime orderDate = ((com.grocerymanagement.model.Order)request.getAttribute("order")).getOrderDate();
                        Date convertedDate = convertToDate(orderDate);
                    %>
                    <fmt:formatDate value="<%= convertedDate %>" pattern="MMM dd, yyyy HH:mm"/>
                </p>
                <p><strong>Status:</strong> ${order.status}</p>
            </div>

            <div class="order-items">
                <h3>Items</h3>
                <table class="table">
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
                            <td colspan="3"><strong>Total</strong></td>
                            <td>
                                $<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                            </td>
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
.order-confirmation {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 70vh;
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
}

.order-details {
    margin-bottom: 30px;
}

.confirmation-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}

.table {
    width: 100%;
    margin-bottom: 20px;
}

.table th, .table td {
    padding: 10px;
    text-align: left;
    border-bottom: 1px solid var(--dark-surface-hover);
}
</style>

<jsp:include page="/views/common/footer.jsp" />