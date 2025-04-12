<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Transactions" />
    <jsp:param name="active" value="transactions" />
</jsp:include>

<div class="admin-transactions">
    <div class="page-header">
        <h1 class="page-title">Transactions</h1>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/transaction/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="searchTerm" placeholder="Search by Transaction ID or Order ID..." value="${param.searchTerm}">
                </div>

                <div class="filter-group">
                    <select name="status">
                        <option value="">All Statuses</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="SUCCESSFUL" ${param.status == 'SUCCESSFUL' ? 'selected' : ''}>Successful</option>
                        <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>Failed</option>
                        <option value="REFUNDED" ${param.status == 'REFUNDED' ? 'selected' : ''}>Refunded</option>
                    </select>
                </div>

                <div class="filter-group">
                    <select name="paymentMethod">
                        <option value="">All Payment Methods</option>
                        <option value="CREDIT_CARD" ${param.paymentMethod == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                        <option value="DEBIT_CARD" ${param.paymentMethod == 'DEBIT_CARD' ? 'selected' : ''}>Debit Card</option>
                        <option value="NET_BANKING" ${param.paymentMethod == 'NET_BANKING' ? 'selected' : ''}>Net Banking</option>
                        <option value="DIGITAL_WALLET" ${param.paymentMethod == 'DIGITAL_WALLET' ? 'selected' : ''}>Digital Wallet</option>
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
                        <option value="amount-desc" ${param.sort == 'amount-desc' ? 'selected' : ''}>Amount (High to Low)</option>
                        <option value="amount-asc" ${param.sort == 'amount-asc' ? 'selected' : ''}>Amount (Low to High)</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/transaction/list" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <!-- Transactions Table -->
    <div class="table-container">
        <table class="data-table" id="transactions-table" data-item-type="transaction">
            <thead>
                <tr>
                    <th width="30">
                        <input type="checkbox" id="select-all">
                    </th>
                    <th data-sort="id">Transaction ID</th>
                    <th data-sort="order">Order ID</th>
                    <th data-sort="amount">Amount</th>
                    <th data-sort="method">Payment Method</th>
                    <th data-sort="status">Status</th>
                    <th data-sort="date" data-default-sort="desc">Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="transaction" items="${transactions}">
                    <tr data-id="${transaction.transactionId}" class="status-${transaction.status.toLowerCase()}">
                        <td>
                            <input type="checkbox" name="selected-items" value="${transaction.transactionId}">
                        </td>
                        <td>${transaction.transactionId.substring(0, 8)}</td>
                        <td>${transaction.orderId.substring(0, 8)}</td>
                        <td data-amount="${transaction.amount}">$<fmt:formatNumber value="${transaction.amount}" pattern="#,##0.00"/></td>
                        <td>
                            <span class="payment-method-badge method-${transaction.paymentMethod.toLowerCase()}">
                                ${transaction.paymentMethod.replace('_', ' ')}
                            </span>
                        </td>
                        <td>
                            <span class="status-badge status-${transaction.status.toLowerCase()}">${transaction.status}</span>
                        </td>
                        <td data-date="${transaction.transactionDate.getTime()}">
                            <fmt:formatDate value="${transaction.transactionDate}" pattern="MMM d, yyyy" />
                            <span class="transaction-time"><fmt:formatDate value="${transaction.transactionDate}" pattern="h:mm a" /></span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/transaction/details?transactionId=${transaction.transactionId}" class="btn btn-sm">View</a>
                                <c:if test="${transaction.status == 'SUCCESSFUL'}">
                                    <a href="${pageContext.request.contextPath}/transaction/refund?transactionId=${transaction.transactionId}" class="btn btn-sm btn-danger">Refund</a>
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
                <a href="${pageContext.request.contextPath}/transaction/list?page=${pageNum}${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}${not empty param.paymentMethod ? '&paymentMethod='.concat(param.paymentMethod) : ''}${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}${not empty param.sort ? '&sort='.concat(param.sort) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>

    <!-- Transaction Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-title">Total Transactions</div>
            <div class="stat-value">${stats.totalCount}</div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Total Revenue</div>
            <div class="stat-value">$<fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0.00"/></div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Successful</div>
            <div class="stat-value">${stats.successfulCount} (${stats.successfulPercentage}%)</div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Failed</div>
            <div class="stat-value">${stats.failedCount} (${stats.failedPercentage}%)</div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Refunded</div>
            <div class="stat-value">$<fmt:formatNumber value="${stats.refundedAmount}" pattern="#,##0.00"/></div>
        </div>
    </div>
</div>

<style>
.admin-transactions {
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

.table-container {
    margin-bottom: 30px;
}

/* Status styles */
tr.status-pending {
    border-left: 3px solid var(--warning);
}

tr.status-successful {
    border-left: 3px solid var(--success);
}

tr.status-failed {
    border-left: 3px solid var(--danger);
}

tr.status-refunded {
    border-left: 3px solid var(--info);
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

.status-successful {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.status-failed {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.status-refunded {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.payment-method-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
}

.method-credit_card {
    background-color: rgba(156, 39, 176, 0.2);
    color: #9c27b0;
}

.method-debit_card {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.method-net_banking {
    background-color: rgba(33, 150, 243, 0.2);
    color: var(--info);
}

.method-digital_wallet {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.transaction-time {
    display: block;
    font-size: 12px;
    color: var(--light-text);
}

.action-buttons {
    display: flex;
    gap: 5px;
}

.stats-row {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 20px;
}

.stat-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 20px;
    box-shadow: var(--card-shadow);
    text-align: center;
}

.stat-title {
    margin-bottom: 10px;
    color: var(--light-text);
    font-size: 14px;
}

.stat-value {
    font-size: 24px;
    font-weight: 600;
    color: var(--dark-text);
}

/* Responsive */
@media (max-width: 768px) {
    .filter-row {
        flex-direction: column;
    }

    .filter-group, .filter-actions {
        width: 100%;
    }

    .date-range-picker {
        flex-direction: column;
    }

    .stats-row {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Select all checkbox functionality
    const selectAllCheckbox = document.getElementById('select-all');
    const checkboxes = document.querySelectorAll('input[name="selected-items"]');

    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });
    }

    // Check if any individual checkbox is unchecked, then uncheck the "select all" checkbox
    checkboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            if (!this.checked && selectAllCheckbox.checked) {
                selectAllCheckbox.checked = false;
            } else if (this.checked) {
                // Check if all individual checkboxes are checked
                const allChecked = Array.from(checkboxes).every(c => c.checked);
                selectAllCheckbox.checked = allChecked;
            }
        });
    });

    // Date range picker validation
    const startDateInput = document.querySelector('.start-date');
    const endDateInput = document.querySelector('.end-date');

    if (startDateInput && endDateInput) {
        startDateInput.addEventListener('change', function() {
            if (endDateInput.value && new Date(endDateInput.value) < new Date(this.value)) {
                endDateInput.value = this.value;
            }
        });

        endDateInput.addEventListener('change', function() {
            if (startDateInput.value && new Date(startDateInput.value) > new Date(this.value)) {
                alert('End date cannot be earlier than start date');
                this.value = startDateInput.value;
            }
        });
    }
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />