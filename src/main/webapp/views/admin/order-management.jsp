<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Order Management" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="container order-management">
    <div class="page-header">
        <h1 class="page-title">Order Management</h1>
    </div>

    <!-- Filter Section -->
    <div class="filter-section">
        <form action="${pageContext.request.contextPath}/order/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="status-filter">Status</label>
                    <select id="status-filter" name="status">
                        <option value="">All Statuses</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="PROCESSING" ${param.status == 'PROCESSING' ? 'selected' : ''}>Processing</option>
                        <option value="SHIPPED" ${param.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                        <option value="DELIVERED" ${param.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                        <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="search-input">Search</label>
                    <input type="text" id="search-input" name="search" placeholder="Search orders..."
                           value="${param.search}">
                </div>
                <div class="filter-group">
                    <button type="submit" class="btn btn-primary">Filter</button>
                </div>
            </div>
        </form>
    </div>

    <!-- Orders Table -->
    <div class="table-container">
        <table class="data-table">
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
                <c:choose>
                    <c:when test="${not empty orders}">
                        <c:forEach var="order" items="${orders}">
                            <tr>
                                <td>${fn:substring(order.orderId, 0, 8)}</td>
                                <td>${order.userId}</td>
                                <td>
                                    <fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy HH:mm"/>
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
                                            <button class="btn btn-sm btn-secondary dropdown-toggle"
                                                    data-toggle="dropdown">
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
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="6" class="text-center">No orders found.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                <a href="${pageContext.request.contextPath}/order/list?page=${pageNum}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>
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
    gap: 15px;
    align-items: flex-end;
}

.filter-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
}

.status-pending {
    background-color: rgba(255, 152, 0, 0.2);
    color: #FF9800;
}
.status-processing {
    background-color: rgba(33, 150, 243, 0.2);
    color: #2196F3;
}
.status-shipped {
    background-color: rgba(76, 175, 80, 0.2);
    color: #4CAF50;
}
.status-delivered {
    background-color: rgba(76, 175, 80, 0.4);
    color: #4CAF50;
}
.status-cancelled {
    background-color: rgba(244, 67, 54, 0.2);
    color: #F44336;
}

.action-buttons {
    display: flex;
    gap: 5px;
}

.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
}

.pagination {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-top: 20px;
}

.pagination a {
    padding: 5px 10px;
    border: 1px solid #ddd;
    text-decoration: none;
    color: #333;
}

.pagination a.active {
    background-color: #4CAF50;
    color: white;
}
</style>

<jsp:include page="/views/common/admin-footer.jsp" />