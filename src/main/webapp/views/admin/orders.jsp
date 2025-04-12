<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Orders" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="admin-orders">
    <div class="page-header">
        <h1 class="page-title">Orders</h1>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/order/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="searchTerm" placeholder="Search by Order ID or Customer..." value="${param.searchTerm}">
                </div>

                <div class="filter-group">
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="PROCESSING" ${param.status == 'PROCESSING' ? 'selected' : ''}>Processing</option>
                        <option value="SHIPPED" ${param.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                        <option value="DELIVERED" ${param.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                        <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>

                <div class="filter-group date-range-picker">
                    <input type="date" name="startDate" placeholder="Start Date" class="start-date" value="${param.startDate}">
                    <span>to</span>
                    <input type="date" name="endDate" placeholder="End Date" class="end-date" value="${param.endDate}">
                </div>

                <div class="filter-group">
                    <select name="sort">
                        <option value="date-desc" ${param.sort == 'date-desc' ? 'selected' : ''}>Date (Newest First)</option>
                        <option value="date-asc" ${param.sort == 'date-asc' ? 'selected' : ''}>Date (Oldest First)</option>
                        <option value="total-desc" ${param.sort == 'total-desc' ? 'selected' : ''}>Amount (High to Low)</option>
                        <option value="total-asc" ${param.sort == 'total-asc' ? 'selected' : ''}>Amount (Low to High)</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/order/list" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <!-- Bulk Actions -->
    <div class="bulk-actions">
        <div class="bulk-action-group">
            <select id="bulk-action">
                <option value="">Bulk Actions</option>
                <option value="processing">Mark as Processing</option>
                <option value="shipped">Mark as Shipped</option>
                <option value="delivered">Mark as Delivered</option>
                <option value="cancelled">Mark as Cancelled</option>
            </select>
            <button id="apply-bulk-action" class="btn btn-sm">Apply</button>
        </div>

        <div id="order-table-stats" class="table-stats">
            Showing ${orders.size()} of ${totalOrders} orders
        </div>
    </div>

    <!-- Orders Table -->
    <div class="table-container">
        <table class="data-table" id="orders-table" data-item-type="order">
            <thead>
                <tr>
                    <th width="30">
                        <input type="checkbox" id="select-all">
                    </th>
                    <th data-sort="id">Order ID</th>
                    <th data-sort="customer">Customer</th>
                    <th data-sort="date" data-default-sort="desc">Date</th>
                    <th data-sort="items">Items</th>
                    <th data-sort="total">Total</th>
                    <th data-sort="status">Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${orders}">
                    <tr data-id="${order.orderId}" class="status-${order.status.toLowerCase()}">
                        <td>
                            <input type="checkbox" name="selected-items" value="${order.orderId}">
                        </td>
                        <td>${order.orderId.substring(0, 8)}</td>
                        <td>${order.userId}</td>
                        <td data-date="${order.orderDate.getTime()}">
                            <fmt:formatDate value="${order.orderDate}" pattern="MMM d, yyyy" />
                            <span class="order-time"><fmt:formatDate value="${order.orderDate}" pattern="h:mm a" /></span>
                        </td>
                        <td>${order.items.size()}</td>
                        <td data-total="${order.totalAmount}">$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                        <td>
                            <select class="status-select" data-id="${order.orderId}" data-type="order">
                                <option value="PENDING" ${order.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="PROCESSING" ${order.status == 'PROCESSING' ? 'selected' : ''}>Processing</option>
                                <option value="SHIPPED" ${order.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                                <option value="DELIVERED" ${order.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                                <option value="CANCELLED" ${order.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                            </select>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-sm">View</a>
                                <a href="${pageContext.request.contextPath}/order/invoice?orderId=${order.orderId}" class="btn btn-sm">Invoice</a>
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
                <a href="${pageContext.request.contextPath}/order/list?page=${pageNum}${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}${not empty param.sort ? '&sort='.concat(param.sort) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>
</div>

<style>
.admin-orders {
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

.filter-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: var(--card-shadow);
}

.filter-row {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    align-items: flex-end;
}

.filter-group {
    flex: 1;
    min-width: 150px;
}

.date-range-picker {
    display: flex;
    align-items: center;
    gap: 10px;
}

.date-range-picker input {
    flex: 1;
}

.date-range-picker span {
    color: var(--light-text);
}

.filter-actions {
    display: flex;
    gap: 10px;
}

.bulk-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.bulk-action-group {
    display: flex;
    gap: 10px;
    align-items: center;
}

.table-stats {
    color: var(--light-text);
}

/* Status styles */
tr.status-pending {
    border-left: 3px solid var(--warning);
}

tr.status-processing {
    border-left: 3px solid var(--info);
}

tr.status-shipped {
    border-left: 3px solid #9c27b0;
}

tr.status-delivered {
    border-left: 3px solid var(--success);
}

tr.status-cancelled {
    border-left: 3px solid var(--danger);
}

.status-select {
    padding: 5px;
    border-radius: var(--border-radius);
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
    border: 1px solid #333;
}

.order-time {
    display: block;
    font-size: 12px;
    color: var(--light-text);
}

.action-buttons {
    display: flex;
    gap: 5px;
}

/* Table sorting styles */
th[data-sort] {
    cursor: pointer;
    position: relative;
}

th[data-sort]::after {
    content: "⇅";
    position: absolute;
    right: 10px;
    color: var(--light-text);
}

th[data-sort].sort-asc::after {
    content: "↑";
    color: var(--primary);
}

th[data-sort].sort-desc::after {
    content: "↓";
    color: var(--primary);
}

/* Responsive */
@media (max-width: 768px) {
    .filter-row, .bulk-actions {
        flex-direction: column;
    }

    .filter-group, .bulk-action-group {
        width: 100%;
    }

    .action-buttons {
        flex-wrap: wrap;
    }

    .table-container {
        overflow-x: auto;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Status change handling
    const statusSelects = document.querySelectorAll('.status-select');
    statusSelects.forEach(select => {
        select.addEventListener('change', function() {
            const orderId = this.getAttribute('data-id');
            const newStatus = this.value;

            updateOrderStatus(orderId, newStatus);
        });
    });

    // Function to update order status
    function updateOrderStatus(orderId, newStatus) {
        // Show confirmation for cancellation
        if (newStatus === 'CANCELLED' && !confirm('Are you sure you want to cancel this order?')) {
            // Reset select to previous value if cancelled
            const select = document.querySelector(`.status-select[data-id="${orderId}"]`);
            const row = select.closest('tr');
            const currentStatus = row.className.replace('status-', '').toUpperCase();
            select.value = currentStatus;
            return;
        }

        fetch(`${contextPath}/order/update-status`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `orderId=${orderId}&status=${newStatus}`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification(`Order status updated to ${newStatus}`);

                // Update row class
                const row = document.querySelector(`tr[data-id="${orderId}"]`);

                // Remove old status class
                row.className = row.className.replace(/status-\w+/, '');

                // Add new status class
                row.classList.add(`status-${newStatus.toLowerCase()}`);
            } else {
                showNotification(data.message || 'Failed to update order status', 'error');

                // Reset select to previous value
                const select = document.querySelector(`.status-select[data-id="${orderId}"]`);
                const row = select.closest('tr');
                const currentStatus = row.className.replace('status-', '').toUpperCase();
                select.value = currentStatus;
            }
        })
        .catch(error => {
            console.error('Error updating order status:', error);
            showNotification('An error occurred. Please try again.', 'error');

            // Reset select to previous value
            const select = document.querySelector(`.status-select[data-id="${orderId}"]`);
            const row = select.closest('tr');
            const currentStatus = row.className.replace('status-', '').toUpperCase();
            select.value = currentStatus;
        });
    }

    // Bulk action handling
    const applyBulkActionBtn = document.getElementById('apply-bulk-action');
    if (applyBulkActionBtn) {
        applyBulkActionBtn.addEventListener('click', function() {
            const selectedOrders = document.querySelectorAll('input[name="selected-items"]:checked');
            if (selectedOrders.length === 0) {
                showNotification('Please select at least one order', 'warning');
                return;
            }

            const action = document.getElementById('bulk-action').value;
            if (!action) {
                showNotification('Please select an action', 'warning');
                return;
            }

            const orderIds = Array.from(selectedOrders).map(checkbox => checkbox.value);

            // Show confirmation for cancel action
            if (action === 'cancelled' && !confirm(`Are you sure you want to cancel ${orderIds.length} selected orders?`)) {
                return;
            }

            processBulkAction(orderIds, action.toUpperCase());
        });
    }

    function processBulkAction(orderIds, status) {
        fetch(`${contextPath}/order/bulk-update-status`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                orderIds: orderIds,
                status: status
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification(`${data.updatedCount} orders updated to ${status}`);

                // Update UI for each updated order
                orderIds.forEach(orderId => {
                    const row = document.querySelector(`tr[data-id="${orderId}"]`);
                    const statusSelect = row.querySelector('.status-select');

                    // Remove old status class
                    row.className = row.className.replace(/status-\w+/, '');

                    // Add new status class
                    row.classList.add(`status-${status.toLowerCase()}`);

                    // Update select value
                    statusSelect.value = status;
                });

                // Uncheck all checkboxes
                document.querySelectorAll('input[name="selected-items"]:checked').forEach(checkbox => {
                    checkbox.checked = false;
                });
                document.getElementById('select-all').checked = false;
            } else {
                showNotification(data.message || 'Failed to update orders', 'error');
            }
        })
        .catch(error => {
            console.error('Error processing bulk action:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }

    // "Select all" checkbox
    const selectAllCheckbox = document.getElementById('select-all');
    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('input[name="selected-items"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });
    }

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