<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | FreshCart</title>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>

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

        /* Dashboard Content */
        .dashboard-title {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: var(--spacing-lg);
            color: var(--text-primary);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: var(--spacing-lg);
            margin-bottom: var(--spacing-xl);
        }

        .stat-card {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            padding: var(--spacing-lg);
            box-shadow: var(--box-shadow);
            transition: transform var(--transition-speed), box-shadow var(--transition-speed);
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--box-shadow-hover);
        }

        .stat-icon {
            position: absolute;
            right: var(--spacing-lg);
            top: var(--spacing-lg);
            font-size: 2.5rem;
            opacity: 0.1;
            color: var(--primary);
        }

        .stat-title {
            font-size: 0.9rem;
            color: var(--text-secondary);
            margin-bottom: var(--spacing-sm);
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: var(--spacing-sm);
            color: var(--text-primary);
        }

        .stat-badge {
            display: inline-flex;
            align-items: center;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .stat-badge.positive {
            background-color: rgba(40, 167, 69, 0.1);
            color: var(--success);
        }

        .stat-badge.negative {
            background-color: rgba(220, 53, 69, 0.1);
            color: var(--danger);
        }

        .stat-badge i {
            margin-right: 5px;
        }

        /* Charts Section */
        .charts-section {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: var(--spacing-lg);
            margin-bottom: var(--spacing-xl);
        }

        @media (max-width: 992px) {
            .charts-section {
                grid-template-columns: 1fr;
            }
        }

        .chart-card {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            padding: var(--spacing-lg);
            box-shadow: var(--box-shadow);
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--spacing-lg);
        }

        .chart-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .chart-period {
            display: inline-block;
            padding: 5px 15px;
            background-color: var(--light);
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all var(--transition-speed);
        }

        .chart-period:hover {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        .chart-container {
            position: relative;
            height: 300px;
        }

        .donut-chart-container {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .donut-chart-legend {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: var(--spacing-sm);
            margin-top: var(--spacing-md);
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }

        /* Recent Entities Sections */
        .recent-section {
            margin-bottom: var(--spacing-xl);
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--spacing-lg);
        }

        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .view-all {
            font-size: 0.85rem;
            color: var(--primary);
            transition: color var(--transition-speed);
        }

        .view-all:hover {
            color: var(--primary-dark);
        }

        .table-container {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            padding: var(--spacing-lg);
            box-shadow: var(--box-shadow);
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

        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
        }

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

        .role-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.7rem;
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

        .action-buttons {
            display: flex;
            gap: 5px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.8rem;
            font-weight: 500;
            cursor: pointer;
            transition: all var(--transition-speed);
            border: none;
        }

        .btn-sm {
            padding: 4px 8px;
            font-size: 0.75rem;
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

        .btn-outline {
            background-color: transparent;
            border: 1px solid var(--gray);
            color: var(--gray);
        }

        .btn-outline:hover {
            background-color: var(--gray);
            color: white;
        }

        /* Inventory Section */
        .inventory-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: var(--spacing-lg);
            margin-bottom: var(--spacing-xl);
        }

        .inventory-card {
            background-color: var(--bg-card);
            border-radius: var(--border-radius);
            padding: var(--spacing-lg);
            box-shadow: var(--box-shadow);
            transition: transform var(--transition-speed), box-shadow var(--transition-speed);
        }

        .inventory-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--box-shadow-hover);
        }

        .inventory-header {
            display: flex;
            align-items: center;
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-md);
        }

        .inventory-image {
            width: 60px;
            height: 60px;
            border-radius: 10px;
            object-fit: cover;
            background-color: var(--light);
        }

        .inventory-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .inventory-category {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        .inventory-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: var(--spacing-md);
        }

        .inventory-stat {
            text-align: center;
        }

        .stat-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-bottom: 5px;
        }

        .stat-number {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .inventory-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .stock-status {
            font-size: 0.8rem;
            font-weight: 500;
        }

        .in-stock {
            color: var(--success);
        }

        .low-stock {
            color: var(--warning);
        }

        .out-of-stock {
            color: var(--danger);
        }

        /* Responsive */
        @media (max-width: 1200px) {
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
            .stats-grid {
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            }

            .chart-container {
                height: 250px;
            }

            .main-header {
                padding: 0 var(--spacing-md);
            }

            .header-search {
                display: none;
            }
        }

        @media (max-width: 576px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .main-content {
                padding: var(--spacing-md);
                padding-top: calc(var(--header-height) + var(--spacing-md));
            }

            .dashboard-title {
                font-size: 1.5rem;
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
                    <span class="logo-text">FreshCart</span>
                </a>
                <div class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </div>
            </div>

            <nav class="sidebar-menu">
                <ul>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="menu-link active">
                            <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                            <span class="menu-text">Dashboard</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-box"></i></span>
                            <span class="menu-text">Products</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/inventory.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-warehouse"></i></span>
                            <span class="menu-text">Inventory</span>
                            <span class="menu-badge">3</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/orders.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-shopping-cart"></i></span>
                            <span class="menu-text">Orders</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/users.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-users"></i></span>
                            <span class="menu-text">Customers</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/reviews.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-star"></i></span>
                            <span class="menu-text">Reviews</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/transactions.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-credit-card"></i></span>
                            <span class="menu-text">Transactions</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/reports.jsp" class="menu-link">
                            <span class="menu-icon"><i class="fas fa-chart-bar"></i></span>
                            <span class="menu-text">Reports</span>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/views/admin/settings.jsp" class="menu-link">
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
            <h1 class="dashboard-title">Dashboard</h1>

            <!-- Stats Overview -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-shopping-cart"></i></div>
                    <div class="stat-title">Total Orders</div>
                    <div class="stat-value">
                        <c:choose>
                            <c:when test="${not empty stats and not empty stats.totalOrders}">
                                ${stats.totalOrders}
                            </c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty stats and not empty stats.orderChange}">
                        <div class="stat-badge ${stats.orderChange >= 0 ? 'positive' : 'negative'}">
                            <i class="fas ${stats.orderChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down'}"></i>
                            <c:choose>
                                <c:when test="${stats.orderChange >= 0}">
                                    ${stats.orderChange}% from last month
                                </c:when>
                                <c:otherwise>
                                    ${-stats.orderChange}% from last month
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>

                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                    <div class="stat-title">Total Customers</div>
                    <div class="stat-value">
                        <c:choose>
                            <c:when test="${not empty stats and not empty stats.totalUsers}">
                                ${stats.totalUsers}
                            </c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty stats and not empty stats.userChange}">
                        <div class="stat-badge ${stats.userChange >= 0 ? 'positive' : 'negative'}">
                            <i class="fas ${stats.userChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down'}"></i>
                            <c:choose>
                                <c:when test="${stats.userChange >= 0}">
                                    ${stats.userChange}% from last month
                                </c:when>
                                <c:otherwise>
                                    ${-stats.userChange}% from last month
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>

                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-dollar-sign"></i></div>
                    <div class="stat-title">Total Revenue</div>
                    <div class="stat-value">$
                        <c:choose>
                            <c:when test="${not empty stats and not empty stats.totalRevenue}">
                                <fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0.00"/>
                            </c:when>
                            <c:otherwise>0.00</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty stats and not empty stats.revenueChange}">
                        <div class="stat-badge ${stats.revenueChange >= 0 ? 'positive' : 'negative'}">
                            <i class="fas ${stats.revenueChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down'}"></i>
                            <c:choose>
                                <c:when test="${stats.revenueChange >= 0}">
                                    ${stats.revenueChange}% from last month
                                </c:when>
                                <c:otherwise>
                                    ${-stats.revenueChange}% from last month
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>

                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-box"></i></div>
                    <div class="stat-title">Total Products</div>
                    <div class="stat-value">
                        <c:choose>
                            <c:when test="${not empty stats and not empty stats.totalProducts}">
                                ${stats.totalProducts}
                            </c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty stats and not empty stats.productChange}">
                        <div class="stat-badge ${stats.productChange >= 0 ? 'positive' : 'negative'}">
                            <i class="fas ${stats.productChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down'}"></i>
                            <c:choose>
                                <c:when test="${stats.productChange >= 0}">
                                    ${stats.productChange}% from last month
                                </c:when>
                                <c:otherwise>
                                    ${-stats.productChange}% from last month
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="charts-section">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Sales Overview</h3>
                        <div class="chart-period">Last 12 Months</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="salesChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <h3 class="chart-title">Product Categories</h3>
                        <div class="chart-period">All Time</div>
                    </div>
                    <div class="donut-chart-container">
                        <canvas id="categoriesChart"></canvas>
                        <div class="donut-chart-legend">
                            <div class="legend-item">
                                <div class="legend-color" style="background-color: #4CAF50;"></div>
                                <span>Fresh Products</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background-color: #2196F3;"></div>
                                <span>Dairy</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background-color: #FFC107;"></div>
                                <span>Vegetables</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background-color: #E91E63;"></div>
                                <span>Fruits</span>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background-color: #9C27B0;"></div>
                                <span>Pantry Items</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Inventory Alert Section -->
            <div class="inventory-section">
                <c:choose>
                    <c:when test="${not empty lowStockProducts}">
                        <c:forEach var="product" items="${lowStockProducts}" varStatus="status">
                            <div class="inventory-card">
                                <div class="inventory-header">
                                    <c:choose>
                                        <c:when test="${not empty product.imagePath}">
                                            <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}" class="inventory-image">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="inventory-image"></div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <h3 class="inventory-title">${product.name}</h3>
                                        <div class="inventory-category">${product.category}</div>
                                    </div>
                                </div>
                                <div class="inventory-stats">
                                    <div class="inventory-stat">
                                        <div class="stat-label">Current Stock</div>
                                        <div class="stat-number">${product.stockQuantity}</div>
                                    </div>
                                    <div class="inventory-stat">
                                        <div class="stat-label">Reorder Point</div>
                                        <div class="stat-number">10</div>
                                    </div>
                                    <div class="inventory-stat">
                                        <div class="stat-label">Price</div>
                                        <div class="stat-number">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></div>
                                    </div>
                                </div>
                                <div class="inventory-footer">
                                    <div class="stock-status ${product.stockQuantity == 0 ? 'out-of-stock' : (product.stockQuantity < 10 ? 'low-stock' : 'in-stock')}">
                                        <i class="fas ${product.stockQuantity == 0 ? 'fa-times-circle' : (product.stockQuantity < 10 ? 'fa-exclamation-circle' : 'fa-check-circle')}"></i>
                                        ${product.stockQuantity == 0 ? 'Out of Stock' : (product.stockQuantity < 10 ? 'Low Stock' : 'In Stock')}
                                    </div>
                                    <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="btn btn-outline btn-sm">View Details</a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="inventory-card" style="grid-column: 1 / -1; text-align: center;">
                            <p>No low stock products to display.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Recent Orders Section -->
            <div class="recent-section">
                <div class="section-header">
                    <h3 class="section-title">Recent Orders</h3>
                    <a href="${pageContext.request.contextPath}/order/list" class="view-all">View All</a>
                </div>

                <div class="table-container">
                    <table class="data-table">
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
                                        <tr>
                                            <td>#${fn:substring(order.orderId, 0, 8)}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty allUsers}">
                                                        <c:forEach var="user" items="${allUsers}">
                                                            <c:if test="${user.userId eq order.userId}">
                                                                ${user.username}
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        User ID: ${fn:substring(order.userId, 0, 8)}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty order.orderDate}">
                                                        <fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy" />
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                                            <td>
                                                <span class="status-badge status-${fn:toLowerCase(order.status)}">${order.status}</span>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-outline btn-sm">View</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align: center;">No recent orders found</td>
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
                    <h3 class="section-title">Recent Customers</h3>
                    <a href="${pageContext.request.contextPath}/user/list" class="view-all">View All</a>
                </div>

                <div class="table-container">
                    <table class="data-table">
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
                                        <tr>
                                            <td>#${fn:substring(user.userId, 0, 8)}</td>
                                            <td>${user.username}</td>
                                            <td>${user.email}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty user.registrationDate}">
                                                        <fmt:formatDate value="${user.registrationDate}" pattern="MMM dd, yyyy" />
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="role-badge role-${fn:toLowerCase(user.role)}">${user.role}</span>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="${pageContext.request.contextPath}/views/admin/user-edit.jsp?userId=${user.userId}" class="btn btn-outline btn-sm">Edit</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align: center;">No recent users found</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Toggle Sidebar
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('sidebar-collapsed');
        });

        // Charts
        document.addEventListener('DOMContentLoaded', function() {
            // Sales Chart
            const salesCtx = document.getElementById('salesChart').getContext('2d');
            const salesChart = new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: '2024',
                        data: [
                            <c:choose>
                                <c:when test="${not empty stats and not empty stats.monthlySales}">
                                    ${stats.monthlySales}
                                </c:when>
                                <c:otherwise>
                                    5000, 6000, 8000, 7500, 9000, 10000, 11000, 10500, 12000, 13000, 12000, 14000
                                </c:otherwise>
                            </c:choose>
                        ],
                        borderColor: '#4CAF50',
                        backgroundColor: 'rgba(76, 175, 80, 0.1)',
                        tension: 0.4,
                        fill: true
                    }, {
                        label: '2023',
                        data: [
                            <c:choose>
                                <c:when test="${not empty stats and not empty stats.previousYearSales}">
                                    ${stats.previousYearSales}
                                </c:when>
                                <c:otherwise>
                                    4000, 4500, 5500, 6000, 7500, 8000, 9500, 9000, 10000, 11000, 10500, 12000
                                </c:otherwise>
                            </c:choose>
                        ],
                        borderColor: '#2196F3',
                        backgroundColor: 'rgba(33, 150, 243, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                drawBorder: false
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // Categories Chart
            const categoriesCtx = document.getElementById('categoriesChart').getContext('2d');
            const categoriesChart = new Chart(categoriesCtx, {
                type: 'doughnut',
                data: {
                    labels: [
                        <c:choose>
                            <c:when test="${not empty stats and not empty stats.categoryLabels}">
                                ${stats.categoryLabels}
                            </c:when>
                            <c:otherwise>
                                'Fresh Products', 'Dairy', 'Vegetables', 'Fruits', 'Pantry Items'
                            </c:otherwise>
                        </c:choose>
                    ],
                    datasets: [{
                        data: [
                            <c:choose>
                                <c:when test="${not empty stats and not empty stats.categoryValues}">
                                    ${stats.categoryValues}
                                </c:when>
                                <c:otherwise>
                                    25, 20, 15, 30, 10
                                </c:otherwise>
                            </c:choose>
                        ],
                        backgroundColor: [
                            '#4CAF50',
                            '#2196F3',
                            '#FFC107',
                            '#E91E63',
                            '#9C27B0'
                        ],
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    cutout: '70%'
                }
            });
        });
    </script>
</body>
</html>