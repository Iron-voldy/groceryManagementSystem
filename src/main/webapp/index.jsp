<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="FreshCart - Premium Groceries Delivered" />
    <jsp:param name="active" value="home" />
</jsp:include>

<!-- Main Content -->
<main class="home-page">
    <!-- Hero Section with Parallax Effect -->
    <section class="hero-parallax">
        <div class="hero-content container">
            <div class="hero-text">
                <h1 class="display-heading">Fresh Groceries <br>Delivered to Your Door</h1>
                <p class="hero-subtitle">Quality products, timely delivery, and exceptional service</p>
                <div class="hero-buttons">
                    <a href="<c:url value='/product/list'/>" class="btn btn-primary btn-lg">
                        Shop Now <i class="fas fa-arrow-right"></i>
                    </a>
                    <a href="#featured-products" class="btn btn-outline btn-lg">
                        Explore Products
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Value Proposition Section -->
    <section class="value-props">
        <div class="container">
            <div class="value-grid">
                <div class="value-card">
                    <div class="value-icon">
                        <i class="fas fa-truck-fast"></i>
                    </div>
                    <h3>Fast Delivery</h3>
                    <p>Get your groceries delivered within 2 hours</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">
                        <i class="fas fa-leaf"></i>
                    </div>
                    <h3>Fresh Products</h3>
                    <p>Farm-fresh produce sourced locally</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">
                        <i class="fas fa-tags"></i>
                    </div>
                    <h3>Best Prices</h3>
                    <p>Competitive pricing with regular promotions</p>
                </div>
                <div class="value-card">
                    <div class="value-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3>Secure Checkout</h3>
                    <p>Safe and secure payment methods</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Categories Section -->
    <section id="categories" class="categories-section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Shop by Category</h2>
                <p class="section-subtitle">Explore our wide range of product categories</p>
            </div>

            <div class="categories-slider">
                <c:forEach var="category" items="${['Fresh Products', 'Dairy', 'Vegetables', 'Fruits', 'Pantry Items']}">
                    <a href="<c:url value='/product/category?category=${category}'/>" class="category-card">
                        <div class="category-img-wrapper">
                            <div class="category-img" style="background-image: url('${pageContext.request.contextPath}/assets/images/${fn:toLowerCase(fn:replace(category, ' ', '-'))}.jpg')"></div>
                        </div>
                        <h3 class="category-name">${category}</h3>
                    </a>
                </c:forEach>
            </div>
        </div>
    </section>

    <!-- Featured Products Section -->
    <section id="featured-products" class="featured-products-section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Featured Products</h2>
                <p class="section-subtitle">Handpicked quality products for you</p>
            </div>

            <div class="products-grid">
                <c:choose>
                    <c:when test="${not empty featuredProducts}">
                        <c:forEach var="product" items="${featuredProducts}">
                            <div class="product-card">
                                <div class="product-badge ${product.stockQuantity < 10 ? 'low-stock' : ''}">
                                    ${product.stockQuantity < 10 ? 'Low Stock' : 'In Stock'}
                                </div>
                                <a href="<c:url value='/product/details?productId=${product.productId}'/>" class="product-img-container">
                                    <c:choose>
                                        <c:when test="${not empty product.imagePath}">
                                            <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}" class="product-img">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/assets/images/product-placeholder.jpg" alt="${product.name}" class="product-img">
                                        </c:otherwise>
                                    </c:choose>
                                </a>
                                <div class="product-info">
                                    <a href="<c:url value='/product/details?productId=${product.productId}'/>" class="product-category">${product.category}</a>
                                    <h3 class="product-name">
                                        <a href="<c:url value='/product/details?productId=${product.productId}'/>">${product.name}</a>
                                    </h3>
                                    <div class="product-price">
                                        <span class="current-price">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></span>
                                    </div>
                                    <div class="product-actions">
                                        <button onclick="addToCart('${product.productId}', 1)" class="btn btn-primary btn-add-cart">
                                            <i class="fas fa-cart-plus"></i> Add to Cart
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="no-products-message">
                            <p>No featured products available at the moment. Check back soon!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="view-all-container">
                <a href="<c:url value='/product/list'/>" class="btn btn-outline btn-lg">View All Products</a>
            </div>
        </div>
    </section>

    <!-- Special Offers Section -->
    <section class="special-offers-section">
        <div class="container">
            <div class="special-offers-grid">
                <div class="offer-card offer-large">
                    <div class="offer-content">
                        <h3>Summer Fruits Special</h3>
                        <p>Get 15% off on all fresh fruits</p>
                        <a href="<c:url value='/product/category?category=Fruits'/>" class="btn btn-light">Shop Now</a>
                    </div>
                </div>
                <div class="offer-card offer-small">
                    <div class="offer-content">
                        <h3>Organic Vegetables</h3>
                        <p>Farm fresh and pesticide-free</p>
                        <a href="<c:url value='/product/category?category=Vegetables'/>" class="btn btn-light">Shop Now</a>
                    </div>
                </div>
                <div class="offer-card offer-small">
                    <div class="offer-content">
                        <h3>Dairy Products</h3>
                        <p>Fresh from local farms</p>
                        <a href="<c:url value='/product/category?category=Dairy'/>" class="btn btn-light">Shop Now</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials-section">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">What Our Customers Say</h2>
                <p class="section-subtitle">Don't just take our word for it</p>
            </div>

            <div class="testimonials-slider">
                <div class="testimonial-card">
                    <div class="testimonial-rating">
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                    </div>
                    <p class="testimonial-text">"The quality of fruits and vegetables is exceptional. Everything is fresh and the delivery is always on time!"</p>
                    <div class="testimonial-author">
                        <div class="testimonial-author-avatar"></div>
                        <div class="testimonial-author-info">
                            <h4>Sarah Johnson</h4>
                            <p>Regular Customer</p>
                        </div>
                    </div>
                </div>

                <div class="testimonial-card">
                    <div class="testimonial-rating">
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star-half-alt"></i>
                    </div>
                    <p class="testimonial-text">"I've been ordering my weekly groceries for months now. The variety and quality are unmatched, and the prices are reasonable."</p>
                    <div class="testimonial-author">
                        <div class="testimonial-author-avatar"></div>
                        <div class="testimonial-author-info">
                            <h4>Michael Rodriguez</h4>
                            <p>Loyal Customer</p>
                        </div>
                    </div>
                </div>

                <div class="testimonial-card">
                    <div class="testimonial-rating">
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                    </div>
                    <p class="testimonial-text">"The convenience of having groceries delivered to my doorstep cannot be overstated. The website is easy to use and customer service is excellent!"</p>
                    <div class="testimonial-author">
                        <div class="testimonial-author-avatar"></div>
                        <div class="testimonial-author-info">
                            <h4>Emily Chen</h4>
                            <p>New Customer</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Newsletter Section -->
    <section class="newsletter-section">
        <div class="container">
            <div class="newsletter-content">
                <div class="newsletter-text">
                    <h2>Subscribe to Our Newsletter</h2>
                    <p>Get updates on new products, special offers, and seasonal recipes</p>
                </div>
                <form class="newsletter-form" id="newsletter-form">
                    <div class="form-group">
                        <input type="email" class="form-control" placeholder="Your email address" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Subscribe</button>
                </form>
            </div>
        </div>
    </section>

    <!-- Mobile App Section -->
    <section class="app-section">
        <div class="container">
            <div class="app-content">
                <div class="app-text">
                    <h2>Download Our Mobile App</h2>
                    <p>Shop on the go with our easy-to-use mobile app. Get exclusive app-only offers and track your deliveries in real-time.</p>
                    <div class="app-buttons">
                        <a href="#" class="app-button">
                            <img src="${pageContext.request.contextPath}/assets/images/app-store.png" alt="App Store">
                        </a>
                        <a href="#" class="app-button">
                            <img src="${pageContext.request.contextPath}/assets/images/google-play.png" alt="Google Play">
                        </a>
                    </div>
                </div>
                <div class="app-image">
                    <img src="${pageContext.request.contextPath}/assets/images/mobile-app.png" alt="Mobile App">
                </div>
            </div>
        </div>
    </section>
</main>

<!-- Notification Component -->
<div id="notification-container"></div>

<!-- CSS Styles -->
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
    --shadow-sm: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
    --shadow-md: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    --shadow-lg: 0 1rem 3rem rgba(0, 0, 0, 0.175);
    --border-radius: 0.5rem;
    --transition: all 0.3s ease;
}

/* General Styles */
body {
    font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    color: var(--text-color);
    line-height: 1.6;
    background-color: var(--light-color);
}

.container {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
}

.section-header {
    text-align: center;
    margin-bottom: 3rem;
}

.section-title {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    color: var(--dark-color);
}

.section-subtitle {
    font-size: 1.1rem;
    color: var(--light-text);
    max-width: 700px;
    margin: 0 auto;
}

/* Buttons */
.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.75rem 1.5rem;
    border-radius: var(--border-radius);
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition);
    border: none;
}

.btn-primary {
    background-color: var(--primary-color);
    color: white;
}

.btn-primary:hover {
    background-color: var(--primary-dark);
}

.btn-outline {
    background-color: transparent;
    color: var(--primary-color);
    border: 2px solid var(--primary-color);
}

.btn-outline:hover {
    background-color: var(--primary-color);
    color: white;
}

.btn-light {
    background-color: white;
    color: var(--primary-color);
    box-shadow: var(--shadow-sm);
}

.btn-light:hover {
    background-color: var(--light-color);
    box-shadow: var(--shadow-md);
}

.btn-lg {
    padding: 1rem 2rem;
    font-size: 1.1rem;
}

/* Hero Section */
.hero-parallax {
    height: 80vh;
    min-height: 600px;
    background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('${pageContext.request.contextPath}/assets/images/hero-bg.jpg');
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    display: flex;
    align-items: center;
    color: white;
    position: relative;
}

.hero-content {
    position: relative;
    z-index: 2;
}

.hero-text {
    max-width: 600px;
}

.display-heading {
    font-size: 4rem;
    font-weight: 800;
    line-height: 1.2;
    margin-bottom: 1.5rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.hero-subtitle {
    font-size: 1.3rem;
    margin-bottom: 2rem;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.hero-buttons {
    display: flex;
    gap: 1rem;
}

/* Value Props Section */
.value-props {
    padding: 5rem 0;
    background-color: white;
}

.value-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
}

.value-card {
    text-align: center;
    padding: 2rem;
    border-radius: var(--border-radius);
    transition: var(--transition);
}

.value-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-md);
}

.value-icon {
    font-size: 2.5rem;
    margin-bottom: 1.5rem;
    color: var(--primary-color);
}

.value-card h3 {
    font-size: 1.5rem;
    margin-bottom: 0.5rem;
}

.value-card p {
    color: var(--light-text);
}

/* Categories Section */
.categories-section {
    padding: 5rem 0;
    background-color: var(--light-color);
}

.categories-slider {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 1.5rem;
}

.category-card {
    display: block;
    text-decoration: none;
    color: var(--text-color);
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    transition: var(--transition);
    background-color: white;
}

.category-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-md);
}

.category-img-wrapper {
    height: 200px;
    overflow: hidden;
}

.category-img {
    width: 100%;
    height: 100%;
    background-size: cover;
    background-position: center;
    transition: transform 0.5s ease;
}

.category-card:hover .category-img {
    transform: scale(1.1);
}

.category-name {
    padding: 1rem;
    text-align: center;
    font-size: 1.3rem;
    margin: 0;
}

/* Featured Products Section */
.featured-products-section {
    padding: 5rem 0;
    background-color: white;
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 2rem;
    margin-bottom: 3rem;
}

.product-card {
    background-color: white;
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-sm);
    overflow: hidden;
    transition: var(--transition);
    position: relative;
}

.product-card:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-5px);
}

.product-badge {
    position: absolute;
    top: 1rem;
    left: 1rem;
    padding: 0.25rem 0.75rem;
    border-radius: 50px;
    font-size: 0.8rem;
    font-weight: 600;
    background-color: var(--success-color);
    color: white;
    z-index: 2;
}

.product-badge.low-stock {
    background-color: var(--warning-color);
    color: var(--dark-color);
}

.product-img-container {
    display: block;
    height: 220px;
    overflow: hidden;
}

.product-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
}

.product-card:hover .product-img {
    transform: scale(1.1);
}

.product-info {
    padding: 1.5rem;
}

.product-category {
    display: inline-block;
    font-size: 0.85rem;
    color: var(--light-text);
    margin-bottom: 0.5rem;
    text-decoration: none;
}

.product-name {
    font-size: 1.2rem;
    margin-bottom: 1rem;
}

.product-name a {
    color: var(--dark-color);
    text-decoration: none;
    transition: var(--transition);
}

.product-name a:hover {
    color: var(--primary-color);
}

.product-price {
    display: flex;
    align-items: center;
    margin-bottom: 1rem;
}

.current-price {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--primary-color);
}

.product-actions {
    display: flex;
    gap: 0.5rem;
}

.btn-add-cart {
    width: 100%;
}

.view-all-container {
    text-align: center;
}

.no-products-message {
    grid-column: 1 / -1;
    text-align: center;
    padding: 2rem;
    background-color: var(--light-color);
    border-radius: var(--border-radius);
}

/* Special Offers Section */
.special-offers-section {
    padding: 5rem 0;
    background-color: var(--light-color);
}

.special-offers-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(2, 200px);
    gap: 1.5rem;
}

.offer-card {
    position: relative;
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
}

.offer-large {
    grid-row: span 2;
    background-image: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('${pageContext.request.contextPath}/assets/images/offer-fruits.jpg');
    background-size: cover;
    background-position: center;
}

.offer-small:nth-child(2) {
    background-image: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('${pageContext.request.contextPath}/assets/images/offer-vegetables.jpg');
    background-size: cover;
    background-position: center;
}

.offer-small:nth-child(3) {
    background-image: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('${pageContext.request.contextPath}/assets/images/offer-dairy.jpg');
    background-size: cover;
    background-position: center;
}

.offer-content {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 1.5rem;
    color: white;
    background-image: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
}

.offer-content h3 {
    font-size: 1.5rem;
    margin-bottom: 0.5rem;
}

.offer-content p {
    margin-bottom: 1rem;
}

/* Testimonials Section */
.testimonials-section {
    padding: 5rem 0;
    background-color: white;
}

.testimonials-slider {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 2rem;
}

.testimonial-card {
    padding: 2rem;
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-sm);
    transition: var(--transition);
}

.testimonial-card:hover {
    box-shadow: var(--shadow-md);
}

.testimonial-rating {
    color: var(--warning-color);
    margin-bottom: 1rem;
}

.testimonial-text {
    font-style: italic;
    margin-bottom: 1.5rem;
    color: var(--dark-color);
}

.testimonial-author {
    display: flex;
    align-items: center;
}

.testimonial-author-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background-color: var(--light-color);
    margin-right: 1rem;
}

.testimonial-author-info h4 {
    margin: 0;
    font-size: 1.1rem;
}

.testimonial-author-info p {
    margin: 0;
    color: var(--light-text);
    font-size: 0.9rem;
}

/* Newsletter Section */
.newsletter-section {
    padding: 5rem 0;
    background-color: var(--primary-color);
    color: white;
}

.newsletter-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
}

.newsletter-text h2 {
    font-size: 2rem;
    margin-bottom: 0.5rem;
}

.newsletter-text p {
    opacity: 0.9;
}

.newsletter-form {
    display: flex;
    gap: 1rem;
    flex: 1;
    max-width: 500px;
}

.form-group {
    flex: 1;
}

.form-control {
    width: 100%;
    padding: 1rem;
    border-radius: var(--border-radius);
    border: none;
}

/* App Section */
.app-section {
    padding: 5rem 0;
    background-color: var(--light-color);
}

.app-content {
    display: flex;
    align-items: center;
    gap: 3rem;
}

.app-text {
    flex: 1;
}

.app-text h2 {
    font-size: 2.5rem;
    margin-bottom: 1rem;
}

.app-text p {
    margin-bottom: 2rem;
    color: var(--light-text);
}

.app-buttons {
    display: flex;
    gap: 1rem;
}

.app-button {
    display: block;
}

.app-button img {
    height: 50px;
}

.app-image {
    flex: 1;
    text-align: center;
}

.app-image img {
    max-width: 100%;
    max-height: 400px;
}

/* Notification */
#notification-container {
    position: fixed;
    top: 1rem;
    right: 1rem;
    z-index: 1000;
}

.notification {
    padding: 1rem 1.5rem;
    margin-bottom: 0.5rem;
    border-radius: var(--border-radius);
    display: flex;
    align-items: center;
    gap: 0.5rem;
    box-shadow: var(--shadow-md);
    animation: slideIn 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
}

.notification-success {
    background-color: var(--success-color);
    color: white;
}

.notification-error {
    background-color: var(--danger-color);
    color: white;
}

.notification-info {
    background-color: var(--info-color);
    color: white;
}

@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes fadeOut {
    from {
        opacity: 1;
    }
    to {
        opacity: 0;
    }
}

/* Responsive Styles */
@media (max-width: 992px) {
    .display-heading {
        font-size: 3rem;
    }

    .hero-subtitle {
        font-size: 1.1rem;
    }

    .app-content {
        flex-direction: column;
    }

    .newsletter-content {
        flex-direction: column;
        text-align: center;
    }

    .newsletter-form {
        width: 100%;
        max-width: 100%;
    }

    .special-offers-grid {
        grid-template-columns: 1fr;
        grid-template-rows: repeat(3, 200px);
    }

    .offer-large {
        grid-row: span 1;
    }
}

@media (max-width: 768px) {
    .hero-parallax {
        height: 70vh;
    }

    .display-heading {
        font-size: 2.5rem;
    }

    .section-title {
        font-size: 2rem;
    }

    .products-grid,
    .categories-slider,
    testimonials-slider {
            grid-template-columns: 1fr;
        }

        .newsletter-form {
            flex-direction: column;
        }

        .btn {
            width: 100%;
        }
    }

    @media (max-width: 576px) {
        .display-heading {
            font-size: 2rem;
        }

        .hero-buttons {
            flex-direction: column;
        }

        .value-grid {
            grid-template-columns: 1fr;
        }
    }
    </style>

    <!-- JavaScript -->
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <script>
    // Context path for use in JavaScript
    const contextPath = '${pageContext.request.contextPath}';

    // Function to add products to cart
    function addToCart(productId, quantity) {
        // Check if user is logged in
        const isLoggedIn = ${not empty sessionScope.user};

        if (!isLoggedIn) {
            // Redirect to login page if not logged in
            window.location.href = contextPath + '/views/user/login.jsp';
            return;
        }

        // Make AJAX request to add product to cart
        fetch(`${contextPath}/cart/add`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `productId=${productId}&quantity=${quantity}`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('Product added to your cart', 'success');
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

    // Function to update cart count in the header
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

    // Function to show notification
    function showNotification(message, type) {
        const notificationContainer = document.getElementById('notification-container');

        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;

        // Add icon based on notification type
        let icon = '';
        if (type === 'success') {
            icon = '<i class="fas fa-check-circle"></i>';
        } else if (type === 'error') {
            icon = '<i class="fas fa-exclamation-circle"></i>';
        } else if (type === 'info') {
            icon = '<i class="fas fa-info-circle"></i>';
        }

        // Set notification content
        notification.innerHTML = `${icon} ${message}`;

        // Add notification to container
        notificationContainer.appendChild(notification);

        // Auto remove notification after 3 seconds
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    // Newsletter form submission
    document.addEventListener('DOMContentLoaded', function() {
        const newsletterForm = document.getElementById('newsletter-form');

        if (newsletterForm) {
            newsletterForm.addEventListener('submit', function(e) {
                e.preventDefault();
                const emailInput = this.querySelector('input[type="email"]');
                const email = emailInput.value.trim();

                if (email) {
                    // This would normally send to a backend endpoint
                    emailInput.value = '';
                    showNotification('Thank you for subscribing to our newsletter!', 'success');
                }
            });
        }

        // Initialize category slider if needed
        // This is a placeholder for slider functionality
        // In a real implementation, you might use a library like Swiper or Slick

        // Initialize testimonials slider if needed
        // This is a placeholder for slider functionality
    });
    </script>

    <jsp:include page="/views/common/footer.jsp" />