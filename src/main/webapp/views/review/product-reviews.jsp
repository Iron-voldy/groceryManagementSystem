<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="${product.name} - Reviews" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="product-reviews-container">
    <div class="reviews-header">
        <div class="navigation">
            <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="back-link">
                ← Back to Product
            </a>
        </div>
        <h1 class="page-title">Reviews for ${product.name}</h1>
    </div>

    <div class="reviews-content">
        <div class="reviews-summary">
            <div class="summary-card">
                <div class="summary-header">
                    <div class="product-image">
                        <c:choose>
                            <c:when test="${not empty product.imagePath}">
                                <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}">
                            </c:when>
                            <c:otherwise>
                                <div class="placeholder-image">
                                    <c:choose>
                                        <c:when test="${product.category == 'Fresh Products'}">🥩</c:when>
                                        <c:when test="${product.category == 'Dairy'}">🥛</c:when>
                                        <c:when test="${product.category == 'Vegetables'}">🥦</c:when>
                                        <c:when test="${product.category == 'Fruits'}">🍎</c:when>
                                        <c:when test="${product.category == 'Pantry Items'}">🥫</c:when>
                                        <c:otherwise>🛒</c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="product-info">
                        <h2>${product.name}</h2>
                        <p class="product-category">${product.category}</p>
                        <div class="product-rating">
                            <div class="rating-stars">
                                <c:forEach begin="1" end="5" var="star">
                                    <span class="star ${star <= averageRating ? 'filled' : ''}">★</span>
                                </c:forEach>
                            </div>
                            <span class="rating-number">${averageRating}/5</span>
                            <span class="rating-count">(${reviews.size()} reviews)</span>
                        </div>
                    </div>
                </div>

                <div class="rating-distribution">
                    <h3>Rating Distribution</h3>
                    <c:forEach var="i" begin="5" end="1" step="-1">
                        <div class="rating-bar">
                            <div class="bar-label">${i} Stars</div>
                            <div class="bar-container">
                                <div class="bar-fill" style="width: ${stats.ratingDistribution[i] * 100 / (stats.totalReviews > 0 ? stats.totalReviews : 1)}%"></div>
                            </div>
                            <div class="bar-count">${stats.ratingDistribution[i]}</div>
                        </div>
                    </c:forEach>
                </div>

                <div class="review-actions">
                    <a href="${pageContext.request.contextPath}/review/create?productId=${product.productId}" class="btn btn-primary">
                        Write a Review
                    </a>
                </div>
            </div>
        </div>

        <div class="reviews-list">
            <h2>Customer Reviews</h2>

            <c:choose>
                <c:when test="${not empty reviews}">
                    <div class="reviews-filter">
                        <label for="sort-reviews">Sort by:</label>
                        <select id="sort-reviews" onchange="sortReviews(this.value)">
                            <option value="date-desc">Newest First</option>
                            <option value="date-asc">Oldest First</option>
                            <option value="rating-desc">Highest Rating</option>
                            <option value="rating-asc">Lowest Rating</option>
                        </select>
                    </div>

                    <div class="reviews-grid">
                        <c:forEach var="review" items="${reviews}">
                            <div class="review-card" data-rating="${review.rating}" data-date="${review.reviewDate.getTime()}">
                                <div class="review-header">
                                    <div class="reviewer-info">
                                        <c:set var="reviewerName" value="${review.userId}" />
                                        <c:if test="${not empty userMap[review.userId]}">
                                            <c:set var="reviewerName" value="${userMap[review.userId].username}" />
                                        </c:if>
                                        <span class="reviewer-name">${reviewerName}</span>
                                        <span class="verified-tag">Verified Purchaser</span>
                                    </div>
                                    <span class="review-date">
                                        <fmt:formatDate value="${review.reviewDate}" pattern="MMM d, yyyy" />
                                    </span>
                                </div>
                                <div class="review-rating">
                                    <c:forEach begin="1" end="5" var="star">
                                        <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                                    </c:forEach>
                                </div>
                                <div class="review-content">
                                    <p>${review.reviewText}</p>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="no-reviews">
                        <p>There are no reviews for this product yet.</p>
                        <a href="${pageContext.request.contextPath}/review/create?productId=${product.productId}" class="btn btn-primary">
                            Be the first to write a review
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<style>
.product-reviews-container {
    padding: 20px 0;
}

.reviews-header {
    margin-bottom: 30px;
}

.navigation {
    margin-bottom: 10px;
}

.back-link {
    color: var(--light-text);
    transition: var(--transition);
}

.back-link:hover {
    color: var(--primary);
}

.page-title {
    color: var(--dark-text);
    margin-bottom: 15px;
}

.reviews-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.reviews-summary {
    flex: 1;
    min-width: 300px;
    max-width: 400px;
}

.summary-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
}

.summary-header {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid #333;
}

.product-image {
    width: 100px;
    height: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    overflow: hidden;
}

.product-image img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.placeholder-image {
    font-size: 3rem;
    color: var(--light-text);
}

.product-info h2 {
    margin-bottom: 5px;
    font-size: 1.2rem;
    color: var(--dark-text);
}

.product-category {
    display: inline-block;
    padding: 3px 8px;
    background-color: var(--dark-surface-hover);
    border-radius: 20px;
    font-size: 12px;
    margin-bottom: 10px;
    color: var(--light-text);
}

.product-rating {
    display: flex;
    align-items: center;
}

.rating-stars {
    display: flex;
    margin-right: 5px;
}

.star {
    color: #ccc;
    font-size: 1.2rem;
}

.star.filled {
    color: var(--secondary);
}

.rating-number {
    margin-right: 5px;
    font-weight: 600;
    color: var(--dark-text);
}

.rating-count {
    color: var(--light-text);
    font-size: 0.9rem;
}

.rating-distribution {
    margin-bottom: 25px;
}

.rating-distribution h3 {
    margin-bottom: 15px;
    font-size: 1.1rem;
    color: var(--dark-text);
}

.rating-bar {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.bar-label {
    width: 70px;
    color: var(--light-text);
    font-size: 0.9rem;
}

.bar-container {
    flex: 1;
    height: 10px;
    background-color: var(--dark-surface-hover);
    border-radius: 5px;
    overflow: hidden;
    margin: 0 10px;
}

.bar-fill {
    height: 100%;
    background-color: var(--secondary);
}

.bar-count {
    width: 30px;
    text-align: right;
    color: var(--light-text);
    font-size: 0.9rem;
}

.review-actions {
    text-align: center;
}

.reviews-list {
    flex: 2;
    min-width: 300px;
}

.reviews-list h2 {
    margin-bottom: 20px;
    color: var(--dark-text);
}

.reviews-filter {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
}

.reviews-filter label {
    margin-right: 10px;
    color: var(--light-text);
}

.reviews-grid {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.review-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    box-shadow: var(--card-shadow);
}

.review-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
}

.reviewer-name {
    font-weight: 600;
    color: var(--dark-text);
    margin-right: 10px;
}

.verified-tag {
    display: inline-block;
    padding: 2px 6px;
    background-color: rgba(76, 175, 80, 0.1);
    color: var(--success);
    border-radius: 10px;
    font-size: 0.7rem;
    text-transform: uppercase;
}

.review-date {
    color: var(--light-text);
    font-size: 0.9rem;
}

.review-rating {
    margin-bottom: 15px;
}

.review-content {
    color: var(--light-text);
    line-height: 1.6;
}

.no-reviews {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 30px;
    text-align: center;
    box-shadow: var(--card-shadow);
}

.no-reviews p {
    margin-bottom: 20px;
    color: var(--light-text);
}

@media (max-width: 768px) {
    .reviews-content {
        flex-direction: column;
    }

    .reviews-summary {
        max-width: none;
    }
}
</style>

<script>
function sortReviews(sortOption) {
    const reviewCards = Array.from(document.querySelectorAll('.review-card'));
    const reviewsGrid = document.querySelector('.reviews-grid');

    reviewCards.sort((a, b) => {
        const [field, direction] = sortOption.split('-');
        const multiplier = direction === 'asc' ? 1 : -1;

        if (field === 'date') {
            const dateA = parseInt(a.getAttribute('data-date'));
            const dateB = parseInt(b.getAttribute('data-date'));
            return (dateA - dateB) * multiplier;
        } else if (field === 'rating') {
            const ratingA = parseInt(a.getAttribute('data-rating'));
            const ratingB = parseInt(b.getAttribute('data-rating'));
            return (ratingA - ratingB) * multiplier;
        }

        return 0;
    });

    // Clear and append sorted cards
    reviewsGrid.innerHTML = '';
    reviewCards.forEach(card => reviewsGrid.appendChild(card));
}
</script>

<jsp:include page="/views/common/footer.jsp" />