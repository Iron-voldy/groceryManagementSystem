<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Edit Review" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<div class="review-container">
    <h1 class="page-title">Edit Review</h1>

    <c:choose>
        <c:when test="${not empty review}">
            <div class="review-product-info">
                <c:if test="${not empty product}">
                    <div class="product-image">
                        <c:choose>
                            <c:when test="${not empty product.imagePath}">
                                <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}">
                            </c:when>
                            <c:otherwise>
                                <div class="placeholder-image">🛒</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="product-details">
                        <h2>${product.name}</h2>
                        <p>${product.category}</p>
                    </div>
                </c:if>
            </div>

            <form action="${pageContext.request.contextPath}/review/update" method="post" class="review-form">
                <input type="hidden" name="reviewId" value="${review.reviewId}">

                <div class="form-group rating-group">
                    <label>Your Rating</label>
                    <div class="star-rating">
                        <c:forEach begin="1" end="5" var="star">
                            <span class="star ${star <= review.rating ? 'filled' : ''}" data-rating="${star}">★</span>
                        </c:forEach>
                    </div>
                    <input type="hidden" id="rating" name="rating" value="${review.rating}" required>
                </div>

                <div class="form-group">
                    <label for="reviewText">Your Review</label>
                    <textarea id="reviewText" name="reviewText" rows="5" required
                            placeholder="Share your experience with this product">${review.reviewText}</textarea>
                </div>

                <div class="review-status">
                    <span class="status-badge
                        ${review.status == 'PENDING' ? 'status-pending' :
                        review.status == 'APPROVED' ? 'status-approved' :
                        'status-rejected'}">
                        ${review.status}
                    </span>
                </div>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/review/details?reviewId=${review.reviewId}"
                    class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Update Review</button>
                </div>
            </form>
        </c:when>
        <c:otherwise>
            <div class="error-message">
                <p>Review not found or no longer available.</p>
                <div class="error-actions">
                    <a href="${pageContext.request.contextPath}/review/user" class="btn btn-primary">Back to My Reviews</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
/* Styles remain unchanged */
.review-container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.review-product-info {
    display: flex;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #333;
}

.product-image {
    width: 100px;
    height: 100px;
    margin-right: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
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

.star-rating {
    display: flex;
    font-size: 2rem;
    color: #ccc;
    margin-bottom: 5px;
}

.star-rating .star {
    cursor: pointer;
    margin-right: 5px;
    transition: color 0.2s;
}

.star-rating .star:hover,
.star-rating .star.hover {
    color: var(--secondary);
}

.star-rating .star.filled {
    color: var(--secondary);
}

.review-status {
    text-align: center;
    margin-bottom: 20px;
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.status-pending {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.status-approved {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-rejected {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.form-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
}

.error-message {
    text-align: center;
    padding: 20px;
}

.error-message p {
    margin-bottom: 20px;
    color: var(--light-text);
}

.error-actions {
    display: flex;
    justify-content: center;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const stars = document.querySelectorAll('.star-rating .star');
    const ratingInput = document.getElementById('rating');

    if (stars.length > 0 && ratingInput) {
        stars.forEach(star => {
            star.addEventListener('click', function() {
                const rating = this.getAttribute('data-rating');
                ratingInput.value = rating;

                // Clear previous filled stars
                stars.forEach(s => s.classList.remove('filled'));

                // Fill stars up to selected rating
                for (let i = 0; i < rating; i++) {
                    stars[i].classList.add('filled');
                }
            });

            // Hover effect
            star.addEventListener('mouseover', function() {
                const rating = parseInt(this.getAttribute('data-rating'));

                stars.forEach((s, index) => {
                    if (index < rating) {
                        s.classList.add('hover');
                    } else {
                        s.classList.remove('hover');
                    }
                });
            });

            star.addEventListener('mouseout', function() {
                stars.forEach(s => s.classList.remove('hover'));
            });
        });
    }
});
</script>

<jsp:include page="/views/common/footer.jsp" />