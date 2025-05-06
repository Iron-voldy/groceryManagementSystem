<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title} | Admin Dashboard</title>

    <!-- Use CDN for Font Awesome to avoid CORS issues -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <!-- Include Chart.js if needed -->
    <c:if test="${param.useCharts == 'true'}">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    </c:if>

    <!-- Custom Admin CSS -->
    <style>
        :root {
            /* Color Scheme */
            --primary: #4CAF50;
            --primary-dark: #388E3C;
            --primary-light: #C8E6C9;
            --secondary: #2196F3;
            --secondary-dark: #1976D2;
            --secondary-light: #BBDEFB;
            --success: #28a745;
            --danger: #dc3545;
            --warning: #ffc107;
            --info: #17a2b8;
            --dark-text: #212529;
            --light-text: #adb5bd;

            /* Background Colors */
            --dark-surface: #ffffff;
            --dark-surface-hover: #f8f9fa;

            /* Border and Shadow */
            --border-color: #dee2e6;
            --border-radius: 8px;
            --card-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

            /* Sidebar */
            --sidebar-width: 250px;
            --sidebar-collapsed-width: 70px;

            /* Header */
            --header-height: 70px;

            /* Transitions */
            --transition: all 0.3s ease;
        }

        body {
            font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            color: var(--dark-text);
            line-height: 1.6;
            min-height: 100vh;
            background-color: #f5f7fb;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        /* Dashboard Layout */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--dark-surface);
            border-right: 1px solid var(--border-color);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            z-index: 1000;
            transition: width var(--transition);
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
        }

        .sidebar-collapsed {
            width: var(--sidebar-collapsed-width);
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
            height: var(--header-height);
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo-icon {
            font-size: 1.8rem;
        }

        .logo-text {
            transition: opacity var(--transition);
            white-space: nowrap;
            overflow: hidden;
        }

        .sidebar-collapsed .logo-text {
            opacity: 0;
            width: 0;
        }

        .sidebar-toggle {
            cursor: pointer;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color var(--transition);
        }

        .sidebar-toggle:hover {
            background-color: var(--primary-light);
        }

        /* Sidebar Menu */
        .sidebar-menu {
            padding: 15px 0;
        }

        .menu-item {
            position: relative;
        }

        .menu-link {
            display: flex;
            align-items: center;
            padding: 10px 15px;
            color: var(--dark-text);
            font-weight: 500;
            transition: all var(--transition);
            border-radius: 5px;
            margin: 0 5px;
        }

        .menu-link:hover {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        .menu-link.active {
            background-color: var(--primary-light);
            color: var(--primary);
            font-weight: 600;
        }

        .menu-icon {
            width: 24px;
            text-align: center;
            margin-right: 15px;
            font-size: 1.2rem;
        }

        .menu-text {
            transition: opacity var(--transition);
            white-space: nowrap;
            overflow: hidden;
        }

        .sidebar-collapsed .menu-text {
            opacity: 0;
            width: 0;
        }

        .menu-badge {
            position: absolute;
            right: 10px;
            background-color: var(--danger);
            color: white;
            font-size: 0.7rem;
            font-weight: 600;
            padding: 2px 6px;
            border-radius: 10px;
        }

        .sidebar-collapsed .menu-badge {
            right: 5px;
        }

        /* User Info in Sidebar */
        .sidebar-footer {
            border-top: 1px solid var(--border-color);
            padding: 15px;
            position: sticky;
            bottom: 0;
            background-color: var(--dark-surface);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }

        .user-details {
            transition: opacity var(--transition);
            white-space: nowrap;
            overflow: hidden;
        }

        .sidebar-collapsed .user-details {
            opacity: 0;
            width: 0;
        }

        .user-name {
            font-weight: 600;
            color: var(--dark-text);
        }

        .user-role {
            font-size: 0.8rem;
            color: var(--light-text);
        }

        /* Main Content */
        .main-content {
            flex-grow: 1;
            margin-left: var(--sidebar-width);
            transition: margin-left var(--transition);
            padding: 20px;
            padding-top: calc(var(--header-height) + 20px);
        }

        .sidebar-collapsed + .main-content {
            margin-left: var(--sidebar-collapsed-width);
        }

        /* Header */
        .main-header {
            position: fixed;
            top: 0;
            right: 0;
            left: var(--sidebar-width);
            height: var(--header-height);
            background-color: var(--dark-surface);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            z-index: 900;
            transition: left var(--transition);
            border-bottom: 1px solid var(--border-color);
        }

        .sidebar-collapsed ~ .main-header {
            left: var(--sidebar-collapsed-width);
        }

        .header-search {
            flex: 1;
            max-width: 400px;
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 10px 40px 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: 30px;
            transition: all var(--transition);
            font-size: 0.9rem;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .search-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--light-text);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .action-item {
            position: relative;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background-color var(--transition);
            color: var(--light-text);
        }

        .action-item:hover {
            background-color: var(--dark-surface-hover);
            color: var(--primary);
        }

        .action-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: var(--danger);
            color: white;
            font-size: 0.7rem;
            font-weight: 600;
            padding: 2px 6px;
            border-radius: 10px;
        }

        /* Table Styles */
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table th, .data-table td {
            padding: 12px 15px;
            text-align: left;
        }

        .data-table th {
            font-weight: 600;
            color: var(--light-text);
            border-bottom: 1px solid var(--border-color);
        }

        .data-table tbody tr {
            border-bottom: 1px solid var(--border-color);
            transition: background-color var(--transition);
        }

        .data-table tbody tr:hover {
            background-color: var(--dark-surface-hover);
        }

        /* Button Styles */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 16px;
            border-radius: var(--border-radius);
            font-weight: 500;
            transition: all var(--transition);
            border: none;
            cursor: pointer;
            gap: 8px;
        }

        .btn-sm {
            padding: 5px 10px;
            font-size: 0.85rem;
        }

        .btn-primary {
            background-color: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
        }

        .btn-secondary {
            background-color: var(--secondary);
            color: white;
        }

        .btn-secondary:hover {
            background-color: var(--secondary-dark);
        }

        .btn-danger {
            background-color: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background-color: #c82333;
        }

        .btn-warning {
            background-color: var(--warning);
            color: #212529;
        }

        .btn-warning:hover {
            background-color: #e0a800;
        }

        /* Card Styles */
        .card {
            background-color: var(--dark-surface);
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .card-header {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
            font-weight: 600;
        }

        .card-body {
            padding: 20px;
        }

        /* Form Styles */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background-color: white;
            transition: var(--transition);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        /* Alert Styles */
        .alert {
            padding: 15px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
        }

        .alert-success {
            background-color: var(--primary-light);
            color: var(--primary-dark);
            border-left: 4px solid var(--primary);
        }

        .alert-danger {
            background-color: rgba(220, 53, 69, 0.1);
            color: var(--danger);
            border-left: 4px solid var(--danger);
        }

        .alert-warning {
            background-color: rgba(255, 193, 7, 0.1);
            color: #856404;
            border-left: 4px solid var(--warning);
        }

        /* Notification Styling */
        #notification-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }

        .notification {
            background-color: var(--primary);
            color: white;
            padding: 15px 20px;
            margin-bottom: 10px;
            border-radius: var(--border-radius);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            max-width: 350px;
            transform: translateX(120%);
            opacity: 0;
            transition: all 0.3s ease;
        }

        .notification.show {
            transform: translateX(0);
            opacity: 1;
        }

        .notification.error {
            background-color: var(--danger);
        }

        .notification.warning {
            background-color: var(--warning);
            color: #212529;
        }

        /* Responsive Adjustments */
        @media (max-width: 992px) {
            .sidebar {
                width: var(--sidebar-collapsed-width);
            }

            .logo-text, .menu-text, .user-details {
                opacity: 0;
                width: 0;
            }

            .main-content {
                margin-left: var(--sidebar-collapsed-width);
            }

            .main-header {
                left: var(--sidebar-collapsed-width);
            }
        }

        @media (max-width: 768px) {
            .main-header {
                padding: 0 15px;
            }

            .header-search {
                display: none;
            }
        }

        @media (max-width: 576px) {
            .main-content {
                padding: 15px;
                padding-top: calc(var(--header-height) + 15px);
            }

            .action-item span {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="logo">
                    <i class="fas fa-shopping-basket logo-icon"></i>
                    <span class="logo-text">GroceryShop</span>
                </a>
                <div class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </div>
            </div>

            <nav class="sidebar-menu">
                <ul>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="menu-link ${param.active == 'dashboard' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                            <span class="menu-text">Dashboard</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="menu-link ${param.active == 'products' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-box"></i></span>
                            <span class="menu-text">Products</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/inventory.jsp" class="menu-link ${param.active == 'inventory' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-warehouse"></i></span>
                            <span class="menu-text">Inventory</span>
                            <span class="menu-badge">3</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/orders.jsp" class="menu-link ${param.active == 'orders' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-shopping-cart"></i></span>
                            <span class="menu-text">Orders</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/users.jsp" class="menu-link ${param.active == 'users' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-users"></i></span>
                            <span class="menu-text">Customers</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/reviews.jsp" class="menu-link ${param.active == 'reviews' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-star"></i></span>
                            <span class="menu-text">Reviews</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/transactions.jsp" class="menu-link ${param.active == 'transactions' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-credit-card"></i></span>
                            <span class="menu-text">Transactions</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/settings.jsp" class="menu-link ${param.active == 'settings' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-cog"></i></span>
                            <span class="menu-text">Settings</span>
                        </a>
                    </li>
                </ul>
            </nav>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.username}">
                                ${fn:substring(sessionScope.user.username, 0, 1).toUpperCase()}
                            </c:when>
                            <c:otherwise>
                                A
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-details">
                        <div class="user-name">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.username}">
                                    ${sessionScope.user.username}
                                </c:when>
                                <c:otherwise>
                                    Admin User
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-role">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.role}">
                                    ${sessionScope.user.role}
                                </c:when>
                                <c:otherwise>
                                    Administrator
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main Header -->
        <header class="main-header">
            <div class="header-search">
                <i class="fas fa-search search-icon"></i>
                <input type="text" class="search-input" placeholder="Search...">
            </div>

            <div class="header-actions">
                <div class="action-item">
                    <i class="fas fa-bell"></i>
                    <span class="action-badge">3</span>
                </div>
                <div class="action-item">
                    <i class="fas fa-envelope"></i>
                    <span class="action-badge">2</span>
                </div>
                <a href="${pageContext.request.contextPath}/user/logout" class="action-item" title="Logout">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <c:if test="${not empty param.message || not empty requestScope.message || not empty sessionScope.message}">
                <div class="alert alert-success" role="alert">
                    ${not empty param.message ? param.message : not empty requestScope.message ? requestScope.message : sessionScope.message}
                </div>
                <c:remove var="message" scope="session" />
            </c:if>

            <c:if test="${not empty param.error || not empty requestScope.error || not empty sessionScope.error}">
                <div class="alert alert-danger" role="alert">
                    ${not empty param.error ? param.error : not empty requestScope.error ? requestScope.error : sessionScope.error}
                </div>
                <c:remove var="error" scope="session" />
            </c:if>