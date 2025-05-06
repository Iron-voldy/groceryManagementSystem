<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="${product.name}" />
    <jsp:param name="active" value="products" />
</jsp:include>

<!-- Main container -->
<div class="container">
    <!-- Breadcrumb Navigation -->
    <nav class="product-navigation">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/product/list">Products</a></li>
            <c:if test="${not empty product.category}">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/product/category?category=${product.category}">${product.category}</a></li>
            </c:if>
            <li class="breadcrumb-item active">${product.name}</li>
        </ol>
    </nav>

    <!-- Product Detail Card -->
    <div class="product-detail-container">
        <div class="product-detail-left">
            <div class="product-image">
                <c:choose>
                    <c:when test="${not empty product.imagePath}">
                        <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}" class="product-img">
                    </c:when>
                    <c:otherwise>
                        <!-- Product image placeholder -->
                        <div class="product-image-placeholder">
                            <img src="${pageContext.request.contextPath}/assets/images/product-placeholder.jpg" alt="${product.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png';">
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="product-detail-right">
            <h1 class="product-title">${product.name}</h1>

            <div class="product-meta">
                <span class="product-category">${product.category}</span>
                <c:if test="${not empty averageRating}">
                    <div class="product-rating">
                        <div class="rating-stars">
                            <c:forEach begin="1" end="5" var="star">
                                <span class="star ${star <= averageRating ? 'filled' : ''}">★</span>
                            </c:forEach>
                        </div>
                        <span class="rating-value">${averageRating}/5</span>
                        <span class="review-count">(${reviews.size()} reviews)</span>
                    </div>
                </c:if>
            </div>

            <div class="product-price">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></div>

            <div class="product-availability">
                <span class="availability-label">Availability:</span>
                <span class="stock-info ${product.stockQuantity > 10 ? 'in-stock' : product.stockQuantity > 0 ? 'low-stock' : 'out-of-stock'}">
                    ${product.stockQuantity > 10 ? 'In Stock' : product.stockQuantity > 0 ? 'Low Stock ('.concat(product.stockQuantity).concat(' left)') : 'Out of Stock'}
                </span>
            </div>

            <div class="product-description">
                <h3>Description</h3>
                <p>${product.description}</p>
            </div>

            <input type="hidden" id="product-id" value="${product.productId}">

            <%-- Replace the existing add-to-cart form with this version --%>
            <c:if test="${product.stockQuantity > 0}">
                <form class="add-to-cart-form" id="add-to-cart-form">
                    <div class="quantity-selector">
                        <label for="quantity">Quantity</label>
                        <div class="quantity-control">
                            <button type="button" class="decrement" aria-label="Decrease quantity">-</button>
                            <input type="number" id="quantity" class="quantity-input" value="1" min="1" max="${product.stockQuantity}">
                            <button type="button" class="increment" aria-label="Increase quantity">+</button>
                        </div>
                    </div>

                    <div class="product-actions">
                        <button type="submit" class="btn btn-primary add-to-cart-btn">
                            <i class="fas fa-cart-plus"></i> Add to Cart
                        </button>
                    </div>
                </form>
            </c:if>
        </div>
    </div>

    <!-- Product Tabs -->
    <div class="product-tabs">
        <ul class="nav-tabs">
            <li class="nav-item">
                <a class="nav-link active" data-toggle="tab" href="#reviews-tab">Reviews</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-toggle="tab" href="#related-tab">Related Products</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-toggle="tab" href="#shipping-tab">Shipping Info</a>
            </li>
        </ul>

        <div class="tab-content">
            <!-- Reviews Tab -->
            <div class="tab-pane fade show active" id="reviews-tab">
                <div class="reviews-section">
                    <div class="reviews-header">
                        <h2>Customer Reviews</h2>
                        <a href="${pageContext.request.contextPath}/review/submit?productId=${product.productId}" class="btn btn-write-review">
                            Write a Review
                        </a>
                    </div>

                    <div class="review-summary">
                        <div class="rating-average">
                            <div class="big-rating">
                                <c:choose>
                                    <c:when test="${empty averageRating}">0.0</c:when>
                                    <c:otherwise><fmt:formatNumber value="${averageRating}" pattern="#.#"/></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="rating-stars large">
                                <c:forEach begin="1" end="5" var="star">
                                    <span class="star ${not empty averageRating && star <= averageRating ? 'filled' : ''}">★</span>
                                </c:forEach>
                            </div>
                            <div class="review-count">Based on ${reviews.size()} reviews</div>
                        </div>

                        <div class="rating-breakdown">
                            <c:set var="ratings" value="${{5:0, 4:0, 3:0, 2:0, 1:0}}" />
                            <c:forEach var="review" items="${reviews}">
                                <c:set target="${ratings}" property="${review.rating}" value="${ratings[review.rating] + 1}" />
                            </c:forEach>

                            <c:forEach var="rating" items="5,4,3,2,1">
                                <div class="rating-bar">
                                    <span class="rating-label">${rating} Stars</span>
                                    <div class="progress-bar">
                                        <div class="progress" style="width: ${reviews.size() > 0 ? (ratings[rating] / reviews.size() * 100) : 0}%"></div>
                                    </div>
                                    <span class="rating-count">${ratings[rating]}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Reviews List -->
                    <div class="reviews-list">
                        <c:choose>
                            <c:when test="${not empty reviews}">
                                <c:forEach var="review" items="${reviews}">
                                    <div class="review-card">
                                        <div class="review-header">
                                            <div class="reviewer-profile">
                                                <div class="avatar">${fn:substring(review.userId, 0, 1).toUpperCase()}</div>
                                                <div class="reviewer-info">
                                                    <span class="reviewer-name">${review.userId}</span>
                                                    <span class="review-date">
                                                        <!-- Format date as string to avoid date conversion issues -->
                                                        ${fn:substring(review.reviewDate, 0, 10)}
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="review-rating">
                                                <c:forEach begin="1" end="5" var="star">
                                                    <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                                                </c:forEach>
                                            </div>
                                        </div>
                                        <div class="review-content">
                                            <p>${review.reviewText}</p>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="no-reviews">
                                    <div class="no-reviews-icon">
                                        <i class="fas fa-comment-alt"></i>
                                    </div>
                                    <h3>No Reviews Yet</h3>
                                    <p>Be the first to review this product!</p>
                                    <a href="${pageContext.request.contextPath}/review/submit?productId=${product.productId}" class="btn btn-primary">Write a Review</a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Related Products Tab -->
            <div class="tab-pane fade" id="related-tab">
                <div class="related-products-section">
                    <h2>You Might Also Like</h2>

                    <div class="related-products-grid">
                        <c:forEach var="relatedProduct" items="${relatedProducts}" varStatus="status" end="3">
                            <div class="related-product-card">
                                <div class="product-img">
                                    <a href="${pageContext.request.contextPath}/product/details?productId=${relatedProduct.productId}">
                                    <c:choose>
                                        <c:when test="${not empty relatedProduct.imagePath}">
                                            <img src="${pageContext.request.contextPath}${relatedProduct.imagePath}" alt="${relatedProduct.name}" class="product-img">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="product-img-placeholder">
                                                <img src="${pageContext.request.contextPath}/assets/images/product-placeholder.jpg" alt="${relatedProduct.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png';">
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    </a>
                                </div>
                                <div class="product-details">
                                    <a href="${pageContext.request.contextPath}/product/details?productId=${relatedProduct.productId}" class="product-title">${relatedProduct.name}</a>
                                    <div class="product-category">${relatedProduct.category}</div>
                                    <div class="product-price">$<fmt:formatNumber value="${relatedProduct.price}" pattern="#,##0.00"/></div>
                                    <div class="product-actions">
                                        <button class="btn btn-primary add-related-product"
                                                data-product-id="${relatedProduct.productId}"
                                                ${relatedProduct.stockQuantity <= 0 ? 'disabled' : ''}>
                                            Add to Cart
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- Shipping Info Tab -->
            <div class="tab-pane fade" id="shipping-tab">
                <div class="shipping-info">
                    <h2>Shipping & Delivery Information</h2>

                    <div class="shipping-card">
                        <div class="shipping-icon">
                            <i class="fas fa-truck"></i>
                        </div>
                        <div class="shipping-details">
                            <h3>Free Standard Shipping</h3>
                            <p>On all orders over $50</p>
                            <p>Delivery in 3-5 business days</p>
                        </div>
                    </div>

                    <div class="shipping-card">
                        <div class="shipping-icon">
                            <i class="fas fa-shipping-fast"></i>
                        </div>
                        <div class="shipping-details">
                            <h3>Express Delivery</h3>
                            <p>$10.99 flat rate</p>
                            <p>Delivery in 1-2 business days</p>
                        </div>
                    </div>

                    <div class="shipping-card">
                        <div class="shipping-icon">
                            <i class="fas fa-box-open"></i>
                        </div>
                        <div class="shipping-details">
                            <h3>Return Policy</h3>
                            <p>Easy returns within 30 days</p>
                            <p>See our <a href="#">Return Policy</a> for details</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Notification container -->
<div id="notification-container"></div>

<style>
/* Container and Global Styles */
.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

/* Breadcrumb Navigation */
.breadcrumb {
    display: flex;
    list-style: none;
    padding: 10px 0;
    margin: 0 0 20px 0;
    background: transparent;
}

.breadcrumb-item {
    display: inline-block;
}

.breadcrumb-item a {
    color: #4CAF50;
    text-decoration: none;
}

.breadcrumb-item:not(:first-child):before {
    content: '/';
    margin: 0 10px;
    color: #999;
}

.breadcrumb-item.active {
    color: #999;
}

/* Product Detail Container */
.product-detail-container {
    display: flex;
    flex-wrap: wrap;
    margin-bottom: 40px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    overflow: hidden;
}

.product-detail-left {
    flex: 1;
    min-width: 300px;
}

.product-image {
    height: 400px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f8f9fa;
    padding: 20px;
}

.product-img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.product-image-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.product-image-placeholder img {
    max-width: 80%;
    max-height: 80%;
    opacity: 0.5;
}

.product-detail-right {
    flex: 1;
    min-width: 300px;
    padding: 30px;
}

.product-title {
    font-size: 28px;
    margin-bottom: 15px;
    color: #333;
}

.product-meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    margin-bottom: 20px;
}

.product-category {
    display: inline-block;
    padding: 5px 10px;
    background-color: #f0f0f0;
    border-radius: 20px;
    font-size: 14px;
    color: #666;
}

.product-rating {
    display: flex;
    align-items: center;
}

.rating-stars {
    color: #FFC107;
    margin-right: 5px;
    font-size: 18px;
}

.star {
    color: #DDD;
}

.star.filled {
    color: #FFC107;
}

.rating-value, .review-count {
    color: #666;
    font-size: 14px;
}

.product-price {
    font-size: 28px;
    font-weight: 600;
    color: #4CAF50;
    margin-bottom: 20px;
}

.product-availability {
    margin-bottom: 20px;
}

.availability-label {
    color: #666;
    margin-right: 5px;
}

.stock-info {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 14px;
}

.in-stock {
    background-color: rgba(76, 175, 80, 0.1);
    color: #4CAF50;
}

.low-stock {
    background-color: rgba(255, 152, 0, 0.1);
    color: #FF9800;
}

.out-of-stock {
    background-color: rgba(244, 67, 54, 0.1);
    color: #F44336;
}

.product-description {
    margin-bottom: 30px;
}

.product-description h3 {
    margin-bottom: 10px;
    font-size: 18px;
    color: #333;
}

.product-description p {
    color: #666;
    line-height: 1.6;
}

/* Add to Cart Form */
.add-to-cart-form {
    margin-top: 20px;
}

.quantity-selector {
    margin-bottom: 20px;
}

.quantity-selector label {
    display: block;
    margin-bottom: 10px;
    font-weight: 500;
}

.quantity-control {
    display: flex;
    align-items: center;
    max-width: 150px;
    border: 1px solid #ddd;
    border-radius: 4px;
    overflow: hidden;
}

.quantity-control button {
    width: 40px;
    height: 40px;
    background-color: #f0f0f0;
    border: none;
    color: #333;
    font-size: 18px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.quantity-control button:hover {
    background-color: #4CAF50;
    color: white;
}

.quantity-input {
    flex: 1;
    height: 40px;
    text-align: center;
    border: none;
    border-left: 1px solid #ddd;
    border-right: 1px solid #ddd;
    font-size: 16px;
}

.product-actions {
    display: flex;
    gap: 15px;
}

.add-to-cart-btn {
    flex: 1;
    height: 50px;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.add-to-cart-btn:hover {
    background-color: #388E3C;
}

/* Tabs Styling */
.product-tabs {
    margin-bottom: 60px;
}

.nav-tabs {
    display: flex;
    list-style: none;
    padding: 0;
    margin: 0 0 20px 0;
    border-bottom: 1px solid #ddd;
}

.nav-item {
    margin-right: 5px;
}

.nav-link {
    display: block;
    padding: 10px 20px;
    border: 1px solid transparent;
    border-bottom: none;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
    color: #666;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
}

.nav-link:hover {
    color: #4CAF50;
}

.nav-link.active {
    color: #4CAF50;
    border-color: #ddd;
    border-bottom-color: white;
    background-color: white;
}

.tab-content {
    background-color: white;
    border: 1px solid #ddd;
    border-top: none;
    border-radius: 0 0 4px 4px;
    padding: 20px;
}

.tab-pane {
    display: none;
}

.tab-pane.show {
    display: block;
}

.fade {
    transition: opacity 0.15s linear;
}

.fade.show {
    opacity: 1;
}

/* Reviews Section Styling */
.reviews-section {
    padding: 20px;
}

.reviews-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.btn-write-review {
    padding: 8px 16px;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
}

.btn-write-review:hover {
    background-color: #388E3C;
}

.review-summary {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    margin-bottom: 30px;
    padding: 20px;
    background-color: #f8f9fa;
    border-radius: 8px;
}

.rating-average {
    flex: 1;
    min-width: 200px;
    text-align: center;
}

.big-rating {
    font-size: 48px;
    font-weight: 700;
    color: #4CAF50;
    margin-bottom: 10px;
}

.rating-stars.large {
    font-size: 24px;
    margin-bottom: 10px;
}

.rating-breakdown {
    flex: 2;
    min-width: 300px;
}

.rating-bar {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.rating-label {
    flex: 1;
    min-width: 80px;
}

.progress-bar {
    flex: 3;
    height: 10px;
    background-color: #e9ecef;
    border-radius: 5px;
    overflow: hidden;
    margin: 0 15px;
}

.progress {
    height: 100%;
    background-color: #4CAF50;
}

.rating-count {
    flex: 0;
    min-width: 30px;
    text-align: right;
}

.reviews-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.review-card {
    padding: 20px;
    background-color: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.review-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
}

.reviewer-profile {
    display: flex;
    align-items: center;
}

.avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: #4CAF50;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 18px;
    margin-right: 10px;
}

.reviewer-info {
    display: flex;
    flex-direction: column;
}

.reviewer-name {
    font-weight: 600;
    margin-bottom: 3px;
}

.review-date {
    color: #999;
    font-size: 12px;
}

.review-content p {
    color: #666;
    line-height: 1.6;
}

.no-reviews {
    text-align: center;
    padding: 40px 20px;
    background-color: #f8f9fa;
    border-radius: 8px;
}

.no-reviews-icon {
    font-size: 36px;
    color: #ddd;
    margin-bottom: 10px;
}

.no-reviews h3 {
    margin-bottom: 10px;
    color: #666;
}

.no-reviews p {
    margin-bottom: 20px;
    color: #999;
}

/* Related Products Styling */
.related-products-section {
    padding: 20px;
}

.related-products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
}

.related-product-card {
    border: 1px solid #ddd;
    border-radius: 8px;
    overflow: hidden;
    transition: all 0.3s ease;
}

.related-product-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.related-product-card .product-img {
    height: 200px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f8f9fa;
    padding: 10px;
}

.related-product-card .product-img img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.related-product-card .product-details {
    padding: 15px;
}

.related-product-card .product-title {
    font-size: 16px;
    margin-bottom: 5px;
    color: #333;
    text-decoration: none;
    display: block;
}

.related-product-card .product-title:hover {
    color: #4CAF50;
}

.related-product-card .product-category {
    font-size: 12px;
    margin-bottom: 10px;
    display: inline-block;
    padding: 3px 8px;
    background-color: #f0f0f0;
    border-radius: 20px;
    color: #666;
}

.related-product-card .product-price {
    font-size: 18px;
    font-weight: 600;
    color: #4CAF50;
    margin-bottom: 15px;
}

.related-product-card .product-actions {
    display: flex;
}

.related-product-card .btn {
    flex: 1;
    padding: 8px 0;
    border: none;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: center;
}

.related-product-card .btn-primary {
    background-color: #4CAF50;
    color: white;
}

.related-product-card .btn-primary:hover {
    background-color: #388E3C;
}

.related-product-card .btn:disabled {
    background-color: #ddd;
    cursor: not-allowed;
}

/* Shipping Info Styling */
.shipping-info {
    padding: 20px;
}

.shipping-card {
    display: flex;
    align-items: center;
    padding: 20px;
    margin-bottom: 20px;
    background-color: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #4CAF50;
}

.shipping-icon {
    font-size: 30px;
    color: #4CAF50;
    margin-right: 20px;
}

.shipping-details h3 {
    margin-bottom: 5px;
    color: #333;
}

.shipping-details p {
    margin: 0 0 5px 0;
    color: #666;
}

/* Notification Styling */
#notification-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 1000;
}

.notification {
    background-color: #4CAF50;
    color: white;
    padding: 12px 20px;
    margin-bottom: 10px;
    border-radius: 4px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    min-width: 250px;
    opacity: 0;
    transform: translateX(100%);
    transition: all 0.3s ease;
}

.notification.show {
    opacity: 1;
    transform: translateX(0);
}

.notification-error {
    background-color: #F44336;
}

/* Responsive Styles */
@media (max-width: 768px) {
    .product-detail-container {
        flex-direction: column;
    }

    .product-image {
        height: 300px;
    }

    .review-summary {
        flex-direction: column;
    }

    .reviews-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
    }

    .nav-tabs {
        flex-wrap: wrap;
    }

.nav-item {
        flex: 1;
        min-width: 120px;
        margin-bottom: 5px;
    }

    .nav-link {
        text-align: center;
    }

    .review-header {
        flex-direction: column;
        gap: 10px;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    console.log("DOM fully loaded");

    // Debug output of product ID
    const productIdField = document.getElementById('product-id');
    if (productIdField) {
        console.log("Product ID from hidden field:", productIdField.value);
    }

    // Add event listener to the form
    const addToCartForm = document.getElementById('add-to-cart-form');
    if (addToCartForm) {
        addToCartForm.addEventListener('submit', function(event) {
            event.preventDefault();
            const productId = document.getElementById('product-id').value;
            const quantity = document.getElementById('quantity').value;
            console.log("Form submitted, Product ID:", productId, "Quantity:", quantity);
            addToCart(productId, quantity);
        });
    }

    // Add event listeners to related product buttons
    const relatedButtons = document.querySelectorAll('.add-related-product');
    relatedButtons.forEach(button => {
        button.addEventListener('click', function(event) {
            const productId = this.getAttribute('data-product-id');
            console.log("Related product button clicked, Product ID:", productId);
            addToCart(productId, 1);
        });
    });

    // Quantity controls
    const decrementBtn = document.querySelector('.decrement');
    const incrementBtn = document.querySelector('.increment');
    const quantityInput = document.querySelector('.quantity-input');

    if (decrementBtn && incrementBtn && quantityInput) {
        decrementBtn.addEventListener('click', function() {
            let value = parseInt(quantityInput.value);
            if (value > 1) {
                quantityInput.value = value - 1;
            }
        });

        incrementBtn.addEventListener('click', function() {
            let value = parseInt(quantityInput.value);
            let max = parseInt(quantityInput.getAttribute('max'));
            if (value < max) {
                quantityInput.value = value + 1;
            }
        });
    }

    // Tab navigation
    const tabLinks = document.querySelectorAll('.nav-link');
    const tabPanes = document.querySelectorAll('.tab-pane');

    if (tabLinks.length > 0) {
        tabLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();

                // Remove active class from all links and panes
                tabLinks.forEach(l => l.classList.remove('active'));
                tabPanes.forEach(p => {
                    p.classList.remove('show');
                    p.classList.remove('active');
                });

                // Add active class to clicked link
                this.classList.add('active');

                // Get target pane and show it
                const targetId = this.getAttribute('href');
                const targetPane = document.querySelector(targetId);
                if (targetPane) {
                    targetPane.classList.add('show');
                    targetPane.classList.add('active');
                }
            });
        });
    }
});

// Function to add to cart
function addToCart(productId, quantity = 1) {
    console.log("Adding to cart: Product ID=" + productId + ", Quantity=" + quantity);

    // Validate product ID
    if (!productId || productId.trim() === '') {
        console.error("Invalid product ID: Empty or missing");
        showNotification('Invalid product ID', 'error');
        return;
    }

    // Validate quantity
    if (!quantity || isNaN(quantity) || quantity <= 0) {
        console.error("Invalid quantity:", quantity);
        showNotification('Please enter a valid quantity', 'error');
        return;
    }

    // Properly encode the parameters
    const params = new URLSearchParams();
    params.append('productId', productId);
    params.append('quantity', quantity);

    fetch(`${pageContext.request.contextPath}/cart/add`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log("Server response:", JSON.stringify(data, null, 2));
        if (data.success) {
            showNotification('Product added to cart successfully');
            const cartCountElements = document.querySelectorAll('.cart-count');
            cartCountElements.forEach(element => {
                element.textContent = data.cartItemCount;
                element.classList.add('has-items');
            });
        } else {
            showNotification(data.message || 'Failed to add product to cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error adding to cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Function to show notification
function showNotification(message, type = 'success') {
    // Create notification container if it doesn't exist
    let container = document.getElementById('notification-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'notification-container';
        container.style.position = 'fixed';
        container.style.top = '20px';
        container.style.right = '20px';
        container.style.zIndex = '1000';
        document.body.appendChild(container);
    }

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    // Add notification to container
    container.appendChild(notification);

    // Show notification with animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);

    // Remove notification after delay
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}
// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM fully loaded - initializing product page features');

    // Quantity controls
    const decrementBtn = document.querySelector('.decrement');
    const incrementBtn = document.querySelector('.increment');
    const quantityInput = document.querySelector('.quantity-input');

    if (decrementBtn && incrementBtn && quantityInput) {
        decrementBtn.addEventListener('click', function() {
            let value = parseInt(quantityInput.value);
            if (value > 1) {
                quantityInput.value = value - 1;
            }
        });

        incrementBtn.addEventListener('click', function() {
            let value = parseInt(quantityInput.value);
            let max = parseInt(quantityInput.getAttribute('max'));
            if (value < max) {
                quantityInput.value = value + 1;
            }
        });
    }

    // Tab navigation
    const tabLinks = document.querySelectorAll('.nav-link');
    const tabPanes = document.querySelectorAll('.tab-pane');

    if (tabLinks.length > 0) {
        tabLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();

                // Remove active class from all links and panes
                tabLinks.forEach(l => l.classList.remove('active'));
                tabPanes.forEach(p => {
                    p.classList.remove('show');
                    p.classList.remove('active');
                });

                // Add active class to clicked link
                this.classList.add('active');

                // Get target pane and show it
                const targetId = this.getAttribute('href');
                const targetPane = document.querySelector(targetId);
                if (targetPane) {
                    targetPane.classList.add('show');
                    targetPane.classList.add('active');
                }
            });
        });
    }
});
</script>

<jsp:include page="/views/common/footer.jsp">
    <jsp:param name="scripts" value="main" />
</jsp:include>