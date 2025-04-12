<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title} - GroceryShop</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/dark-theme.css'/>">
    <script>
        // Set context path for JavaScript
        const contextPath = '${pageContext.request.contextPath}';
    </script>
</head>
<body>
    <header>
        <div class="container header-container">
            <a href="<c:url value='/index.jsp'/>" class="logo">
                <span class="logo-icon">🛒</span> GroceryShop
            </a>

            <button class="menu-toggle" aria-label="Toggle menu">
                <span></span>
                <span></span>
                <span></span>
            </button>

            <nav class="nav-links">
                <a href="<c:url value='/index.jsp'/>" class="nav-link ${param.active == 'home' ? 'active' : ''}">Home</a>
                <a href="<c:url value='/product/list'/>" class="nav-link ${param.active == 'products' ? 'active' : ''}">Products</a>

                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a href="<c:url value='/views/user/login.jsp'/>" class="nav-link ${param.active == 'login' ? 'active' : ''}">Login</a>
                        <a href="<c:url value='/views/user/register.jsp'/>" class="nav-link ${param.active == 'register' ? 'active' : ''}">Register</a>
                    </c:when>
                    <c:otherwise>
                        <a href="<c:url value='/order/user'/>" class="nav-link ${param.active == 'orders' ? 'active' : ''}">My Orders</a>
                        <a href="<c:url value='/review/user'/>" class="nav-link ${param.active == 'reviews' ? 'active' : ''}">My Reviews</a>
                        <a href="<c:url value='/views/user/profile.jsp'/>" class="nav-link ${param.active == 'profile' ? 'active' : ''}">Profile</a>

                        <c:if test="${sessionScope.user.role == 'ADMIN'}">
                            <a href="<c:url value='/views/admin/dashboard.jsp'/>" class="nav-link ${param.active == 'admin' ? 'active' : ''}">Admin Panel</a>
                        </c:if>

                        <a href="<c:url value='/user/logout'/>" class="nav-link">Logout</a>
                    </c:otherwise>
                </c:choose>

                <a href="<c:url value='/cart/view'/>" class="nav-link cart-link ${param.active == 'cart' ? 'active' : ''}">
                    <span class="cart-icon">🛒</span>
                    <span class="cart-count ${not empty sessionScope.cartItemCount && sessionScope.cartItemCount > 0 ? 'has-items' : ''}">${not empty sessionScope.cartItemCount ? sessionScope.cartItemCount : '0'}</span>
                </a>
            </nav>
        </div>
    </header>

    <main class="container">
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