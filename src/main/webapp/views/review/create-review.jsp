<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Write a Review" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<div class="review-container">
    <h1 class="page-title">Write a Review</h1>

    <!-- Display error message if exists -->
    <c:if test="${not empty error}">
        <div class="alert alert-error">
            ${error}
        </div>
    </c:if>

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

    <form action="${pageContext.request.contextPath}/review/create" method="post" class="review-form" id="reviewForm">
        <input type="hidden" name="productId" value="${product.productId}">

        <div class="form-group rating-group">
            <label>Your Rating <span class="required">*</span></label>
            <div class="star-rating">
                <c:forEach begin="1" end="5" var="star">
                    <span class="star" data-rating="${star}">★</span>
                </c:forEach>
            </div>
            <input type="hidden" id="rating" name="rating" required>
            <div class="rating-error" style="color: var(--danger); display: none;">Please select a rating</div>
        </div>

        <div class="form-group">
            <label for="reviewText">Your Review <span class="required">*</span></label>
            <textarea id="reviewText" name="reviewText" rows="5" required
                      placeholder="Share your experience with this product">${param.reviewText}</textarea>
        </div>

        <div class="form-actions">
            <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}"
               class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">Submit Review</button>
        </div>
    </form>
</div>

<style>
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

.form-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
}

.required {
    color: var(--danger);
}

.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: var(--border-radius);
}

.alert-error {
    background-color: rgba(244, 67, 54, 0.1);
    border: 1px solid var(--danger);
    color: var(--danger);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const stars = document.querySelectorAll('.star-rating .star');
    const ratingInput = document.getElementById('rating');
    const ratingError = document.querySelector('.rating-error');
    const reviewForm = document.getElementById('reviewForm');

    // Star rating functionality
    stars.forEach(star => {
        star.addEventListener('click', function() {
            const rating = this.getAttribute('data-rating');
            ratingInput.value = rating;
            ratingError.style.display = 'none';

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

    // Form validation
    reviewForm.addEventListener('submit', function(event) {
        let isValid = true;

        // Validate rating
        if (!ratingInput.value) {
            ratingError.style.display = 'block';
            isValid = false;
        }

        // Validate review text
        const reviewText = document.getElementById('reviewText').value.trim();
        if (!reviewText) {
            document.getElementById('reviewText').classList.add('is-invalid');
            isValid = false;
        }

        if (!isValid) {
            event.preventDefault();
        }
    });
});
</script>

<jsp:include page="/views/common/footer.jsp" />