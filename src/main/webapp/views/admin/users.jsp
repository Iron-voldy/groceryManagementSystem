<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Users" />
    <jsp:param name="active" value="users" />
</jsp:include>

<div class="admin-users">
    <div class="page-header">
        <h1 class="page-title">User Management</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/views/user/register.jsp" class="btn btn-primary">
                <i class="fas fa-plus">+</i> Add New User
            </a>
        </div>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/user/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="searchTerm" placeholder="Search users..." value="${param.searchTerm}">
                </div>

                <div class="filter-group">
                    <select name="role">
                        <option value="">All Roles</option>
                        <option value="CUSTOMER" ${param.role == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                        <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>Admin</option>
                        <option value="STAFF" ${param.role == 'STAFF' ? 'selected' : ''}>Staff</option>
                    </select>
                </div>

                <div class="filter-group">
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <div class="filter-group date-range-picker">
                    <input type="date" name="startDate" placeholder="Start Date" class="start-date" value="${param.startDate}">
                    <span>to</span>
                    <input type="date" name="endDate" placeholder="End Date" class="end-date" value="${param.endDate}">
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/user/list" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <!-- Bulk Actions -->
    <div class="bulk-actions">
        <div class="bulk-action-group">
            <select id="bulk-action">
                <option value="">Bulk Actions</option>
                <option value="activate">Activate</option>
                <option value="deactivate">Deactivate</option>
                <option value="delete">Delete</option>
            </select>
            <button id="apply-bulk-action" class="btn btn-sm">Apply</button>
        </div>

        <div id="users-table-stats" class="table-stats">
            Showing ${users.size()} of ${totalUsers} users
        </div>
    </div>

    <!-- Users Table -->
    <div class="table-container">
        <table class="data-table" id="users-table" data-item-type="user">
            <thead>
                <tr>
                    <th width="30">
                        <input type="checkbox" id="select-all">
                    </th>
                    <th data-sort="id">User ID</th>
                    <th data-sort="username" data-default-sort="asc">Username</th>
                    <th data-sort="email">Email</th>
                    <th data-sort="role">Role</th>
                    <th data-sort="registration">Registration Date</th>
                    <th data-sort="status">Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="user" items="${users}">
                    <tr data-id="${user.userId}">
                        <td>
                            <input type="checkbox" name="selected-items" value="${user.userId}">
                        </td>
                        <td>${user.userId.substring(0, 8)}</td>
                        <td>${user.username}</td>
                        <td>${user.email}</td>
                        <td>
                            <span class="role-badge role-${fn:toLowerCase(user.role.toString())}">
                                ${user.role}
                            </span>
                        </td>
                        <td data-date="${user.registrationDate.getTime()}">
                            <fmt:formatDate value="${user.registrationDate}" pattern="MMM d, yyyy" />
                        </td>
                        <td>
                            <span class="status-badge ${user.active ? 'status-active' : 'status-inactive'}">
                                ${user.active ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/views/user/edit-user.jsp?userId=${user.userId}"
                                   class="btn btn-sm">Edit</a>
                                <button class="btn btn-sm btn-danger delete-btn"
                                        data-id="${user.userId}">Delete</button>
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
                <a href="${pageContext.request.contextPath}/user/list?page=${pageNum}${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}${not empty param.role ? '&role='.concat(param.role) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>
</div>

<style>
/* Similar styling to other admin list pages */
.admin-users {
    padding-bottom: 40px;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
}

.page-title {
    margin: 0;
    color: var(--dark-text);
}

.role-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    text-transform: uppercase;
}

.role-admin {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.role-customer {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.role-staff {
    background-color: rgba(156, 39, 176, 0.2);
    color: #9c27b0;
}

.status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
}

.status-active {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-inactive {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Bulk action handling
    const bulkActionSelect = document.getElementById('bulk-action');
    const applyBulkActionBtn = document.getElementById('apply-bulk-action');

    if (bulkActionSelect && applyBulkActionBtn) {
        applyBulkActionBtn.addEventListener('click', function() {
            const selectedUsers = document.querySelectorAll('input[name="selected-items"]:checked');
            if (selectedUsers.length === 0) {
                alert('Please select at least one user');
                return;
            }

            const action = bulkActionSelect.value;
            if (!action) {
                alert('Please select an action');
                return;
            }

            const userIds = Array.from(selectedUsers).map(user => user.value);

            if (action === 'delete' && !confirm(`Are you sure you want to delete ${selectedUsers.length} selected users?`)) {
                return;
            }

            processBulkAction(userIds, action);
        });
    }

    function processBulkAction(userIds, action) {
        fetch(`${contextPath}/user/bulk-action`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                ids: userIds,
                action: action
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification(`${data.processedCount} users processed successfully`);

                // Remove deleted rows
                if (action === 'delete') {
                    userIds.forEach(id => {
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

    // Delete user functionality
    const deleteButtons = document.querySelectorAll('.delete-btn');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function() {
            const userId = this.getAttribute('data-id');
            if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
                fetch(`${contextPath}/user/delete`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `userId=${userId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('User deleted successfully');
                        // Remove the row from the table
                        const row = document.querySelector(`tr[data-id="${userId}"]`);
                        if (row) row.remove();
                    } else {
                        showNotification(data.message || 'Failed to delete user', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error deleting user:', error);
                    showNotification('An error occurred. Please try again.', 'error');
                });
            }
        });
    });

    // Notification function
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