<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>

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
                                LocalDateTime registrationDate = (LocalDateTime) session.getAttribute("user") != null
                                    ? ((com.grocerymanagement.model.User)session.getAttribute("user")).getRegistrationDate()
                                    : null;
                                if (registrationDate != null) {
                                    out.print(registrationDate.format(DateTimeFormatter.ofPattern("MMMM yyyy")));
                                }
                            %>
                        </c:if>
                    </p>
                </div>
            </div>

            <!-- Rest of the profile page remains the same -->
        </div>
    </div>
</div>

<!-- Rest of the existing profile.jsp content -->