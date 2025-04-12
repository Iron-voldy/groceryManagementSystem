<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title} - Admin Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dark-theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <script>
        // Set context path for JavaScript
        const contextPath = '${pageContext.request.contextPath}';
    </script>
</head>
<body class="admin-body">
    <header class="admin-header">
        <div class="container header-container">
            <div class="admin-header-left">
                <button class="sidebar-toggle" aria-label="Toggle sidebar">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
                <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="logo">
                    <span class="logo-icon">🛒</span> GroceryShop Admin
                </a>
            </div>

            <div class="admin-header-right">
                <div class="admin-user-info">
                    <span class="admin-username">${sessionScope.user.username}</span>
                    <span class="admin-role">${sessionScope.user.role}</span>
                </div>
                <a href="${pageContext.request.contextPath}/user/logout" class="logout-button">Logout</a>
            </div>
        </div>
    </header>

    <div class="admin-layout">
        <aside class="sidebar">
            <nav class="sidebar-nav">
                <ul class="sidebar-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="sidebar-link ${param.active == 'dashboard' ? 'active' : ''}">
                            Dashboard
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="sidebar-link ${param.active == 'products' ? 'active' : ''}">
                            Products
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/orders.jsp" class="sidebar-link ${param.active == 'orders' ? 'active' : ''}">
                            Orders
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/users.jsp" class="sidebar-link ${param.active == 'users' ? 'active' : ''}">
                            Users
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/transactions.jsp" class="sidebar-link ${param.active == 'transactions' ? 'active' : ''}">
                            Transactions
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/views/admin/reviews.jsp" class="sidebar-link ${param.active == 'reviews' ? 'active' : ''}">
                            Reviews
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/index.jsp" class="sidebar-link">
                            View Store
                        </a>
                    </li>
                </ul>
            </nav>
        </aside>

        <div class="admin-content">
            <!-- Display success message if exists -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    ${success}
                </div>
            </c:if>

            <!-- Display error message if exists -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    ${error}
                </div>
            </c:if>