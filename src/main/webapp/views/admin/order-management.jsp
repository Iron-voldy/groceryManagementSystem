<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Order Management" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="container order-management">
    <h1>Order Management</h1>

    <div class="filter-section">
        <form action="${pageContext.request.contextPath}/order/list" method="get">
            <div class="filter-row">
                <select name="status">
                    <option value="">All Statuses</option>
                    <option value="PENDING">Pending</option>
                    <option value="PROCESSING">Processing</option>
                    <option value="SHIPPED">Shipped</option>
                    <option value="DELIVERED">Delivered</option>
                    <option value="CANCELLED">Cancelled</option>
                </select>

                <input type="date" name="startDate" placeholder="Start Date">
                <input type="date" name="endDate" placeholder="End Date">

                <button type="submit" class="btn btn-primary">Filter</button>
            </div>
        </form>
    </div>

    <div class="order-list">
        <table class="table">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${orders}">
                    <tr>
                        <td>${order.orderId.substring(0,8)}</td>
                        <td>${order.userId}</td>
                        <td>
                            <fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy"/>
                        </td>
                        <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                        <td>
                            <span class="status-badge status-${fn:toLowerCase(order.status)}">
                                ${order.status}
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}"
                                   class="btn btn-sm btn-primary">View</a>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-secondary dropdown-toggle">
                                        Update Status
                                    </button>
                                    <div class="dropdown-menu">
                                        <form action="${pageContext.request.contextPath}/order/update-status" method="post">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" name="status" value="PROCESSING"
                                                    class="dropdown-item">Processing</button>
                                            <button type="submit" name="status" value="SHIPPED"
                                                    class="dropdown-item">Shipped</button>
                                            <button type="submit" name="status" value="DELIVERED"
                                                    class="dropdown-item">Delivered</button>
                                            <button type="submit" name="status" value="CANCELLED"
                                                    class="dropdown-item">Cancelled</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<style>
.order-management {
    padding: 20px;
}

.filter-section {
    margin-bottom: 20px;
}

.filter-row {
    display: flex;
    gap: 10px;
}

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
</style>

<jsp:include page="/views/common/admin-footer.jsp" />