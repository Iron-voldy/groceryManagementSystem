<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
                            <fmt:formatDate value="${sessionScope.user.registrationDate}" pattern="MMMM yyyy" />
                        </c:if>
                    </p>
                </div>
            </div>

            <div class="profile-navigation">
                <a href="#account" class="profile-nav-link active" data-target="account-section">Account Details</a>
                <a href="#orders" class="profile-nav-link" data-target="orders-section">My Orders</a>
                <a href="#reviews" class="profile-nav-link" data-target="reviews-section">My Reviews</a>
                <a href="#address" class="profile-nav-link" data-target="address-section">Addresses</a>
                <a href="#password" class="profile-nav-link" data-target="password-section">Change Password</a>
            </div>
        </div>

        <div class="profile-main">
            <!-- Account Details Section -->
            <div id="account-section" class="profile-section active">
                <h2 class="section-title">Account Details</h2>

                <form action="${pageContext.request.contextPath}/user/update" method="post" class="profile-form" data-validate="true">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" value="${sessionScope.user.username}" disabled>
                        <small class="form-text">Username cannot be changed</small>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" value="${sessionScope.user.email}" required>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Profile</button>
                    </div>
                </form>
            </div>

            <!-- Orders Section -->
            <div id="orders-section" class="profile-section">
                <h2 class="section-title">My Orders</h2>

                <c:choose>
                    <c:when test="${not empty userOrders}">
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Date</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${userOrders}">
                                        <tr>
                                            <td>${order.orderId.substring(0, 8)}</td>
                                            <td><fmt:formatDate value="${order.orderDate}" pattern="MMM d, yyyy" /></td>
                                            <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                                            <td>
                                                <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-sm">View</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-section">
                            <p>You haven't placed any orders yet.</p>
                            <a href="${pageContext.request.contextPath}/product/list" class="btn">Shop Now</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Reviews Section -->
            <div id="reviews-section" class="profile-section">
                <h2 class="section-title">My Reviews</h2>

                <c:choose>
                    <c:when test="${not empty userReviews}">
                        <div class="reviews-list">
                            <c:forEach var="review" items="${userReviews}">
                                <div class="review-card">
                                    <div class="review-header">
                                        <h3 class="review-product">${review.productName}</h3>
                                        <div class="review-date">
                                            <fmt:formatDate value="${review.reviewDate}" pattern="MMM d, yyyy" />
                                        </div>
                                    </div>

                                    <div class="review-rating">
                                        <c:forEach begin="1" end="5" var="star">
                                            <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                                        </c:forEach>
                                    </div>

                                    <div class="review-content">
                                        <p>${review.reviewText}</p>
                                    </div>

                                    <div class="review-actions">
                                        <a href="${pageContext.request.contextPath}/review/update?reviewId=${review.reviewId}" class="btn btn-sm">Edit</a>
                                        <button class="btn btn-sm btn-danger" onclick="deleteReview('${review.reviewId}')">Delete</button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-section">
                            <p>You haven't written any reviews yet.</p>
                            <a href="${pageContext.request.contextPath}/product/list" class="btn">Shop and Review</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Addresses Section -->
            <div id="address-section" class="profile-section">
                <h2 class="section-title">My Addresses</h2>

                <c:choose>
                    <c:when test="${not empty userAddresses}">
                        <div class="addresses-grid">
                            <c:forEach var="address" items="${userAddresses}">
                                <div class="address-card">
                                    <div class="address-header">
                                        <h3 class="address-title">${address.type}</h3>
                                        <c:if test="${address.isDefault}">
                                            <span class="default-badge">Default</span>
                                        </c:if>
                                    </div>

                                    <div class="address-content">
                                        <p>${address.fullName}</p>
                                        <p>${address.street}</p>
                                        <p>${address.city}, ${address.state} ${address.zip}</p>
                                        <p>${address.country}</p>
                                        <p>${address.phone}</p>
                                    </div>

                                    <div class="address-actions">
                                        <button class="btn btn-sm" onclick="editAddress('${address.id}')">Edit</button>
                                        <button class="btn btn-sm btn-danger" onclick="deleteAddress('${address.id}')">Delete</button>
                                        <c:if test="${!address.isDefault}">
                                            <button class="btn btn-sm" onclick="setDefaultAddress('${address.id}')">Set as Default</button>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-section">
                            <p>You haven't added any addresses yet.</p>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="section-actions">
                    <button class="btn btn-primary" onclick="addNewAddress()">Add New Address</button>
                </div>

                <!-- Address Form (initially hidden) -->
                <div id="address-form-container" style="display: none;">
                    <form id="address-form" action="${pageContext.request.contextPath}/user/address/save" method="post" class="profile-form" data-validate="true">
                        <input type="hidden" id="address-id" name="addressId">

                        <div class="form-row">
                            <div class="form-group">
                                <label for="address-type">Address Type</label>
                                <select id="address-type" name="addressType" required>
                                    <option value="SHIPPING">Shipping</option>
                                    <option value="BILLING">Billing</option>
                                    <option value="BOTH">Shipping & Billing</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <div class="checkbox-container">
                                    <input type="checkbox" id="is-default" name="isDefault">
                                    <label for="is-default">Set as default address</label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="full-name">Full Name</label>
                            <input type="text" id="full-name" name="fullName" required>
                        </div>

                        <div class="form-group">
                            <label for="street">Street Address</label>
                            <input type="text" id="street" name="street" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="city">City</label>
                                <input type="text" id="city" name="city" required>
                            </div>

                            <div class="form-group">
                                <label for="state">State/Province</label>
                                <input type="text" id="state" name="state" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="zip">Zip/Postal Code</label>
                                <input type="text" id="zip" name="zip" required>
                            </div>

                            <div class="form-group">
                                <label for="country">Country</label>
                                <select id="country" name="country" required>
                                    <option value="">Select Country</option>
                                    <option value="US">United States</option>
                                    <option value="CA">Canada</option>
                                    <option value="UK">United Kingdom</option>
                                    <!-- Add more countries as needed -->
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" id="phone" name="phone" required>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Save Address</button>
                            <button type="button" class="btn btn-secondary" onclick="cancelAddressForm()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Change Password Section -->
            <div id="password-section" class="profile-section">
                <h2 class="section-title">Change Password</h2>

                <form action="${pageContext.request.contextPath}/user/update-password" method="post" class="profile-form" data-validate="true">
                    <div class="form-group">
                        <label for="current-password">Current Password</label>
                        <div class="password-input-container">
                            <input type="password" id="current-password" name="currentPassword" required>
                            <span class="password-toggle">Show</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="new-password">New Password</label>
                        <div class="password-input-container">
                            <input type="password" id="new-password" name="newPassword" required
                                   data-validate-password="true" data-min-length="8">
                            <span class="password-toggle">Show</span>
                        </div>
                        <small class="form-text">Password must be at least 8 characters with at least one uppercase letter, one lowercase letter, and one number.</small>
                    </div>

                    <div class="form-group">
                        <label for="confirm-password">Confirm New Password</label>
                        <div class="password-input-container">
                            <input type="password" id="confirm-password" name="confirmPassword" required
                                   data-match="#new-password">
                            <span class="password-toggle">Show</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Password</button>
                    </div>
                </form>
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
    margin-bottom: 0;
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

.profile-main {
    flex: 3;
    min-width: 300px;
}

.profile-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: var(--card-shadow);
    text-align: center;
}

.profile-avatar {
    margin-bottom: 15px;
}

.avatar-placeholder {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background-color: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 36px;
    font-weight: 600;
    margin: 0 auto;
}

.profile-name {
    font-size: 20px;
    margin-bottom: 5px;
    color: var(--dark-text);
}

.profile-email {
    color: var(--light-text);
    margin-bottom: 5px;
}

.profile-role {
    display: inline-block;
    padding: 3px 10px;
    background-color: var(--dark-surface-hover);
    border-radius: 20px;
    font-size: 12px;
    margin-bottom: 10px;
    color: var(--primary);
    text-transform: uppercase;
}

.profile-member-since {
    font-size: 12px;
    color: var(--light-text);
}

.profile-navigation {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--card-shadow);
}

.profile-nav-link {
    display: block;
    padding: 15px 20px;
    color: var(--dark-text);
    border-bottom: 1px solid #333;
    transition: var(--transition);
}

.profile-nav-link:last-child {
    border-bottom: none;
}

.profile-nav-link:hover {
    background-color: var(--dark-surface-hover);
}

.profile-nav-link.active {
    background-color: var(--primary);
    color: white;
}

.profile-section {
    display: none;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
}

.profile-section.active {
    display: block;
}

.section-title {
    margin-bottom: 25px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
}

.profile-form {
    max-width: 600px;
}

.form-actions {
    margin-top: 30px;
}

.empty-section {
    text-align: center;
    padding: 30px;
}

.empty-section p {
    margin-bottom: 20px;
    color: var(--light-text);
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.status-pending {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.status-processing {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.status-shipped {
    background-color: rgba(156, 39, 176, 0.2);
    color: #9c27b0;
}

.status-delivered {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-cancelled {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.section-actions {
    margin-top: 20px;
    text-align: right;
}

.addresses-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.address-card {
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    padding: 20px;
    transition: var(--transition);
}

.address-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}

.address-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.address-title {
    margin: 0;
    font-size: 18px;
    color: var(--dark-text);
}

.default-badge {
    display: inline-block;
    padding: 3px 8px;
    background-color: var(--primary);
    color: white;
    border-radius: 20px;
    font-size: 12px;
}

.address-content {
    margin-bottom: 20px;
    color: var(--light-text);
}

.address-content p {
    margin-bottom: 5px;
}

.address-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.reviews-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.review-card {
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    padding: 20px;
}

.review-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.review-product {
    margin: 0;
    font-size: 18px;
    color: var(--dark-text);
}

.review-date {
    font-size: 14px;
    color: var(--light-text);
}

.review-rating {
    margin-bottom: 15px;
}

.star {
    color: #777;
    font-size: 18px;
}

.star.filled {
    color: var(--secondary);
}

.review-content {
    color: var(--light-text);
    margin-bottom: 15px;
}

.review-actions {
    display: flex;
    gap: 10px;
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

@media (max-width: 768px) {
    .profile-content {
        flex-direction: column;
    }

    .profile-sidebar {
        max-width: none;
    }

    .addresses-grid {
        grid-template-columns: 1fr;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Profile navigation
    const navLinks = document.querySelectorAll('.profile-nav-link');
    const sections = document.querySelectorAll('.profile-section');

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            // Remove active class from all links and sections
            navLinks.forEach(l => l.classList.remove('active'));
            sections.forEach(s => s.classList.remove('active'));

            // Add active class to clicked link
            this.classList.add('active');

            // Show corresponding section
            const targetSection = document.getElementById(this.getAttribute('data-target'));
            targetSection.classList.add('active');

            // Update URL hash
            window.location.hash = this.getAttribute('href');
        });
    });

    // Check URL hash on page load
    const hash = window.location.hash;
    if (hash) {
        const activeLink = document.querySelector(`.profile-nav-link[href="${hash}"]`);
        if (activeLink) {
            activeLink.click();
        }
    }

    // Password toggles
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

// Address functions
function addNewAddress() {
    document.getElementById('address-form-container').style.display = 'block';
    document.getElementById('address-form').reset();
    document.getElementById('address-id').value = '';
    scrollToForm();
}

function editAddress(addressId) {
    // Fetch address details and populate form
    fetch(`${contextPath}/user/address/get?addressId=${addressId}`)
    .then(response => response.json())
    .then(address => {
        document.getElementById('address-id').value = address.id;
        document.getElementById('address-type').value = address.type;
        document.getElementById('is-default').checked = address.isDefault;
        document.getElementById('full-name').value = address.fullName;
        document.getElementById('street').value = address.street;
        document.getElementById('city').value = address.city;
        document.getElementById('state').value = address.state;
        document.getElementById('zip').value = address.zip;
        document.getElementById('country').value = address.country;
        document.getElementById('phone').value = address.phone;

        document.getElementById('address-form-container').style.display = 'block';
        scrollToForm();
    })
    .catch(error => {
        console.error('Error fetching address:', error);
        alert('Failed to load address details. Please try again.');
    });
}

function deleteAddress(addressId) {
    if (confirm('Are you sure you want to delete this address?')) {
        window.location.href = `${contextPath}/user/address/delete?addressId=${addressId}`;
    }
}

function setDefaultAddress(addressId) {
    window.location.href = `${contextPath}/user/address/set-default?addressId=${addressId}`;
}

function cancelAddressForm() {
    document.getElementById('address-form-container').style.display = 'none';
}

function scrollToForm() {
    document.getElementById('address-form-container').scrollIntoView({
        behavior: 'smooth',
        block: 'start'
    });
}

// Review functions
function deleteReview(reviewId) {
    if (confirm('Are you sure you want to delete this review?')) {
        window.location.href = `${contextPath}/review/delete?reviewId=${reviewId}`;
    }
}
</script>

<jsp:include page="/views/common/footer.jsp" />