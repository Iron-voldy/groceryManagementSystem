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
                                <button type="button" class="btn btn-sm btn-danger delete-review-btn"
                                        data-review-id="${review.reviewId}">Delete Review</button>
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

.d-inline {
    display: inline-block;
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

<div id="confirmationModal" class="modal">
    <div class="modal-content">
        <h3>Confirm Deletion</h3>
        <p>Are you sure you want to delete this review? This action cannot be undone.</p>
        <div class="modal-actions">
            <button id="confirmDelete" class="btn btn-danger">Delete</button>
            <button id="cancelDelete" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
</div>

<style>
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.7);
    overflow: auto;
}

.modal-content {
    background-color: var(--dark-surface);
    margin: 15% auto;
    padding: 30px;
    border-radius: var(--border-radius);
    max-width: 500px;
    box-shadow: var(--card-shadow);
    text-align: center;
}

.modal-content h3 {
    margin-bottom: 20px;
    color: var(--dark-text);
}

.modal-content p {
    margin-bottom: 30px;
    color: var(--light-text);
}

.modal-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Delete review with confirmation
    const deleteButtons = document.querySelectorAll('.delete-review-btn');
    const modal = document.getElementById('confirmationModal');
    const confirmDeleteBtn = document.getElementById('confirmDelete');
    const cancelDeleteBtn = document.getElementById('cancelDelete');
    let currentReviewId = null;

    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            currentReviewId = this.getAttribute('data-review-id');
            modal.style.display = 'block';
        });
    });

    confirmDeleteBtn.addEventListener('click', function() {
        if (currentReviewId) {
            // Make sure to include the full contextPath
            const fullUrl = '${pageContext.request.contextPath}/review/delete';
            console.log('Sending request to:', fullUrl);

            fetch(fullUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: `reviewId=${currentReviewId}`
            })
            .then(response => {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    return response.text().then(text => {
                        console.error('Error response:', text);
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    });
                }
                return response.json();
            })
            .then(data => {
                console.log('Success data:', data);
                if (data.success) {
                    showNotification(data.message, 'success');
                    // Redirect to user reviews after successful deletion
                    window.location.href = '${pageContext.request.contextPath}/review/user';
                } else {
                    showNotification(data.message, 'error');
                }
                modal.style.display = 'none';
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('An error occurred while deleting the review', 'error');
                modal.style.display = 'none';
            });
        }
    });

    cancelDeleteBtn.addEventListener('click', function() {
        modal.style.display = 'none';
    });

    // Close modal if clicking outside
    window.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
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

<style>
.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    border-radius: var(--border-radius);
    background-color: var(--success);
    color: white;
    max-width: 300px;
    z-index: 1000;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.3);
    transform: translateX(110%);
    transition: transform 0.3s ease;
}

.notification.show {
    transform: translateX(0);
}

.notification-error {
    background-color: var(--danger);
}

.notification-warning {
    background-color: var(--warning);
}
</style>

<jsp:include page="/views/common/footer.jsp" />