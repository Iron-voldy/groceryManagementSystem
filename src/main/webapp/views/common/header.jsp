<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title} | GroceryShop</title>

    <!-- Use CDN for Font Awesome to avoid CORS issues -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" integrity="sha512-1ycn6IcaQQ40/MKBW2W4Rhis/DbILU74C1vSrLJxCq57o941Ym01SwNsOMqvEBFlcgUa6xLiPY/NS5R+E6ztJQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <!-- Custom CSS -->
    <style>
        :root {
            --primary-color: #4CAF50;
            --primary-dark: #388E3C;
            --primary-light: #C8E6C9;
            --secondary-color: #FF9800;
            --dark-color: #333333;
            --light-color: #f8f9fa;
            --text-color: #212529;
            --light-text: #6c757d;
            --border-color: #dee2e6;
            --success-color: #28a745;
            --danger-color: #dc3545;
            --warning-color: #ffc107;
            --info-color: #17a2b8;
        }

        body {
            font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            color: var(--text-color);
            line-height: 1.6;
        }

        /* Header Styles */
        .navbar {
            background-color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 0.5rem 1rem;
        }

        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary-color);
        }

        .navbar-brand i {
            margin-right: 0.5rem;
        }

        .nav-link {
            color: var(--text-color);
            font-weight: 500;
            padding: 0.5rem 1rem;
            transition: color 0.3s ease;
        }

        .nav-link:hover {
            color: var(--primary-color);
        }

        .nav-link.active {
            color: var(--primary-color);
            border-bottom: 2px solid var(--primary-color);
        }

        .search-form {
            position: relative;
            margin-right: 1rem;
        }

        .search-input {
            border: 1px solid var(--border-color);
            border-radius: 50px;
            padding: 0.375rem 2.5rem 0.375rem 1rem;
            width: 100%;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .search-input:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(76, 175, 80, 0.25);
        }

        .search-btn {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            border: none;
            background: transparent;
            padding: 0 0.75rem;
            color: var(--light-text);
            cursor: pointer;
        }

        .search-btn:hover {
            color: var(--primary-color);
        }

        .cart-link {
            position: relative;
            display: flex;
            align-items: center;
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
        }

        .cart-icon {
            font-size: 1.5rem;
            margin-right: 0.5rem;
        }

        .cart-count {
            position: absolute;
            top: -8px;
            right: -8px;
            background-color: var(--primary-color);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: bold;
        }

        .cart-count.has-items {
            display: flex;
        }

        .user-actions {
            display: flex;
            align-items: center;
        }

        .btn {
            padding: 0.375rem 1rem;
            border-radius: 50px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }

        .btn-outline-primary {
            color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-outline-primary:hover {
            background-color: var(--primary-color);
            color: white;
        }

        /* User dropdown menu */
        .user-dropdown {
            position: relative;
            display: inline-block;
        }

        .dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            background-color: white;
            min-width: 200px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 1;
            border-radius: 0.25rem;
            padding: 0.5rem 0;
        }

        .user-dropdown:hover .dropdown-menu {
            display: block;
        }

        .dropdown-item {
            display: block;
            padding: 0.5rem 1rem;
            color: var(--text-color);
            text-decoration: none;
            transition: background-color 0.3s ease;
        }

        .dropdown-item:hover {
            background-color: #f8f9fa;
            color: var(--primary-color);
        }

        .dropdown-divider {
            height: 1px;
            background-color: var(--border-color);
            margin: 0.5rem 0;
        }

        /* Responsive Breakpoints */
        @media (max-width: 992px) {
            .navbar-collapse {
                background-color: white;
                padding: 1rem;
                box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
                border-radius: 0 0 0.5rem 0.5rem;
            }

            .search-form {
                margin: 0.5rem 0;
                width: 100%;
            }

            .user-actions {
                flex-direction: column;
                align-items: flex-start;
                width: 100%;
            }

            .user-actions .btn {
                margin: 0.25rem 0;
                width: 100%;
            }

            .cart-link {
                margin: 0.5rem 0;
            }

            .dropdown-menu {
                position: static;
                box-shadow: none;
                width: 100%;
                margin-top: 0.5rem;
            }
        }

        @media (max-width: 576px) {
            .navbar-brand {
                font-size: 1.2rem;
            }
        }

        /* Add Animation Classes */
        .fade-in {
            animation: fadeIn 0.5s ease forwards;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Form Fields */
        .form-group {
            margin-bottom: 1rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--text-color);
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border-color);
            border-radius: 0.25rem;
            background-color: white;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(76, 175, 80, 0.25);
        }

        /* Alert Messages */
        .alert {
            padding: 1rem;
            border-radius: 0.25rem;
            margin-bottom: 1rem;
        }

        .alert-success {
            background-color: var(--primary-light);
            color: var(--primary-dark);
            border-left: 4px solid var(--primary-color);
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid var(--danger-color);
        }

        .alert-warning {
            background-color: #fff3cd;
            color: #856404;
            border-left: 4px solid var(--warning-color);
        }

        /* Notification styling */
        #notification-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }

        .notification {
            background-color: var(--primary-color);
            color: white;
            padding: 15px 20px;
            margin-bottom: 10px;
            border-radius: 5px;
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
    </style>
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-lg navbar-light">
            <div class="container">
                <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                    <i class="fas fa-shopping-basket"></i> GroceryShop
                </a>

                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav mr-auto">
                        <li class="nav-item">
                            <a class="nav-link ${param.active == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${param.active == 'products' ? 'active' : ''}" href="${pageContext.request.contextPath}/product/list">Products</a>
                        </li>
                        <c:if test="${not empty sessionScope.user}">
                            <li class="nav-item">
                                <a class="nav-link ${param.active == 'orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/order/user-orders">My Orders</a>
                            </li>
                        </c:if>
                    </ul>

                    <form class="search-form d-flex" action="${pageContext.request.contextPath}/product/search" method="get">
                        <input type="text" name="searchTerm" class="search-input" placeholder="Search products...">
                        <button type="submit" class="search-btn">
                            <i class="fas fa-search"></i>
                        </button>
                    </form>

                    <div class="user-actions">
                        <c:choose>
                            <c:when test="${empty sessionScope.user}">
                                <a href="${pageContext.request.contextPath}/views/user/login.jsp" class="btn btn-outline-primary mr-2">Login</a>
                                <a href="${pageContext.request.contextPath}/views/user/register.jsp" class="btn btn-primary">Register</a>
                            </c:when>
                            <c:otherwise>
                                <div class="user-dropdown">
                                    <a href="#" class="nav-link">
                                        <i class="fas fa-user"></i> ${sessionScope.user.username} <i class="fas fa-chevron-down ml-1"></i>
                                    </a>
                                    <div class="dropdown-menu">
                                        <a href="${pageContext.request.contextPath}/views/user/profile.jsp" class="dropdown-item">
                                            <i class="fas fa-user-circle mr-2"></i> Profile
                                        </a>
                                        <a href="${pageContext.request.contextPath}/order/user-orders" class="dropdown-item">
                                            <i class="fas fa-shopping-bag mr-2"></i> My Orders
                                        </a>
                                        <a href="${pageContext.request.contextPath}/payment/saved-cards" class="dropdown-item">
                                            <i class="fas fa-credit-card mr-2"></i> Payment Methods
                                        </a>
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/user/logout" class="dropdown-item">
                                            <i class="fas fa-sign-out-alt mr-2"></i> Logout
                                        </a>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <a href="${pageContext.request.contextPath}/cart/view" class="cart-link ml-3">
                            <i class="fas fa-shopping-cart cart-icon"></i>
                            <span class="cart-count ${not empty sessionScope.cartItemCount && sessionScope.cartItemCount > 0 ? 'has-items' : ''}">
                                ${not empty sessionScope.cartItemCount ? sessionScope.cartItemCount : '0'}
                            </span>
                        </a>
                    </div>
                </div>
            </div>
        </nav>
    </header>

    <main class="container mt-4">
        <c:if test="${not empty param.message || not empty requestScope.message || not empty sessionScope.message}">
            <div class="alert alert-${not empty param.alertType ? param.alertType : 'success'}" role="alert">
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