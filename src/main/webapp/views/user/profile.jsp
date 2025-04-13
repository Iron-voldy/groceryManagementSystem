<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="com.grocerymanagement.model.User" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="My Profile" />
    <jsp:param name="active" value="profile" />
</jsp:include>

<div class="profile-container">
    <div class="profile-header">
        <h1 class="page-title">My Profile</h1>
    </div>

    <div class="profile-content">
        <div class="profile-sidebar">
            <div class="profile-card">
                <div class="profile-avatar">
                    <div class="avatar-placeholder">
                        ${sessionScope.user.username.substring(0, 1).toUpperCase()}
                    </div>
                </div>
                <div class="profile-info">
                    <h2 class="profile-name">${sessionScope.user.username}</h2>
                    <p class="profile-email">${sessionScope.user.email}</p>
                    <p class="profile-role">${sessionScope.user.role}</p>
                    <p class="profile-member-since">Member since:
                        <c:if test="${not empty sessionScope.user.registrationDate}">
                            <%
                                // Fix for ClassCastException
                                User currentUser = (User)session.getAttribute("user");
                                if (currentUser != null) {
                                    LocalDateTime registrationDate = currentUser.getRegistrationDate();
                                    if (registrationDate != null) {
                                        out.print(registrationDate.format(DateTimeFormatter.ofPattern("MMMM yyyy")));
                                    }
                                }
                            %>
                        </c:if>
                    </p>
                </div>
            </div>

            <div class="profile-navigation">
                <ul class="profile-nav-links">
                    <li><a href="${pageContext.request.contextPath}/user/profile" class="active">Profile Information</a></li>
                    <li><a href="${pageContext.request.contextPath}/order/my-orders">My Orders</a></li>
                    <li><a href="${pageContext.request.contextPath}/review/user">My Reviews</a></li>
                    <li><a href="${pageContext.request.contextPath}/user/addresses">Addresses</a></li>
                    <li><a href="${pageContext.request.contextPath}/user/payment-methods">Payment Methods</a></li>
                </ul>
            </div>
        </div>

        <div class="profile-main">
            <div class="profile-section">
                <h2 class="section-title">Profile Information</h2>

                <form action="${pageContext.request.contextPath}/user/update" method="post" data-validate="true">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" value="${sessionScope.user.username}" disabled>
                        <small class="form-text">Username cannot be changed</small>
                    </div>

                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" value="${sessionScope.user.email}" required>
                    </div>

                    <div class="form-group">
                        <label for="newPassword">New Password</label>
                        <div class="password-input-container">
                            <input type="password" id="newPassword" name="newPassword"
                                   data-validate-password="true" data-min-length="8">
                            <span class="password-toggle">Show</span>
                        </div>
                        <small class="form-text">Leave blank to keep current password</small>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <div class="password-input-container">
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   data-match="#newPassword">
                            <span class="password-toggle">Show</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Profile</button>
                    </div>
                </form>
            </div>

            <div class="profile-section">
                <h2 class="section-title">Account Settings</h2>

                <div class="account-actions">
                    <a href="${pageContext.request.contextPath}/user/delete" class="btn btn-danger"
                       onclick="return confirm('Are you sure you want to delete your account? This action cannot be undone.')">
                        Delete Account
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.profile-container {
    padding: 20px 0;
}

.profile-header {
    margin-bottom: 30px;
}

.page-title {
    color: var(--dark-text);
}

.profile-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.profile-sidebar {
    flex: 1;
    min-width: 250px;
    max-width: 300px;
}

.profile-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    margin-bottom: 20px;
    text-align: center;
    box-shadow: var(--card-shadow);
}

.profile-avatar {
    margin-bottom: 15px;
}

.avatar-placeholder {
    width: 100px;
    height: 100px;
    background-color: var(--primary);
    color: white;
    font-size: 3rem;
    font-weight: bold;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto;
}

.profile-name {
    font-size: 1.5rem;
    margin-bottom: 5px;
    color: var(--dark-text);
}

.profile-email {
    color: var(--light-text);
    margin-bottom: 10px;
}

.profile-role {
    display: inline-block;
    background-color: var(--dark-surface-hover);
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 0.8rem;
    margin-bottom: 10px;
}

.profile-navigation {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--card-shadow);
}

.profile-nav-links {
    list-style: none;
    padding: 0;
    margin: 0;
}

.profile-nav-links li a {
    display: block;
    padding: 15px 20px;
    color: var(--light-text);
    border-left: 3px solid transparent;
    transition: var(--transition);
}

.profile-nav-links li a:hover {
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
}

.profile-nav-links li a.active {
    background-color: var(--dark-surface-hover);
    color: var(--primary);
    border-left-color: var(--primary);
}

.profile-main {
    flex: 3;
    min-width: 300px;
}

.profile-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.section-title {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 1.2rem;
}

.form-text {
    display: block;
    margin-top: 5px;
    font-size: 0.8rem;
    color: var(--light-text);
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
    font-size: 0.8rem;
}

.password-toggle:hover {
    color: var(--primary);
}

.form-actions {
    margin-top: 20px;
}

.account-actions {
    display: flex;
    justify-content: flex-start;
    gap: 15px;
}

@media (max-width: 768px) {
    .profile-content {
        flex-direction: column;
    }

    .profile-sidebar {
        max-width: none;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Password toggle functionality
    const passwordToggles = document.querySelectorAll('.password-toggle');
    passwordToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            const input = this.previousElementSibling;
            const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
            input.setAttribute('type', type);
            this.textContent = type === 'password' ? 'Show' : 'Hide';
        });
    });
});
</script>

<jsp:include page="/views/common/footer.jsp" />