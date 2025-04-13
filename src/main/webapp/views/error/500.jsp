<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Internal Server Error" />
</jsp:include>

<div class="error-container">
    <div class="error-content">
        <h1 class="error-code">500</h1>
        <h2 class="error-message">Internal Server Error</h2>
        <p>Something went wrong on our server. Please try again later or contact support if the problem persists.</p>

        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary">Go to Home</a>
            <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
        </div>
    </div>
</div>

<style>
.error-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 70vh;
    text-align: center;
    padding: 20px;
}

.error-content {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 40px;
    box-shadow: var(--card-shadow);
    max-width: 600px;
}

.error-code {
    font-size: 8rem;
    color: var(--danger);
    margin-bottom: 20px;
}

.error-message {
    font-size: 2rem;
    color: var(--dark-text);
    margin-bottom: 20px;
}

.error-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-top: 30px;
}
</style>

<jsp:include page="/views/common/footer.jsp" />