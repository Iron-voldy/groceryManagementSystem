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
    <jsp:param name="title" value="My Orders" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="container my-orders">
    <h1>My Orders</h1>

    <c:choose>
        <c:when test="${not empty orders}">
            <div class="order-list">
                <c:forEach var="order" items="${orders}">
                    <div class="order-card">
                        <div class="order-header">
                            <span class="order-id">Order #${fn:substring(order.orderId, 0, 8)}</span>
                            <span class="order-date">
                                <%
                                    LocalDateTime orderDate = ((com.grocerymanagement.model.Order)pageContext.getAttribute("order")).getOrderDate();
                                    Date convertedDate = convertToDate(orderDate);
                                %>
                                <fmt:formatDate value="<%= convertedDate %>" pattern="MMM dd, yyyy HH:mm"/>
                            </span>
                        </div>
                        <div class="order-body">
                            <div class="order-items">
                                <c:forEach var="item" items="${order.items}">
                                    <div class="order-item">
                                        <span class="item-name">${item.productName}</span>
                                        <span class="item-quantity">Qty: ${item.quantity}</span>
                                        <span class="item-price">
                                            $<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>
                                        </span>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="order-summary">
                                <span class="total-label">Total:</span>
                                <span class="total-amount">
                                    $<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                                </span>
                            </div>
                            <div class="order-status">
                                <span class="status-badge status-${fn:toLowerCase(order.status)}">
                                    ${order.status}
                                </span>
                            </div>
                        </div>
                        <div class="order-actions">
                            <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}"
                               class="btn btn-sm btn-primary">View Details</a>
                            <c:if test="${order.status == 'PENDING'}">
                                <form action="${pageContext.request.contextPath}/order/cancel" method="post">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Cancel Order</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-orders">
                <p>You haven't placed any orders yet.</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary">
                    Start Shopping
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.my-orders {
    max-width: 800px;
    margin: 0 auto;
}

.order-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    margin-bottom: 20px;
    box-shadow: var(--card-shadow);
}

.order-header {
    display: flex;
    justify-content: space-between;
    padding: 15px;
    background-color: var(--dark-surface-hover);
    border-top-left-radius: var(--border-radius);
    border-top-right-radius: var(--border-radius);
}

.order-body {
    padding: 15px;
}

.order-items {
    margin-bottom: 15px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
}

.order-status {
    text-align: right;
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
}

.status-pending {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.status-processing {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.status-shipped {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-delivered {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-cancelled {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}
</style>

<jsp:include page="/views/common/footer.jsp" />