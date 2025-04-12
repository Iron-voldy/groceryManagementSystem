<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Login" />
    <jsp:param name="active" value="login" />
</jsp:include>

<div class="auth-container">
    <div class="auth-card">
        <h2 class="auth-title">Login to Your Account</h2>

        <form action="${pageContext.request.contextPath}/user/login" method="post" data-validate="true">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-input-container">
                    <input type="password" id="password" name="password" required>
                    <span class="password-toggle">Show</span>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Login</button>
            </div>
        </form>

        <div class="auth-links">
            <p>Don't have an account? <a href="${pageContext.request.contextPath}/views/user/register.jsp">Register</a></p>
        </div>
    </div>
</div>

<style>
.auth-container {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px 0;
}

.auth-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    padding: 30px;
    width: 100%;
    max-width: 400px;
}

.auth-title {
    text-align: center;
    margin-bottom: 30px;
    color: var(--dark-text);
}

.form-actions {
    margin-top: 30px;
}

.form-actions .btn {
    width: 100%;
}

.auth-links {
    margin-top: 20px;
    text-align: center;
}

.auth-social {
    margin-top: 30px;
    text-align: center;
}

.auth-social-title {
    margin-bottom: 15px;
    position: relative;
}

.auth-social-title::before, .auth-social-title::after {
    content: "";
    position: absolute;
    top: 50%;
    width: 30%;
    height: 1px;
    background-color: #333;
}

.auth-social-title::before {
    left: 0;
}

.auth-social-title::after {
    right: 0;
}

.social-buttons {
    display: flex;
    justify-content: center;
    gap: 15px;
}

.social-button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: var(--dark-surface-hover);
    transition: var(--transition);
}

.social-button:hover {
    background-color: var(--primary);
}

.password-input-container {
    position: relative;
}

.password-toggle {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: var(--light-text);
    font-size: 14px;
}

.password-toggle:hover {
    color: var(--primary);
}


</style>

<jsp:include page="/views/common/footer.jsp" />