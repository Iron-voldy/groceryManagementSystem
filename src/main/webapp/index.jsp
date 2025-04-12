<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Home" />
    <jsp:param name="active" value="home" />
</jsp:include>

<!-- Hero Banner -->
<section class="hero-banner">
    <div class="hero-content">
        <h1>Fresh Groceries Delivered to Your Door</h1>
        <p>Shop for the finest selection of fresh produce, pantry essentials, and household items.</p>
        <a href="${pageContext.request.contextPath}/product/list" class="btn btn-lg">Shop Now</a>
    </div>
</section>

<!-- Featured Categories -->
<section class="section">
    <h2 class="section-title">Shop by Category</h2>
    <div class="categories-grid">
        <a href="${pageContext.request.contextPath}/product/category?category=Fresh+Products" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥩</div>
            <h3>Fresh Products</h3>
        </a>
        <a href="${pageContext.request.contextPath}/product/category?category=Dairy" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥛</div>
            <h3>Dairy</h3>
        </a>
        <a href="${pageContext.request.contextPath}/product/category?category=Vegetables" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥦</div>
            <h3>Vegetables</h3>
        </a>
        <a href="${pageContext.request.contextPath}/product/category?category=Fruits" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🍎</div>
            <h3>Fruits</h3>
        </a>
        <a href="${pageContext.request.contextPath}/product/category?category=Pantry+Items" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥫</div>
            <h3>Pantry Items</h3>
        </a>
    </div>
</section>

<!-- Featured Products -->
<section class="section">
    <h2 class="section-title">Featured Products</h2>
    <div class="grid">
        <c:forEach var="product" items="${featuredProducts}" varStatus="status">
            <div class="product-card">
                <div class="product-img">🛒</div>
                <div class="product-details">
                    <h3 class="product-title">${product.name}</h3>
                    <div class="product-category">${product.category}</div>
                    <div class="product-price">$${product.price}</div>
                    <p class="product-description">${product.description.length() > 80 ? product.description.substring(0, 80).concat('...') : product.description}</p>
                    <div class="product-actions">
                        <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="btn btn-sm">View</a>
                        <button onclick="addToCart('${product.productId}')" class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>
        </c:forEach>

        <!-- If no featured products, show placeholders -->
        <c:if test="${empty featuredProducts}">
            <!-- Product 1 -->
            <div class="product-card">
                <div class="product-img">🍎</div>
                <div class="product-details">
                    <h3 class="product-title">Fresh Organic Apples</h3>
                    <div class="product-category">Fruits</div>
                    <div class="product-price">$2.99</div>
                    <p class="product-description">Sweet and juicy organic apples, perfect for healthy snacking.</p>
                    <div class="product-actions">
                        <a href="#" class="btn btn-sm">View</a>
                        <button class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>

            <!-- Product 2 -->
            <div class="product-card">
                <div class="product-img">🥛</div>
                <div class="product-details">
                    <h3 class="product-title">Organic Whole Milk</h3>
                    <div class="product-category">Dairy</div>
                    <div class="product-price">$3.49</div>
                    <p class="product-description">Farm-fresh organic whole milk, rich in calcium and nutrients.</p>
                    <div class="product-actions">
                        <a href="#" class="btn btn-sm">View</a>
                        <button class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>

            <!-- Product 3 -->
            <div class="product-card">
                <div class="product-img">🥦</div>
                <div class="product-details">
                    <h3 class="product-title">Fresh Broccoli</h3>
                    <div class="product-category">Vegetables</div>
                    <div class="product-price">$1.99</div>
                    <p class="product-description">Fresh and crunchy broccoli, packed with vitamins and minerals.</p>
                    <div class="product-actions">
                        <a href="#" class="btn btn-sm">View</a>
                        <button class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>

            <!-- Product 4 -->
            <div class="product-card">
                <div class="product-img">🍞</div>
                <div class="product-details">
                    <h3 class="product-title">Whole Grain Bread</h3>
                    <div class="product-category">Pantry Items</div>
                    <div class="product-price">$2.79</div>
                    <p class="product-description">Freshly baked whole grain bread, nutritious and delicious.</p>
                    <div class="product-actions">
                        <a href="#" class="btn btn-sm">View</a>
                        <button class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>
        </c:if>
    </div>

    <div class="view-all-button">
        <a href="${pageContext.request.contextPath}/product/list" class="btn">View All Products</a>
    </div>
</section>

<!-- Why Choose Us -->
<section class="section why-choose-us">
    <h2 class="section-title">Why Choose Us</h2>
    <div class="features-grid">
        <div class="feature-card">
            <div class="feature-icon">🚚</div>
            <h3>Fast Delivery</h3>
            <p>Get your groceries delivered to your doorstep within hours of ordering.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">🌱</div>
            <h3>Fresh Produce</h3>
            <p>We source our products directly from local farmers for maximum freshness.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">💰</div>
            <h3>Best Prices</h3>
            <p>Competitive prices and regular deals to help you save on your grocery bills.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">🔄</div>
            <h3>Easy Returns</h3>
            <p>Not satisfied? We offer hassle-free returns and refunds.</p>
        </div>
    </div>
</section>

<!-- Customer Testimonials -->
<section class="section testimonials">
    <h2 class="section-title">What Our Customers Say</h2>
    <div class="testimonials-grid">
        <div class="testimonial-card">
            <div class="testimonial-text">
                "I've been shopping with GroceryShop for over a year now, and I'm consistently impressed by the quality of their products and service."
            </div>
            <div class="testimonial-author">- Sarah Johnson</div>
            <div class="testimonial-rating">★★★★★</div>
        </div>
        <div class="testimonial-card">
            <div class="testimonial-text">
                "Their delivery is always on time, and the produce is so fresh. It's like having a farmers market delivered to my door!"
            </div>
            <div class="testimonial-author">- Michael Chen</div>
            <div class="testimonial-rating">★★★★★</div>
        </div>
        <div class="testimonial-card">
            <div class="testimonial-text">
                "The customer service is exceptional. I had an issue with an order once, and they resolved it immediately and gave me a discount on my next purchase."
            </div>
            <div class="testimonial-author">- Emily Rodriguez</div>
            <div class="testimonial-rating">★★★★☆</div>
        </div>
    </div>
</section>

<!-- Call to Action -->
<section class="section cta-section">
    <div class="cta-content">
        <h2>Ready to Start Shopping?</h2>
        <p>Join thousands of satisfied customers and experience the convenience of online grocery shopping.</p>
        <a href="${pageContext.request.contextPath}/product/list" class="btn btn-lg">Shop Now</a>
    </div>
</section>

<style>
/* Additional styles specific to home page */
.hero-banner {
    background-color: #2c3e50;
    padding: 80px 20px;
    text-align: center;
    margin-bottom: 40px;
    border-radius: var(--border-radius);
}

.hero-content {
    max-width: 800px;
    margin: 0 auto;
}

.hero-content h1 {
    font-size: 2.5rem;
    margin-bottom: 20px;
    color: var(--primary);
}

.hero-content p {
    font-size: 1.2rem;
    margin-bottom: 30px;
    color: var(--dark-text);
}

.section {
    margin-bottom: 60px;
}

.section-title {
    text-align: center;
    margin-bottom: 30px;
    font-size: 2rem;
    color: var(--dark-text);
}

.categories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 20px;
}

.category-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    text-align: center;
    transition: var(--transition);
    box-shadow: var(--card-shadow);
}

.category-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
}

.category-img {
    height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 3rem;
}

.category-card h3 {
    padding: 15px;
    margin: 0;
    background-color: var(--darker-bg);
    color: var(--dark-text);
}

.view-all-button {
    text-align: center;
    margin-top: 30px;
}

.features-grid, .testimonials-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 30px;
}

.feature-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 30px;
    text-align: center;
    box-shadow: var(--card-shadow);
    transition: var(--transition);
}

.feature-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
}

.feature-icon {
    font-size: 3rem;
    margin-bottom: 15px;
}

.feature-card h3 {
    margin-bottom: 15px;
    font-size: 1.5rem;
}

.testimonial-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
}

.testimonial-text {
    font-style: italic;
    margin-bottom: 15px;
}

.testimonial-author {
    font-weight: 600;
    margin-bottom: 10px;
}

.testimonial-rating {
    color: var(--secondary);
}

.cta-section {
    background-color: var(--primary);
    padding: 60px 20px;
    text-align: center;
    border-radius: var(--border-radius);
}

.cta-content {
    max-width: 700px;
    margin: 0 auto;
}

.cta-content h2 {
    font-size: 2rem;
    margin-bottom: 20px;
    color: white;
}

.cta-content p {
    font-size: 1.1rem;
    margin-bottom: 30px;
    color: rgba(255, 255, 255, 0.9);
}

.cta-content .btn {
    background-color: white;
    color: var(--primary);
}

.cta-content .btn:hover {
    background-color: rgba(255, 255, 255, 0.9);
}

@media (max-width: 768px) {
    .hero-content h1 {
        font-size: 2rem;
    }

    .feature-card, .testimonial-card {
        padding: 20px;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />