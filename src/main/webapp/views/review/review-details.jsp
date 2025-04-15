<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.grocerymanagement.model.Review" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Review Details" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<div class="review-details-container">
    <div class="review-header">
        <h1 class="page-title">Review Details</h1>
        <c:if test="${not empty review}">
            <div class="review-status-badge
                ${review.status eq 'PENDING' ? 'status-pending' :
                review.status eq 'APPROVED' ? 'status-approved' :
                'status-rejected'}">
                ${review.status}
            </div>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not empty review}">
            <div class="review-content-wrapper">
                <div class="product-section">
                    <c:if test="${not empty product}">
                        <div class="product-card">
                            <div class="product-image">
                                <c:choose>
                                    <c:when test="${not empty product.imagePath}">
                                        <img src="${pageContext.request.contextPath}${product.imagePath}"
                                            alt="${product.name}">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="placeholder-image">🛒</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="product-details">
                                <h2 class="product-name">${product.name}</h2>
                                <p class="product-category">${product.category}</p>
                                <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}"
                                class="btn btn-sm btn-secondary">View Product</a>
                            </div>
                        </div>
                    </c:if>
                </div>

                <div class="review-details-section">
                    <div class="review-meta">
                        <div class="review-rating">
                            <c:forEach begin="1" end="5" var="star">
                                <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                            </c:forEach>
                            <span class="rating-text">${review.rating}/5 Rating</span>
                        </div>
                        <div class="review-date">
                            <c:if test="${not empty review.reviewDate}">
                                <%
                                    Review currentReview = (Review)request.getAttribute("review");
                                    if (currentReview != null && currentReview.getReviewDate() != null) {
                                        out.print(currentReview.getReviewDate().format(
                                            java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy 'at' h:mm a")));
                                    }
                                %>
                            </c:if>
                        </div>
                    </div>

                    <div class="review-text-container">
                        <p class="review-text">${review.reviewText}</p>
                    </div>

                    <div class="review-actions">
                        <c:if test="${sessionScope.user.userId eq review.userId}">
                            <div class="user-review-actions">
                                <a href="${pageContext.request.contextPath}/review/edit?reviewId=${review.reviewId}"
                                class="btn btn-sm btn-secondary">Edit Review</a>
                                <a href="#"
                                class="btn btn-sm btn-danger delete-review"
                                data-review-id="${review.reviewId}">Delete Review</a>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.user.role eq 'ADMIN' and review.status eq 'PENDING'}">
                            <div class="admin-review-actions">
                                <form action="${pageContext.request.contextPath}/review/moderate" method="post" class="d-inline">
                                    <input type="hidden" name="reviewId" value="${review.reviewId}">
                                    <input type="hidden" name="status" value="APPROVED">
                                    <button type="submit" class="btn btn-sm btn-success">Approve</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/review/moderate" method="post" class="d-inline">
                                    <input type="hidden" name="reviewId" value="${review.reviewId}">
                                    <input type="hidden" name="status" value="REJECTED">
                                    <button type="submit" class="btn btn-sm btn-danger">Reject</button>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="not-found-message">
                <p>Review not found or has been deleted.</p>
                <div class="action-links">
                    <a href="${pageContext.request.contextPath}/review/user" class="btn btn-primary">My Reviews</a>
                    <a href="${pageContext.request.contextPath}/product/list" class="btn btn-secondary">Browse Products</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<style>
.review-details-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.review-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 15px;
    border-bottom: 1px solid #333;
}

.review-status-badge {
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 0.8rem;
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

.review-content-wrapper {
    display: flex;
    gap: 30px;
}

.product-section {
    flex: 1;
    max-width: 250px;
}

.product-card {
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    padding: 20px;
    text-align: center;
}

.product-image {
    width: 150px;
    height: 150px;
    margin: 0 auto 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
}

.product-image img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.placeholder-image {
    font-size: 4rem;
    color: var(--light-text);
}

.review-details-section {
    flex: 2;
}

.review-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #333;
}

.review-rating .star {
    color: #ccc;
    font-size: 1.5rem;
}

.review-rating .star.filled {
    color: var(--secondary);
}

.rating-text {
    margin-left: 10px;
    color: var(--light-text);
}

.review-date {
    color: var(--light-text);
}

.review-text-container {
    margin-bottom: 30px;
    line-height: 1.6;
    color: var(--dark-text);
}

.review-actions {
    display: flex;
    justify-content: space-between;
    gap: 15px;
}

.user-review-actions,
.admin-review-actions {
    display: flex;
    gap: 10px;
}

.not-found-message {
    text-align: center;
    padding: 40px 20px;
}

.not-found-message p {
    margin-bottom: 20px;
    font-size: 18px;
    color: var(--light-text);
}

.action-links {
    display: flex;
    justify-content: center;
    gap: 15px;
}

@media (max-width: 768px) {
    .review-content-wrapper {
        flex-direction: column;
    }

    .product-section {
        max-width: 100%;
    }

    .review-actions {
        flex-direction: column;
    }
}
</style>


<script>
document.addEventListener('DOMContentLoaded', function() {
    // Delete review confirmation
    const deleteReviewButtons = document.querySelectorAll('.delete-review');
    deleteReviewButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const reviewId = this.getAttribute('data-review-id');
            const reviewCard = this.closest('.review-card');

            if (!reviewId) {
                showNotification('Error: Review ID is missing', 'error');
                return;
            }

            if (confirm('Are you sure you want to delete this review? This action cannot be undone.')) {
                // Use fetch for AJAX request
                fetch(`${contextPath}/review/delete`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: new URLSearchParams({
                        reviewId: reviewId
                    })
                })
                .then(response => {
                    // Check if response is OK
                    if (!response.ok) {
                        // Try to parse error response
                        return response.text().then(text => {
                            console.error('Error response:', text);
                            throw new Error('Network response was not ok: ' + text);
                        });
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        showNotification(data.message, 'success');
                        // Remove the review row from the DOM
                        if (reviewCard) {
                            reviewCard.remove();
                        }
                    } else {
                        showNotification(data.message, 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showNotification('An error occurred while deleting the review', 'error');
                });
            }
        });
    });

    // Notification function
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
});

</script>

<jsp:include page="/views/common/footer.jsp" />