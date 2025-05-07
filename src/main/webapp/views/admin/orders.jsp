<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Orders" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="admin-orders">
    <div class="page-header">
        <h1 class="page-title">Orders</h1>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/order/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="search" placeholder="Search orders..."
                           value="${fn:escapeXml(param.search)}">
                </div>

                <div class="filter-group">
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="PROCESSING" ${param.status == 'PROCESSING' ? 'selected' : ''}>Processing</option>
                        <option value="SHIPPED" ${param.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                        <option value="DELIVERED" ${param.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                        <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
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
                    <th>User ID</th>
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
                                    <%
                                    // Custom date formatting to handle the specific LocalDateTime format
                                    LocalDateTime orderDate = ((com.grocerymanagement.model.Order)pageContext.getAttribute("order")).getOrderDate();
                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
                                    out.print(orderDate.format(formatter));
                                    %>
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

                                        <a href="${pageContext.request.contextPath}/order/edit?orderId=${order.orderId}"
                                                   class="btn btn-sm btn-primary">
                                                    <i class="fas fa-edit"></i> Edit
                                                </a>
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
                <a href="${pageContext.request.contextPath}/order/list?page=${pageNum}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.search ? '&search='.concat(param.search) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>
</div>

<style>
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