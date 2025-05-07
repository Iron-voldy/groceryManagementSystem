<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Reviews" />
    <jsp:param name="active" value="reviews" />
</jsp:include>

<!-- Add context path for JavaScript to use -->
<meta name="context-path" content="${pageContext.request.contextPath}" />

<div class="admin-reviews">
    <div class="page-header">
        <h1 class="page-title">Product Reviews</h1>
    </div>

    <!-- Review Statistics -->
    <div class="review-stats-grid">
        <div class="stat-card">
            <div class="stat-icon">💬</div>
            <div class="stat-content">
                <h3 class="stat-title">Total Reviews</h3>
                <div class="stat-value">${stats.totalReviews}</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">⭐</div>
            <div class="stat-content">
                <h3 class="stat-title">Average Rating</h3>
                <div class="stat-value">
                    <fmt:formatNumber value="${stats.averageRating}" pattern="#,##0.1"/>
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
                <h3 class="stat-title">Approved Reviews</h3>
                <div class="stat-value">${stats.approvedReviews}</div>
                <div class="stat-change">${stats.approvedPercentage}%</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">⏳</div>
            <div class="stat-content">
                <h3 class="stat-title">Pending Reviews</h3>
                <div class="stat-value">${stats.pendingReviews}</div>
                <div class="stat-change">${stats.pendingPercentage}%</div>
            </div>
        </div>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/review/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="searchTerm" placeholder="Search reviews..." value="${param.searchTerm}">
                </div>

                <div class="filter-group">
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="APPROVED" ${param.status == 'APPROVED' ? 'selected' : ''}>Approved</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="REJECTED" ${param.status == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                    </select>
                </div>

                <div class="filter-group">
                    <select name="rating">
                        <option value="">All Ratings</option>
                        <option value="5" ${param.rating == '5' ? 'selected' : ''}>5 Stars</option>
                        <option value="4" ${param.rating == '4' ? 'selected' : ''}>4 Stars</option>
                        <option value="3" ${param.rating == '3' ? 'selected' : ''}>3 Stars</option>
                        <option value="2" ${param.rating == '2' ? 'selected' : ''}>2 Stars</option>
                        <option value="1" ${param.rating == '1' ? 'selected' : ''}>1 Star</option>
                    </select>
                </div>

                <div class="filter-group date-range-picker">
                    <input type="date" name="startDate" placeholder="Start Date" class="start-date" value="${param.startDate}">
                    <span>to</span>
                    <input type="date" name="endDate" placeholder="End Date" class="end-date" value="${param.endDate}">
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/review/list" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <!-- Bulk Actions -->
    <div class="bulk-actions">
        <div class="bulk-action-group">
            <select id="bulk-action">
                <option value="">Bulk Actions</option>
                <option value="approve">Approve</option>
                <option value="reject">Reject</option>
                <option value="delete">Delete</option>
            </select>
            <button id="apply-bulk-action" class="btn btn-sm">Apply</button>
        </div>

        <div id="reviews-table-stats" class="table-stats">
            Showing ${reviews.size()} of ${totalReviews} reviews
        </div>
    </div>

    <!-- Reviews Table -->
    <div class="table-container">
        <table class="data-table" id="reviews-table" data-item-type="review">
            <thead>
                <tr>
                    <th width="30">
                        <input type="checkbox" id="select-all">
                    </th>
                    <th data-sort="id">Review ID</th>
                    <th data-sort="product">Product</th>
                    <th data-sort="user">User</th>
                    <th data-sort="rating">Rating</th>
                    <th data-sort="date" data-default-sort="desc">Date</th>
                    <th data-sort="status">Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="review" items="${reviews}">
                    <tr data-id="${review.reviewId}" class="status-${review.status.toString().toLowerCase()}">
                        <td>
                            <input type="checkbox" name="selected-items" value="${review.reviewId}">
                        </td>
                        <td>${fn:substring(review.reviewId, 0, 8)}</td>
                        <td>${review.productName}</td>
                        <td>${review.userName}</td>
                        <td>
                            <div class="rating">
                                <c:forEach begin="1" end="5" var="star">
                                    <span class="star ${star <= review.rating ? 'filled' : ''}">★</span>
                                </c:forEach>
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty review.reviewDate}">
                                    <fmt:parseDate value="${review.reviewDate.toString()}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                                    <fmt:formatDate value="${parsedDate}" pattern="MMM d, yyyy" />
                                </c:when>
                                <c:otherwise>
                                    N/A
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="status-badge status-${review.status.toLowerCase()}">
                                ${review.status}
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/review/details?reviewId=${review.reviewId}"
                                   class="btn btn-sm">View</a>
                                <c:if test="${review.status == 'PENDING'}">
                                    <button class="btn btn-sm btn-primary approve-btn"
                                            data-id="${review.reviewId}">Approve</button>
                                    <button class="btn btn-sm btn-danger reject-btn"
                                            data-id="${review.reviewId}">Reject</button>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                <a href="${pageContext.request.contextPath}/review/list?page=${pageNum}
                    ${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}
                    ${not empty param.status ? '&status='.concat(param.status) : ''}
                    ${not empty param.rating ? '&rating='.concat(param.rating) : ''}
                    ${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}
                    ${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>
</div>

<style>
.admin-reviews {
    padding-bottom: 40px;
}

.review-stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    display: flex;
    align-items: center;
    box-shadow: var(--card-shadow);
    transition: var(--transition);
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
}

.stat-icon {
    font-size: 3rem;
    margin-right: 20px;
    color: var(--primary);
}

.stat-content {
    flex: 1;
}

.stat-title {
    font-size: 14px;
    color: var(--light-text);
    margin-bottom: 5px;
}

.stat-value {
    font-size: 24px;
    font-weight: 600;
    color: var(--dark-text);
    margin-bottom: 5px;
}

.stat-change {
    font-size: 12px;
    color: var(--light-text);
}

.rating {
    color: var(--secondary);
}

.rating .star {
    color: #777;
    font-size: 18px;
}

.rating .star.filled {
    color: var(--secondary);
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.status-approved {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-pending {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.status-rejected {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Get context path from meta tag
    const contextPath = document.querySelector('meta[name="context-path"]')?.getAttribute('content') || '';

    // Bulk action handling
    const bulkActionSelect = document.getElementById('bulk-action');
    const applyBulkActionBtn = document.getElementById('apply-bulk-action');

    if (bulkActionSelect && applyBulkActionBtn) {
        applyBulkActionBtn.addEventListener('click', function() {
            const selectedReviews = document.querySelectorAll('input[name="selected-items"]:checked');
            if (selectedReviews.length === 0) {
                alert('Please select at least one review');
                return;
            }

            const action = bulkActionSelect.value;
            if (!action) {
                alert('Please select an action');
                return;
            }

            const reviewIds = Array.from(selectedReviews).map(review => review.value);

            if (action === 'delete' && !confirm(`Are you sure you want to delete ${selectedReviews.length} selected reviews?`)) {
                return;
            }

            processBulkAction(reviewIds, action);
        });
    }

    // Individual review action buttons
    const approveButtons = document.querySelectorAll('.approve-btn');
    const rejectButtons = document.querySelectorAll('.reject-btn');

    approveButtons.forEach(button => {
        button.addEventListener('click', function() {
            const reviewId = this.getAttribute('data-id');
            processReviewAction(reviewId, 'APPROVED');
        });
    });

    rejectButtons.forEach(button => {
        button.addEventListener('click', function() {
            const reviewId = this.getAttribute('data-id');
            processReviewAction(reviewId, 'REJECTED');
        });
    });

    // Function to process review status updates
    function processReviewAction(reviewId, status) {
        // Build the complete URL with context path
        const url = `${contextPath}/review/update-status`;

        console.log(`Sending request to: ${url}`);
        console.log(`Review ID: ${reviewId}, Status: ${status}`);

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `reviewId=${reviewId}&status=${status}`
        })
        .then(response => {
            console.log('Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Response data:', data);
            if (data.success) {
                showNotification(`Review ${status.toLowerCase()} successfully`);

                // Update row status
                const row = document.querySelector(`tr[data-id="${reviewId}"]`);
                if (row) {
                    // Update status badge
                    const statusBadge = row.querySelector('.status-badge');
                    if (statusBadge) {
                        statusBadge.className = `status-badge status-${status.toLowerCase()}`;
                        statusBadge.textContent = status;
                    }

                    // Remove action buttons
                    const actionButtons = row.querySelector('.action-buttons');
                    if (actionButtons) {
                        actionButtons.innerHTML = `
                            <a href="${contextPath}/review/details?reviewId=${reviewId}" class="btn btn-sm">View</a>
                        `;
                    }
                }
            } else {
                showNotification(data.message || 'Failed to update review', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating review:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }

    function processBulkAction(reviewIds, action) {
        fetch(`${contextPath}/review/bulk-action`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                ids: reviewIds,
                action: action
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification(`${data.processedCount} reviews processed successfully`);

                // Remove deleted/processed rows
                if (action === 'delete') {
                    reviewIds.forEach(id => {
                        const row = document.querySelector(`tr[data-id="${id}"]`);
                        if (row) row.remove();
                    });
                } else {
                    // Reload page for other actions
                    window.location.reload();
                }
            } else {
                showNotification(data.message || 'Failed to process bulk action', 'error');
            }
        })
        .catch(error => {
            console.error('Error processing bulk action:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }

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
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />