<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Admin Dashboard" />
    <jsp:param name="active" value="dashboard" />
    <jsp:param name="useCharts" value="true" />
</jsp:include>

<div class="admin-dashboard">
    <h1 class="page-title">Dashboard</h1>

    <!-- Stats Overview -->
    <div class="stats-overview">
        <div class="stat-card">
            <div class="stat-icon" style="background-color: #4CAF50;">
                <i class="fas fa-shopping-cart">📦</i>
            </div>
            <div class="stat-content">
                <h3 class="stat-title">Total Orders</h3>
                <div class="stat-value">${stats.totalOrders}</div>
                <div class="stat-change ${stats.orderChange >= 0 ? 'positive' : 'negative'}">
                    ${stats.orderChange >= 0 ? '+' : ''}${stats.orderChange}% from last month
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #2196F3;">
                <i class="fas fa-users">👥</i>
            </div>
            <div class="stat-content">
                <h3 class="stat-title">Total Users</h3>
                <div class="stat-value">${stats.totalUsers}</div>
                <div class="stat-change ${stats.userChange >= 0 ? 'positive' : 'negative'}">
                    ${stats.userChange >= 0 ? '+' : ''}${stats.userChange}% from last month
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #ff9800;">
                <i class="fas fa-money-bill">💰</i>
            </div>
            <div class="stat-content">
                <h3 class="stat-title">Revenue</h3>
                <div class="stat-value">$<fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0.00"/></div>
                <div class="stat-change ${stats.revenueChange >= 0 ? 'positive' : 'negative'}">
                    ${stats.revenueChange >= 0 ? '+' : ''}${stats.revenueChange}% from last month
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background-color: #e91e63;">
                <i class="fas fa-box">🛒</i>
            </div>
            <div class="stat-content">
                <h3 class="stat-title">Products</h3>
                <div class="stat-value">${stats.totalProducts}</div>
                <div class="stat-change ${stats.productChange >= 0 ? 'positive' : 'negative'}">
                    ${stats.productChange >= 0 ? '+' : ''}${stats.productChange}% from last month
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
        <div class="chart-card">
            <h3 class="card-title">Sales Overview</h3>
            <div class="chart-container">
                <canvas id="sales-chart" height="300" data-chart='{"labels":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"datasets":[{"label":"2023","data":[5000,6000,8000,7500,9000,10000,11000,10500,12000,13000,12000,14000],"borderColor":"#4CAF50","backgroundColor":"rgba(76, 175, 80, 0.1)","tension":0.4,"fill":true},{"label":"2024","data":[6000,7000,9000,8500,10000,11000,12000,11500,13000,14000,0,0],"borderColor":"#2196F3","backgroundColor":"rgba(33, 150, 243, 0.1)","tension":0.4,"fill":true}]}'></canvas>
            </div>
        </div>

        <div class="chart-card">
            <h3 class="card-title">Product Categories</h3>
            <div class="chart-container">
                <canvas id="categories-chart" height="300" data-chart='{"labels":["Fresh Products","Dairy","Vegetables","Fruits","Pantry Items"],"datasets":[{"data":[25,20,15,30,10],"backgroundColor":["#4CAF50","#2196F3","#ff9800","#e91e63","#9c27b0"]}]}'></canvas>
            </div>
        </div>
    </div>

    <!-- Recent Orders Section -->
    <div class="recent-section">
        <div class="section-header">
            <h3 class="section-title">Recent Orders</h3>
            <a href="${pageContext.request.contextPath}/views/admin/orders.jsp" class="view-all">View All</a>
        </div>

        <div class="table-container">
            <table class="data-table" id="recent-orders">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Date</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty recentOrders}">
                            <c:forEach var="order" items="${recentOrders}">
                                <tr data-id="${order.orderId}">
                                    <td>${order.orderId.substring(0, 8)}</td>
                                    <td>${order.userId}</td>
                                    <td><fmt:formatDate value="${order.orderDate}" pattern="MMM d, yyyy" /></td>
                                    <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                                    <td>
                                        <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-sm">View</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6">No recent orders found</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Users Section -->
    <div class="recent-section">
        <div class="section-header">
            <h3 class="section-title">Recent Users</h3>
            <a href="${pageContext.request.contextPath}/views/admin/users.jsp" class="view-all">View All</a>
        </div>

        <div class="table-container">
            <table class="data-table" id="recent-users">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Registered</th>
                        <th>Role</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty recentUsers}">
                            <c:forEach var="user" items="${recentUsers}">
                                <tr data-id="${user.userId}">
                                    <td>${user.userId.substring(0, 8)}</td>
                                    <td>${user.username}</td>
                                    <td>${user.email}</td>
                                    <td><fmt:formatDate value="${user.registrationDate}" pattern="MMM d, yyyy" /></td>
                                    <td>
                                        <span class="role-badge role-${user.role.toLowerCase()}">${user.role}</span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/views/admin/user-edit.jsp?userId=${user.userId}" class="btn btn-sm">Edit</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6">No recent users found</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
.admin-dashboard {
    padding: 0 0 40px 0;
}

.page-title {
    margin-bottom: 30px;
    color: var(--dark-text);
}

.stats-overview {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.stat-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    display: flex;
    align-items: center;
    box-shadow: var(--card-shadow);
    transition: var(--transition);
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
}

.stat-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 20px;
    font-size: 24px;
    color: white;
}

.stat-content {
    flex: 1;
}

.stat-title {
    font-size: 14px;
    color: var(--light-text);
    margin-bottom: 5px;
}

.stat-value {
    font-size: 24px;
    font-weight: 600;
    color: var(--dark-text);
    margin-bottom: 5px;
}

.stat-change {
    font-size: 12px;
}

.positive {
    color: var(--success);
}

.negative {
    color: var(--danger);
}

.charts-section {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.chart-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    box-shadow: var(--card-shadow);
}

.card-title {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
}

.chart-container {
    height: 300px;
    position: relative;
}

.recent-section {
    margin-bottom: 40px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.section-title {
    color: var(--dark-text);
    margin: 0;
}

.view-all {
    color: var(--primary);
}

.status-badge, .role-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
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
    background-color: rgba(156, 39, 176, 0.2);
    color: #9c27b0;
}

.status-delivered {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-cancelled {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.role-admin {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.role-customer {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.role-staff {
    background-color: rgba(156, 39, 176, 0.2);
    color: #9c27b0;
}

.action-buttons {
    display: flex;
    gap: 5px;
}

@media (max-width: 768px) {
    .charts-section {
        grid-template-columns: 1fr;
    }
}
</style>

<jsp:include page="/views/common/admin-footer.jsp" />