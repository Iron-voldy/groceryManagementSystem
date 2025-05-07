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
            --dark: #343a40;
            --light: #f8f9fa;
            --gray: #6c757d;
            --gray-dark: #495057;
            --gray-light: #adb5bd;

            /* Background Colors */
            --bg-body: #f5f7fb;
            --bg-sidebar: #ffffff;
            --bg-card: #ffffff;

            /* Text Colors */
            --text-primary: #212529;
            --text-secondary: #6c757d;
            --text-light: #adb5bd;
            --text-white: #ffffff;

            /* Border and Shadow */
            --border-color: #e9ecef;
            --border-radius: 10px;
            --box-shadow: 0 .125rem .25rem rgba(0,0,0,.075);
            --box-shadow-hover: 0 .5rem 1rem rgba(0,0,0,.15);

            /* Spacing */
            --spacing-xs: 0.25rem;
            --spacing-sm: 0.5rem;
            --spacing-md: 1rem;
            --spacing-lg: 1.5rem;
            --spacing-xl: 3rem;

            /* Sidebar */
            --sidebar-width: 250px;
            --sidebar-collapsed-width: 70px;

            /* Header */
            --header-height: 70px;

            /* Transitions */
            --transition-speed: 0.3s;
        }

        /* Reset & Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-primary);
            line-height: 1.6;
            min-height: 100vh;
            position: relative;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        ul {
            list-style: none;
        }

        /* Layout */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--bg-sidebar);
            border-right: 1px solid var(--border-color);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            z-index: 1000;
            transition: width var(--transition-speed);
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }

        .sidebar-collapsed {
            width: var(--sidebar-collapsed-width);
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: var(--spacing-md) var(--spacing-md);
            border-bottom: 1px solid var(--border-color);
            height: var(--header-height);
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }

        .logo-icon {
            font-size: 1.8rem;
        }

        .sidebar-toggle {
            cursor: pointer;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color var(--transition-speed);
        }

        .sidebar-toggle:hover {
            background-color: var(--primary-light);
        }

        .sidebar-menu {
            padding: var(--spacing-md) 0;
        }

        .menu-item {
            position: relative;
        }

        .menu-link {
            display: flex;
            align-items: center;
            padding: var(--spacing-sm) var(--spacing-md);
            color: var(--text-secondary);
            font-weight: 500;
            transition: all var(--transition-speed);
            border-radius: 5px;
            margin: 0 var(--spacing-xs);
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
            margin-right: var(--spacing-md);
            font-size: 1.2rem;
        }

        .menu-text {
            transition: opacity var(--transition-speed);
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

        .sidebar-footer {
            border-top: 1px solid var(--border-color);
            padding: var(--spacing-md);
            position: sticky;
            bottom: 0;
            background-color: var(--bg-sidebar);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
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
            transition: opacity var(--transition-speed);
            white-space: nowrap;
            overflow: hidden;
        }

        .sidebar-collapsed .user-details {
            opacity: 0;
            width: 0;
        }

        .user-name {
            font-weight: 600;
            color: var(--text-primary);
        }

        .user-role {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        /* Main Content */
        .main-content {
            flex-grow: 1;
            margin-left: var(--sidebar-width);
            transition: margin-left var(--transition-speed);
            padding: var(--spacing-lg);
            padding-top: calc(var(--header-height) + var(--spacing-md));
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
            background-color: var(--bg-card);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 var(--spacing-xl);
            z-index: 900;
            transition: left var(--transition-speed);
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
            padding: var(--spacing-sm) var(--spacing-lg);
            padding-left: 40px;
            border: 1px solid var(--border-color);
            border-radius: 30px;
            transition: all var(--transition-speed);
            font-size: 0.9rem;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .search-icon {
            position: absolute;
            left: var(--spacing-md);
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
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
            transition: background-color var(--transition-speed);
            color: var(--text-secondary);
        }

        .action-item:hover {
            background-color: var(--light);
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

        /* Table styles */
        .table-container {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            padding: var(--spacing-md);
            margin-bottom: var(--spacing-xl);
            overflow-x: auto;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table th,
        .data-table td {
            padding: var(--spacing-sm) var(--spacing-md);
            text-align: left;
        }

        .data-table th {
            font-weight: 600;
            color: var(--text-secondary);
            border-bottom: 1px solid var(--border-color);
        }

        .data-table tbody tr {
            border-bottom: 1px solid var(--border-color);
            transition: background-color var(--transition-speed);
        }

        .data-table tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }

        .data-table tbody tr:last-child {
            border-bottom: none;
        }

        /* Page header styles */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--spacing-lg);
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 600;
            color: var(--text-primary);
            margin: 0;
        }

        .page-actions {
            display: flex;
            gap: var(--spacing-sm);
        }

        /* Filter section styles */
        .filter-section {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            padding: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
            box-shadow: var(--box-shadow);
        }

        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: var(--spacing-sm);
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-group input,
        .filter-group select {
            width: 100%;
            padding: 8px 12px;
            border-radius: 5px;
            border: 1px solid var(--border-color);
        }

        .filter-actions {
            display: flex;
            gap: var(--spacing-sm);
            align-items: flex-end;
        }

        /* Button styles */
        .btn {
            display: inline-flex;
            align-items: center;
            padding: 8px 15px;
            border-radius: var(--border-radius);
            font-weight: 500;
            cursor: pointer;
            transition: all var(--transition-speed);
            border: none;
            text-decoration: none;
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
            color: white;
        }

        .btn-secondary {
            background-color: var(--light);
            color: var(--text-primary);
        }

        .btn-secondary:hover {
            background-color: var(--gray-light);
            color: var(--text-primary);
        }

        .btn-danger {
            background-color: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background-color: #bd2130;
            color: white;
        }

        .btn-warning {
            background-color: var(--warning);
            color: var(--dark);
        }

        .btn-warning:hover {
            background-color: #e0a800;
            color: var(--dark);
        }

        /* Status badge styles */
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        /* For order statuses */
        .status-pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: var(--warning);
        }

        .status-processing {
            background-color: rgba(33, 150, 243, 0.1);
            color: var(--secondary);
        }

        .status-shipped {
            background-color: rgba(156, 39, 176, 0.1);
            color: #9c27b0;
        }

        .status-delivered {
            background-color: rgba(76, 175, 80, 0.1);
            color: var(--success);
        }

        .status-cancelled {
            background-color: rgba(244, 67, 54, 0.1);
            color: var(--danger);
        }

        /* For user roles */
        .role-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .role-admin {
            background-color: rgba(244, 67, 54, 0.1);
            color: var(--danger);
        }

        .role-customer {
            background-color: rgba(33, 150, 243, 0.1);
            color: var(--secondary);
        }

        .role-staff {
            background-color: rgba(156, 39, 176, 0.1);
            color: #9c27b0;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: var(--spacing-lg);
        }

        .pagination a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 5px;
            background-color: var(--bg-card);
            color: var(--text-secondary);
            font-weight: 500;
            transition: all var(--transition-speed);
            box-shadow: var(--box-shadow);
        }

        .pagination a:hover {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        .pagination a.active {
            background-color: var(--primary);
            color: white;
        }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .sidebar {
                width: var(--sidebar-collapsed-width);
            }

            .menu-text, .user-details, .logo-text {
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
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .filter-row {
                flex-direction: column;
            }

            .filter-group {
                width: 100%;
            }

            .header-search {
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
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="logo">
                    <i class="fas fa-shopping-basket logo-icon"></i>
                    <span class="logo-text">FreshCart</span>
                </a>
                <div class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </div>
            </div>

            <nav class="sidebar-menu">
                <ul>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="menu-link ${param.active == 'dashboard' ? 'active' : ''}">
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
                        <a href="${pageContext.request.contextPath}/inventory/list" class="menu-link ${param.active == 'inventory' ? 'active' : ''}">
                            <span class="menu-icon"><i class="fas fa-warehouse"></i></span>
                            <span class="menu-text">Inventory</span>
                            <span class="menu-badge">3</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/order/list" class="menu-link ${param.active == 'orders' ? 'active' : ''}">
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
                        <a href="${pageContext.request.contextPath}/review/list" class="menu-link ${param.active == 'reviews' ? 'active' : ''}">
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
                <input type="text" class="search-input" placeholder="Search products, orders, customers...">
            </div>

            <div class="header-actions">
                <div class="action-item">
                    <i class="fas fa-bell"></i>
                    <span class="action-badge">5</span>
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
            <!-- Content will be injected here -->