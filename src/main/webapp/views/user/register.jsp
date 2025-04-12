<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Register" />
    <jsp:param name="active" value="register" />
</jsp:include>

<div class="auth-container">
    <div class="auth-card">
        <h2 class="auth-title">Create an Account</h2>

        <form action="${pageContext.request.contextPath}/user/register" method="post" data-validate="true">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required
                       data-min-length="4" pattern="^[a-zA-Z0-9_]+$">
                <small class="form-text">Username must be at least 4 characters and can only contain letters, numbers, and underscores.</small>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-input-container">
                    <input type="password" id="password" name="password" required
                           data-validate-password="true" data-min-length="8">
                    <span class="password-toggle">Show</span>
                </div>
                <small class="form-text">Password must be at least 8 characters with at least one uppercase letter, one lowercase letter, and one number.</small>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <div class="password-input-container">
                    <input type="password" id="confirmPassword" name="confirmPassword" required
                           data-match="#password">
                    <span class="password-toggle">Show</span>
                </div>
            </div>

            <div class="form-group">
                <label for="role">Account Type</label>
                <select id="role" name="role" required>
                    <option value="CUSTOMER">Customer</option>
                </select>
            </div>

            <div class="form-group">
                <div class="checkbox-container">
                    <input type="checkbox" id="terms" name="terms" required>
                    <label for="terms">I agree to the <a href="#" class="link-text">Terms of Service</a> and <a href="#" class="link-text">Privacy Policy</a></label>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Register</button>
            </div>
        </form>

        <div class="auth-links">
            <p>Already have an account? <a href="${pageContext.request.contextPath}/views/user/login.jsp">Login</a></p>
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
    max-width: 450px;
}

.auth-title {
    text-align: center;
    margin-bottom: 30px;
    color: var(--dark-text);
}

.form-group {
    margin-bottom: 20px;
}

.form-text {
    display: block;
    margin-top: 5px;
    font-size: 12px;
    color: var(--light-text);
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

.checkbox-container {
    display: flex;
    align-items: flex-start;
}

.checkbox-container input[type="checkbox"] {
    width: auto;
    margin-right: 10px;
    margin-top: 4px;
}

.link-text {
    color: var(--primary);
    text-decoration: underline;
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