<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="${product.name}" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="product-navigation">
    <a href="${pageContext.request.contextPath}/product/list" class="back-link">
        ← Back to Products
    </a>
</div>

<div class="product-detail-container">
    <div class="product-detail-left">
        <div class="product-image">
            <!-- Product image placeholder -->
            <div class="product-image-placeholder">
                <c:choose>
                    <c:when test="${product.category == 'Fresh Products'}">🥩</c:when>
                    <c:when test="${product.category == 'Dairy'}">🥛</c:when>
                    <c:when test="${product.category == 'Vegetables'}">🥦</c:when>
                    <c:when test="${product.category == 'Fruits'}">🍎</c:when>
                    <c:when test="${product.category == 'Pantry Items'}">🥫</c:when>
                    <c:otherwise>🛒</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="product-detail-right">
        <h1 class="product-title">${product.name}</h1>

        <div class="product-meta">
            <span class="product-category">${product.category}</span>
            <c:if test="${not empty averageRating}">
                <div class="product-rating">
                    <span class="rating-stars">
                        <c:forEach begin="1" end="5" var="star">
                            <span class="star ${star <= averageRating ? 'filled' : ''}">★</span>
                        </c:forEach>
                    </span>
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

        <c:if test="${product.stockQuantity > 0}">
            <form class="add-to-cart-form" onsubmit="event.preventDefault(); addToCartWithQuantity('${product.productId}');">
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
                        Add to Cart
                    </button>
                </div>
            </form>
        </c:if>
    </div>
</div>

<!-- Product Reviews Section -->
<div class="product-reviews-section">
    <h2>Customer Reviews</h2>

    <div class="review-summary">
        <div class="rating-average">
            <div class="big-rating">
                <c:choose>
                    <c:when test="${empty averageRating}">0.0</c:when>
                    <c:otherwise>${averageRating}</c:otherwise>
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

            <c:forEach begin="5" end="1" step="-1" var="rating">
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

    <div class="review-actions">
        <a href="${pageContext.request.contextPath}/review/submit?productId=${product.productId}" class="btn">Write a Review</a>
    </div>

    <div class="reviews-list">
        <c:choose>
            <c:when test="${not empty reviews}">
                <c:forEach var="review" items="${reviews}">
                    <div class="review-card">
                        <div class="review-header">
                            <div class="review-info">
                                <span class="reviewer-name">${review.userId}</span>
                                <span class="review-date">
                                    <fmt:formatDate value="${review.reviewDate}" pattern="MMM d, yyyy" />
                                </span>
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
                    <p>There are no reviews yet. Be the first to review this product!</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Related Products Section -->
<div class="related-products-section">
    <h2>You Might Also Like</h2>

    <div class="related-products-grid">
        <c:forEach var="relatedProduct" items="${relatedProducts}" varStatus="status" end="3">
            <div class="product-card">
                <div class="product-img">
                    <div class="product-img-placeholder">
                        <c:choose>
                            <c:when test="${relatedProduct.category == 'Fresh Products'}">🥩</c:when>
                            <c:when test="${relatedProduct.category == 'Dairy'}">🥛</c:when>
                            <c:when test="${relatedProduct.category == 'Vegetables'}">🥦</c:when>
                            <c:when test="${relatedProduct.category == 'Fruits'}">🍎</c:when>
                            <c:when test="${relatedProduct.category == 'Pantry Items'}">🥫</c:when>
                            <c:otherwise>🛒</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="product-details">
                    <h3 class="product-title">${relatedProduct.name}</h3>
                    <div class="product-category">${relatedProduct.category}</div>
                    <div class="product-price">$<fmt:formatNumber value="${relatedProduct.price}" pattern="#,##0.00"/></div>
                    <div class="product-actions">
                        <a href="${pageContext.request.contextPath}/product/details?productId=${relatedProduct.productId}" class="btn btn-sm">View</a>
                        <button onclick="addToCart('${relatedProduct.productId}')"
                                class="btn btn-sm btn-secondary"
                                ${relatedProduct.stockQuantity <= 0 ? 'disabled' : ''}>
                            Add to Cart
                        </button>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

<style>
.product-navigation {
    margin-bottom: 20px;
}

.back-link {
    display: inline-block;
    padding: 5px 10px;
    color: var(--light-text);
    transition: var(--transition);
}

.back-link:hover {
    color: var(--primary);
}

.product-detail-container {
    display: flex;
    flex-wrap: wrap;
    margin-bottom: 40px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--card-shadow);
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
    background-color: var(--dark-surface-hover);
}

.product-image-placeholder {
    font-size: 8rem;
}

.product-detail-right {
    flex: 1;
    min-width: 300px;
    padding: 30px;
}

.product-title {
    font-size: 28px;
    margin-bottom: 15px;
    color: var(--dark-text);
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
    background-color: var(--dark-surface-hover);
    border-radius: 20px;
    font-size: 14px;
    color: var(--light-text);
}

.product-rating {
    display: flex;
    align-items: center;
}

.rating-stars {
    color: var(--secondary);
    margin-right: 5px;
}

.star.filled {
    color: var(--secondary);
}

.rating-value, .review-count {
    color: var(--light-text);
    font-size: 14px;
}

.product-price {
    font-size: 28px;
    font-weight: 600;
    color: var(--secondary);
    margin-bottom: 20px;
}

.product-availability {
    margin-bottom: 20px;
}

.availability-label {
    color: var(--light-text);
    margin-right: 5px;
}

.stock-info {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 14px;
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

.product-description {
    margin-bottom: 30px;
}

.product-description h3 {
    margin-bottom: 10px;
    font-size: 18px;
    color: var(--dark-text);
}

.product-description p {
    color: var(--light-text);
    line-height: 1.6;
}

.add-to-cart-form {
    margin-top: 20px;
}

.quantity-selector {
    margin-bottom: 20px;
}

.quantity-selector label {
    display: block;
    margin-bottom: 10px;
}

.quantity-control {
    display: flex;
    align-items: center;
    max-width: 150px;
}

.quantity-control button {
    width: 40px;
    height: 40px;
    background-color: var(--dark-surface-hover);
    border: none;
    color: var(--dark-text);
    font-size: 20px;
    cursor: pointer;
    transition: var(--transition);
}

.quantity-control button:hover {
    background-color: var(--primary);
    color: white;
}

.quantity-input {
    flex: 1;
    height: 40px;
    text-align: center;
    border-radius: 0;
    background-color: var(--dark-surface-hover);
    border: none;
    color: var(--dark-text);
}

.product-actions {
    display: flex;
    gap: 15px;
}

.add-to-cart-btn {
    flex: 1;
    height: 50px;
}

.product-reviews-section, .related-products-section {
    margin-top: 60px;
    margin-bottom: 60px;
}

.product-reviews-section h2, .related-products-section h2 {
    margin-bottom: 30px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
}

.review-summary {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    margin-bottom: 30px;
    padding: 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.rating-average {
    flex: 1;
    min-width: 200px;
    text-align: center;
}

.big-rating {
    font-size: 48px;
    font-weight: 700;
    color: var(--secondary);
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
    background-color: var(--dark-surface-hover);
    border-radius: 5px;
    overflow: hidden;
    margin: 0 15px;
}

.progress {
    height: 100%;
    background-color: var(--secondary);
}

.rating-count {
    flex: 0;
    min-width: 30px;
    text-align: right;
}

.review-actions {
    margin-bottom: 30px;
    text-align: right;
}

.reviews-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.review-card {
    padding: 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.review-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
}

.reviewer-name {
    font-weight: 600;
    margin-right: 15px;
}

.review-date {
    color: var(--light-text);
    font-size: 14px;
}

.review-content p {
    color: var(--light-text);
    line-height: 1.6;
}

.no-reviews {
    text-align: center;
    padding: 30px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    color: var(--light-text);
}

.related-products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
}

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
}
</style>

<script>
function addToCartWithQuantity(productId) {
    const quantity = document.getElementById('quantity').value;
    addToCart(productId, quantity);
}

function addToCart(productId, quantity = 1) {
    fetch(`${pageContext.request.contextPath}/cart/add`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}&quantity=${quantity}`
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            // Show success message
            showNotification('Product added to cart successfully');

            // Update cart count in header
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

function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

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

// Initialize quantity controls
document.addEventListener('DOMContentLoaded', function() {
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
});
</script>

<jsp:include page="/views/common/footer.jsp">
    <jsp:param name="scripts" value="main" />
</jsp:include>