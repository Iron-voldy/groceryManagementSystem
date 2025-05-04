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
    <jsp:param name="title" value="Order Details" />
</jsp:include>

<div class="container order-details">
    <div class="order-details-card">
        <div class="order-header">
            <h1>Order Details</h1>
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

        <div class="order-content">
            <div class="order-items">
                <h2>Order Items</h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Unit Price</th>
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
                </table>
            </div>

            <div class="order-summary">
                <h2>Order Summary</h2>
                <div class="summary-row">
                    <span>Subtotal</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row">
                    <span>Tax (10%)</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount * 0.1}" pattern="#,##0.00"/></span>
                </div>
                <div class="summary-row total">
                    <span>Total</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount * 1.1}" pattern="#,##0.00"/></span>
                </div>
            </div>

            <div class="order-status">
                <h2>Order Status</h2>
                <div class="status-badge status-${fn:toLowerCase(order.status)}">
                    ${order.status}
                </div>
                <c:if test="${order.status == 'PENDING'}">
                    <form action="${pageContext.request.contextPath}/order/cancel" method="post">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <button type="submit" class="btn btn-danger">Cancel Order</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</div>

<style>
    .status-badge {
        display: inline-block;
        padding: 5px 10px;
        border-radius: 20px;
        font-size: 12px;
    }
    .status-pending { background-color: rgba(255, 152, 0, 0.2); color: var(--warning); }
    .status-processing { background-color: rgba(33, 150, 243, 0.2); color: var(--info); }
    .status-shipped { background-color: rgba(76, 175, 80, 0.2); color: var(--success); }
    .status-delivered { background-color: rgba(76, 175, 80, 0.4); color: var(--success); }
    .status-cancelled { background-color: rgba(244, 67, 54, 0.2); color: var(--danger); }

.order-details {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.order-details-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    padding: 30px;
}

.order-header {
    margin-bottom: 30px;
    border-bottom: 1px solid var(--dark-surface-hover);
    padding-bottom: 15px;
}

.order-meta {
    display: flex;
    justify-content: space-between;
}

.table {
    width: 100%;
    margin-bottom: 30px;
}

.table th, .table td {
    padding: 10px;
    border-bottom: 1px solid var(--dark-surface-hover);
}

.order-summary {
    margin-bottom: 30px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid var(--dark-surface-hover);
}

.summary-row.total {
    font-weight: bold;
}

.status-badge {
    display: inline-block;
    padding: 10px 15px;
    border-radius: 20px;
    margin-bottom: 15px;
}
</style>

<jsp:include page="/views/common/footer.jsp" />