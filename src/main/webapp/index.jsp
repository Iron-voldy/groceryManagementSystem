<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="GroceryShop - Fresh Groceries Delivered" />
    <jsp:param name="active" value="home" />
</jsp:include>

<main class="home-page">
    <section class="hero-section container">
        <div class="hero-content">
            <div class="hero-text">
                <h1>Fresh Groceries, Delivered Directly to You</h1>
                <p>Discover premium quality produce, pantry essentials, and more - all at your fingertips.</p>
                <div class="hero-actions">
                    <a href="<c:url value='/product/list'/>" class="btn btn-primary">
                        Shop Now <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="#categories" class="btn btn-secondary">
                        Browse Categories <i class="fas fa-list"></i>
                    </a>
                </div>
            </div>
            <div class="hero-image">
                <img src="https://images.unsplash.com/photo-1542838132-92c1b18a7e91" alt="Fresh Groceries">
            </div>
        </div>
    </section>

    <section id="categories" class="categories-section container">
        <h2 class="section-title">Shop by Category</h2>
        <div class="categories-grid">
            <c:set var="categories" value="${[
                'Fresh Products:https://images.unsplash.com/photo-1542838132-92c1b18a7e91:Fresh Produce',
                'Dairy:https://images.unsplash.com/photo-1582564286939-400c5f16deja:Dairy Products',
                'Vegetables:https://images.unsplash.com/photo-1563767801639-f:Organic Vegetables',
                'Fruits:https://images.unsplash.com/photo-1449373557:Fresh Fruits',
                'Pantry Items:https://images.unsplash.com/photo-1542838132-92c1b18a7e9:Kitchen Essentials'
            ]}"/>

            <c:forEach var="category" items="${categories}">
                <c:set var="catDetails" value="${fn:split(category, ':')}"/>
                <a href="<c:url value='/product/category?category=${catDetails[0]}'/>" class="category-card card">
                    <img src="${catDetails[1]}" alt="${catDetails[0]}">
                    <div class="category-details">
                        <h3>${catDetails[0]}</h3>
                        <p>${catDetails[2]}</p>
                    </div>
                </a>
            </c:forEach>
        </div>
    </section>

    <section class="featured-products container">
        <h2 class="section-title">Featured Products</h2>
        <div class="products-grid">
            <c:forEach var="product" items="${featuredProducts}">
                <div class="product-card card">
                    <img src="https://images.unsplash.com/photo-1542838132" alt="${product.name}">
                    <div class="product-details">
                        <h3>${product.name}</h3>
                        <p class="product-category">${product.category}</p>
                        <div class="product-footer">
                            <span class="product-price">
                                $<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/>
                            </span>
                            <div class="product-actions">
                                <button onclick="addToCart('${product.productId}')" class="btn btn-primary btn-sm">
                                    Add to Cart
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <section class="newsletter container">
        <div class="newsletter-content">
            <h2>Get Fresh Updates Delivered</h2>
            <p>Subscribe to our newsletter and enjoy exclusive offers!</p>
            <form class="newsletter-form">
                <input type="email" placeholder="Your email address" required>
                <button type="submit" class="btn btn-primary">Subscribe</button>
            </form>
        </div>
    </section>
</main>

<style>
    /* Page-specific styles */
    .hero-section {
        display: flex;
        align-items: center;
        gap: var(--spacing-lg);
        margin-bottom: var(--spacing-lg);
    }

    .hero-content {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: var(--spacing-lg);
        align-items: center;
    }

    .categories-grid,
    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--spacing-md);
    }

    .newsletter {
        text-align: center;
        background-color: var(--surface-color);
        padding: var(--spacing-lg);
        border-radius: 12px;
    }

    .newsletter-form {
        display: flex;
        max-width: 500px;
        margin: 0 auto;
        gap: var(--spacing-sm);
    }

    .newsletter-form input {
        flex-grow: 1;
        padding: var(--spacing-sm);
        background-color: var(--background-color);
        border: 1px solid var(--border-color);
        color: var(--text-primary);
        border-radius: 8px;
    }
</style>

<script src="https://kit.fontawesome.com/your-fontawesome-kit.js" crossorigin="anonymous"></script>
<script>
    function showNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;

        // Use a ternary operator that works with EL expressions
        const icon = type === 'success'
            ? '<i class="fas fa-check-circle"></i>'
            : '<i class="fas fa-exclamation-circle"></i>';

        notification.innerHTML = `${icon} ${message}`;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.classList.add('show');
        }, 10);

        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => {
                notification.remove();
            }, 300);
        }, 3000);
    }

    function addToCart(productId) {
        fetch(`${contextPath}/cart/add`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `productId=${productId}&quantity=1`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('Product added to cart', 'success');
                updateCartCount(data.cartItemCount);
            } else {
                showNotification(data.message || 'Failed to add product to cart', 'error');
            }
        })
        .catch(error => {
            console.error('Error adding to cart:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }

    function updateCartCount(count) {
        const cartCountElements = document.querySelectorAll('.cart-count');
        cartCountElements.forEach(element => {
            element.textContent = count;
            if (count > 0) {
                element.classList.add('has-items');
            } else {
                element.classList.remove('has-items');
            }
        });
    }
</script>

<style>
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px;
        border-radius: 5px;
        color: white;
        opacity: 0;
        transition: opacity 0.3s;
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .notification.notification-success {
        background-color: #4CAF50;
    }

    .notification.notification-error {
        background-color: #F44336;
    }

    .notification.show {
        opacity: 1;
    }

    .notification i {
        margin-right: 10px;
    }
</style>

<jsp:include page="/views/common/footer.jsp" />