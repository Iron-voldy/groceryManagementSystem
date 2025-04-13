<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="System Setup" />
</jsp:include>

<div class="container setup-container">
    <div class="card">
        <h1 class="card-title">System Setup</h1>

        <div class="card-body">
            <p class="alert ${not empty username ? 'alert-success' : 'alert-warning'}">
                ${message}
            </p>

            <c:if test="${not empty username}">
                <div class="credentials">
                    <h3>Admin Credentials</h3>
                    <p><strong>Username:</strong> ${username}</p>
                    <p><strong>Password:</strong> AdminPassword123!</p>
                    <p class="text-warning">
                        <strong>Important:</strong> Change this password immediately after first login!
                    </p>
                </div>
            </c:if>

            <div class="setup-actions">
                <a href="${pageContext.request.contextPath}/views/user/login.jsp" class="btn btn-primary">
                    Proceed to Login
                </a>
            </div>
        </div>
    </div>
</div>

<style>
.setup-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 60vh;
}

.card {
    width: 100%;
    max-width: 500px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    padding: 30px;
}

.card-title {
    text-align: center;
    margin-bottom: 20px;
    color: var(--dark-text);
}

.credentials {
    background-color: var(--dark-surface-hover);
    padding: 20px;
    border-radius: var(--border-radius);
    margin-bottom: 20px;
}

.setup-actions {
    text-align: center;
}
</style>

<jsp:include page="/views/common/footer.jsp" />