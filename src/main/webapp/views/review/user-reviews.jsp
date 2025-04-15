<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.grocerymanagement.model.Review" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="My Reviews" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<div class="user-reviews-container">
    <h1 class="page-title">My Reviews</h1>

    <c:choose>
        <c:when test="${not empty reviews and reviews.size() > 0}">
            <div class="reviews-grid">
                <c:forEach var="review" items="${reviews}">
                    <div class="review-card" data-review-id="${review.reviewId}">
                        <div class="review-header">
                            <div class="review-rating">
                                <c:forEach begin="1" end="5" var="star">
                                    <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                                </c:forEach>
                            </div>
                            <div class="review-status">
                                <span class="status-badge
                                    ${review.status == 'PENDING' ? 'status-pending' :
                                      review.status == 'APPROVED' ? 'status-approved' :
                                      'status-rejected'}">
                                    ${review.status}
                                </span>
                            </div>
                        </div>

                        <div class="review-product-info">
                            <c:set var="productDetails" value="${productMap[review.productId]}" />
                            <c:if test="${not empty productDetails}">
                                <div class="product-image">
                                    <c:choose>
                                        <c:when test="${not empty productDetails.imagePath}">
                                            <img src="${pageContext.request.contextPath}${productDetails.imagePath}"
                                                 alt="${productDetails.name}">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="placeholder-image">🛒</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="product-name">
                                    ${productDetails.name}
                                </div>
                            </c:if>
                        </div>

                        <div class="review-content">
                            <p>${review.reviewText}</p>
                        </div>

                        <div class="review-footer">
                            <div class="review-date">
                                <%
                                    Review currentReview = (Review)pageContext.getAttribute("review");
                                    if (currentReview != null && currentReview.getReviewDate() != null) {
                                        out.print(currentReview.getReviewDate().format(
                                            java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy")));
                                    }
                                %>
                            </div>
                            <div class="review-actions">
                                <a href="${pageContext.request.contextPath}/review/details?reviewId=${review.reviewId}"
                                   class="btn btn-sm btn-secondary">View Details</a>
                                <c:if test="${review.status == 'PENDING' || review.status == 'REJECTED'}">
                                    <a href="${pageContext.request.contextPath}/review/edit?reviewId=${review.reviewId}"
                                       class="btn btn-sm btn-primary">Edit</a>
                                </c:if>
                                <button class="btn btn-sm btn-danger delete-review-btn"
                                        data-review-id="${review.reviewId}">Delete</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-reviews">
                <p>You haven't written any reviews yet.</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary">
                    Start Shopping
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Confirmation Modal -->
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
.user-reviews-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.reviews-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.review-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    box-shadow: var(--card-shadow);
    display: flex;
    flex-direction: column;
    position: relative;
}

.review-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
}

.review-rating .star {
    color: #ccc;
    font-size: 1.2rem;
}

.review-rating .star.filled {
    color: var(--secondary);
}

.status-badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 0.7rem;
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

.review-product-info {
    display: flex;
    align-items: center;
    margin-bottom: 15px;
}

.product-image {
    width: 50px;
    height: 50px;
    margin-right: 10px;
    background-color: var(--dark-surface-hover);
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: var(--border-radius);
}

.product-image img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}

.placeholder-image {
    font-size: 1.5rem;
    color: var(--light-text);
}

.review-content {
    flex-grow: 1;
    margin-bottom: 15px;
}

.review-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #333;
    padding-top: 10px;
}

.review-date {
    color: var(--light-text);
    font-size: 0.8rem;
}

.review-actions {
    display: flex;
    gap: 10px;
}

.no-reviews {
    text-align: center;
    background-color: var(--dark-surface);
    padding: 40px;
    border-radius: var(--border-radius);
}

.no-reviews p {
    margin-bottom: 20px;
    color: var(--light-text);
}

/* Modal Styles */
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

/* Notification Styles */
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
            // Use the full context path for the URL
            const fullUrl = '${pageContext.request.contextPath}/review/delete';
            console.log('Sending delete request to:', fullUrl);

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
                    // Remove the review card from the DOM
                    const reviewCard = document.querySelector(`.review-card[data-review-id="${currentReviewId}"]`);
                    if (reviewCard) {
                        reviewCard.remove();
                    }

                    // If no more reviews, reload the page to show the "no reviews" message
                    if (document.querySelectorAll('.review-card').length === 0) {
                        setTimeout(() => {
                            window.location.reload();
                        }, 1000);
                    }
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

    // Check for success message in session and display notification
    const urlParams = new URLSearchParams(window.location.search);
    const successMessage = urlParams.get('success');
    const errorMessage = urlParams.get('error');

    if (successMessage) {
        showNotification(decodeURIComponent(successMessage), 'success');
    } else if (errorMessage) {
        showNotification(decodeURIComponent(errorMessage), 'error');
    }
});
</script>

<jsp:include page="/views/common/footer.jsp" />