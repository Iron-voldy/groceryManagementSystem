<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Review Submitted" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="success-container">
    <div class="success-card">
        <div class="success-icon">✅</div>
        <h1 class="success-title">Review Submitted Successfully!</h1>

        <c:if test="${review.status == 'PENDING'}">
            <p class="success-message">
                Thank you for your review. It is currently pending approval and will be visible once approved.
            </p>
        </c:if>

        <c:if test="${review.status == 'APPROVED'}">
            <p class="success-message">
                Thank you for your review. It has been approved and is now visible on the product page.
            </p>
        </c:if>

        <div class="success-actions">
            <a href="${pageContext.request.contextPath}/product/details?productId=${review.productId}" class="btn btn-primary">
                Back to Product
            </a>
            <a href="${pageContext.request.contextPath}/review/user" class="btn btn-secondary">
                View My Reviews
            </a>
        </div>
    </div>
</div>

<style>
.success-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 60vh;
    padding: 40px 0;
}

.success-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 40px;
    box-shadow: var(--card-shadow);
    text-align: center;
    max-width: 500px;
    width: 100%;
}

.success-icon {
    font-size: 3rem;
    margin-bottom: 20px;
}

.success-title {
    color: var(--success);
    margin-bottom: 20px;
}

.success-message {
    color: var(--light-text);
    margin-bottom: 30px;
    line-height: 1.6;
}

.success-actions {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 15px;
}

@media (max-width: 768px) {
    .success-card {
        padding: 30px 20px;
    }

    .success-actions {
        flex-direction: column;
    }

    .success-actions .btn {
        width: 100%;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp" />