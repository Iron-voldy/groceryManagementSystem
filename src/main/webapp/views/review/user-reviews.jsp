<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="My Reviews" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<div class="user-reviews-container">
    <h1 class="page-title">My Reviews</h1>

    <c:choose>
        <c:when test="${not empty reviews}">
            <div class="reviews-grid">
                <c:forEach var="review" items="${reviews}">
                    <div class="review-card">
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
                                <fmt:formatDate value="${review.reviewDate}" pattern="MMMM d, yyyy" />
                            </div>
                            <div class="review-actions">
                                <a href="${pageContext.request.contextPath}/review/details?reviewId=${review.reviewId}"
                                   class="btn btn-sm btn-secondary">View Details</a>
                                <c:if test="${review.status == 'PENDING' || review.status == 'REJECTED'}">
                                    <a href="${pageContext.request.contextPath}/review/edit?reviewId=${review.reviewId}"
                                       class="btn btn-sm btn-primary">Edit</a>
                                </c:if>
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
</style>

<jsp:include page="/views/common/footer.jsp" />