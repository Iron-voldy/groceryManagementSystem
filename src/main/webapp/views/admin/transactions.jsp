<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Transactions" />
    <jsp:param name="active" value="transactions" />
    <jsp:param name="useCharts" value="true" />
</jsp:include>

<div class="admin-transactions">
    <div class="page-header">
        <h1 class="page-title">Transactions</h1>
        <div class="page-actions">
            <button onclick="downloadTransactionReport()" class="btn btn-secondary">
                <i class="fas fa-download">⬇️</i> Download Report
            </button>
        </div>
    </div>

    <!-- Transaction Statistics -->
    <div class="transaction-stats-grid">
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-content">
                <h3 class="stat-title">Total Revenue</h3>
                <div class="stat-value">
                    $<fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0.00"/>
                </div>
                <div class="stat-change">All Transactions</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
                <h3 class="stat-title">Successful Transactions</h3>
                <div class="stat-value">${stats.successfulCount}</div>
                <div class="stat-change">${stats.successfulPercentage}%</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">❌</div>
            <div class="stat-content">
                <h3 class="stat-title">Failed Transactions</h3>
                <div class="stat-value">${stats.failedCount}</div>
                <div class="stat-change">${stats.failedPercentage}%</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">💸</div>
            <div class="stat-content">
                                             <h3 class="stat-title">Refunded Amount</h3>
                                             <div class="stat-value">
                                                 $<fmt:formatNumber value="${stats.refundedAmount}" pattern="#,##0.00"/>
                                             </div>
                                             <div class="stat-change">Total Refunds</div>
                                         </div>
                                     </div>
                                 </div>

                                 <!-- Charts Section -->
                                 <div class="charts-section">
                                     <div class="chart-card">
                                         <h3 class="card-title">Transaction Trends</h3>
                                         <div class="chart-container">
                                             <canvas id="transaction-chart" height="300"
                                                 data-chart='${requestScope.transactionChartData}'>
                                             </canvas>
                                         </div>
                                     </div>

                                     <div class="chart-card">
                                         <h3 class="card-title">Payment Method Distribution</h3>
                                         <div class="chart-container">
                                             <canvas id="payment-methods-chart" height="300"
                                                 data-chart='${requestScope.paymentMethodChartData}'>
                                             </canvas>
                                         </div>
                                     </div>
                                 </div>

                                 <!-- Filter and Search -->
                                 <div class="filter-section">
                                     <form id="filter-form" action="${pageContext.request.contextPath}/transaction/list" method="get">
                                         <div class="filter-row">
                                             <div class="filter-group">
                                                 <input type="text" name="searchTerm" placeholder="Search transactions..."
                                                        value="${param.searchTerm}">
                                             </div>

                                             <div class="filter-group">
                                                 <select name="status">
                                                     <option value="">All Statuses</option>
                                                     <option value="SUCCESSFUL" ${param.status == 'SUCCESSFUL' ? 'selected' : ''}>
                                                         Successful
                                                     </option>
                                                     <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>
                                                         Failed
                                                     </option>
                                                     <option value="REFUNDED" ${param.status == 'REFUNDED' ? 'selected' : ''}>
                                                         Refunded
                                                     </option>
                                                 </select>
                                             </div>

                                             <div class="filter-group">
                                                 <select name="paymentMethod">
                                                     <option value="">All Payment Methods</option>
                                                     <option value="CREDIT_CARD" ${param.paymentMethod == 'CREDIT_CARD' ? 'selected' : ''}>
                                                         Credit Card
                                                     </option>
                                                     <option value="DEBIT_CARD" ${param.paymentMethod == 'DEBIT_CARD' ? 'selected' : ''}>
                                                         Debit Card
                                                     </option>
                                                     <option value="NET_BANKING" ${param.paymentMethod == 'NET_BANKING' ? 'selected' : ''}>
                                                         Net Banking
                                                     </option>
                                                     <option value="DIGITAL_WALLET" ${param.paymentMethod == 'DIGITAL_WALLET' ? 'selected' : ''}>
                                                         Digital Wallet
                                                     </option>
                                                 </select>
                                             </div>

                                             <div class="filter-group date-range-picker">
                                                 <input type="date" name="startDate" placeholder="Start Date"
                                                        class="start-date" value="${param.startDate}">
                                                 <span>to</span>
                                                 <input type="date" name="endDate" placeholder="End Date"
                                                        class="end-date" value="${param.endDate}">
                                             </div>

                                             <div class="filter-actions">
                                                 <button type="submit" class="btn btn-primary">Apply</button>
                                                 <a href="${pageContext.request.contextPath}/transaction/list" class="btn btn-secondary">
                                                     Reset
                                                 </a>
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
                                                 <tr data-id="${transaction.transactionId}"
                                                     class="status-${transaction.status.toLowerCase()}">
                                                     <td>
                                                         <input type="checkbox" name="selected-items"
                                                                value="${transaction.transactionId}">
                                                     </td>
                                                     <td>${transaction.transactionId.substring(0, 8)}</td>
                                                     <td>${transaction.orderId.substring(0, 8)}</td>
                                                     <td data-amount="${transaction.amount}">
                                                         $<fmt:formatNumber value="${transaction.amount}" pattern="#,##0.00"/>
                                                     </td>
                                                     <td>
                                                         <span class="payment-method-badge
                                                             method-${transaction.paymentMethod.toLowerCase().replace('_', '-')}">
                                                             ${transaction.paymentMethod.replace('_', ' ')}
                                                         </span>
                                                     </td>
                                                     <td>
                                                         <span class="status-badge status-${transaction.status.toLowerCase()}">
                                                             ${transaction.status}
                                                         </span>
                                                     </td>
                                                     <td data-date="${transaction.transactionDate.getTime()}">
                                                         <fmt:formatDate value="${transaction.transactionDate}"
                                                                         pattern="MMM d, yyyy" />
                                                         <span class="transaction-time">
                                                             <fmt:formatDate value="${transaction.transactionDate}"
                                                                             pattern="h:mm a" />
                                                         </span>
                                                     </td>
                                                     <td>
                                                         <div class="action-buttons">
                                                             <a href="${pageContext.request.contextPath}/transaction/details?transactionId=${transaction.transactionId}"
                                                                class="btn btn-sm">View</a>
                                                             <c:if test="${transaction.status == 'SUCCESSFUL'}">
                                                                 <a href="${pageContext.request.contextPath}/transaction/refund?transactionId=${transaction.transactionId}"
                                                                    class="btn btn-sm btn-danger">Refund</a>
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
                                             <a href="${pageContext.request.contextPath}/transaction/list?page=${pageNum}
                                                 ${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}
                                                 ${not empty param.status ? '&status='.concat(param.status) : ''}
                                                 ${not empty param.paymentMethod ? '&paymentMethod='.concat(param.paymentMethod) : ''}
                                                 ${not empty param.startDate ? '&startDate='.concat(param.startDate) : ''}
                                                 ${not empty param.endDate ? '&endDate='.concat(param.endDate) : ''}"
                                                class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
                                         </c:forEach>
                                     </div>
                                 </c:if>
                             </div>

                             <style>
                             .admin-transactions {
                                 padding-bottom: 40px;
                             }

                             .transaction-stats-grid {
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

                             .charts-section {
                                 display: grid;
                                 grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
                                 gap: 20px;
                                 margin-bottom: 30px;
                             }

                             .chart-card {
                                 background-color: var(--dark-surface);
                                 border-radius: var(--border-radius);
                                 padding: 20px;
                                 box-shadow: var(--card-shadow);
                             }

                             .chart-container {
                                 height: 300px;
                                 position: relative;
                             }

                             .payment-method-badge {
                                 display: inline-block;
                                 padding: 5px 10px;
                                 border-radius: 20px;
                                 font-size: 12px;
                             }

                             .method-credit-card {
                                 background-color: rgba(156, 39, 176, 0.2);
                                 color: #9c27b0;
                             }

                             .method-debit-card {
                                 background-color: rgba(76, 175, 80, 0.2);
                                 color: var(--success);
                             }

                             .method-net-banking {
                                 background-color: rgba(33, 150, 243, 0.2);
                                 color: var(--info);
                             }

                             .method-digital-wallet {
                                 background-color: rgba(255, 152, 0, 0.2);
                                 color: var(--warning);
                             }

                             .status-badge {
                                 display: inline-block;
                                 padding: 5px 10px;
                                 border-radius: 20px;
                                 font-size: 12px;
                                 text-transform: uppercase;
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
                             </style>

                             <script>
                             document.addEventListener('DOMContentLoaded', function() {
                                 // Download transaction report
                                 window.downloadTransactionReport = function() {
                                     window.location.href = `${contextPath}/transaction/download-report`;
                                 };

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

                                 // Charts initialization (if Chart.js is loaded)
                                 if (typeof Chart !== 'undefined') {
                                     // Transaction Trends Chart
                                     const transactionChartElement = document.getElementById('transaction-chart');
                                     if (transactionChartElement) {
                                         const chartData = JSON.parse(transactionChartElement.getAttribute('data-chart'));
                                         new Chart(transactionChartElement, {
                                             type: 'line',
                                             data: chartData,
                                             options: {
                                                 responsive: true,
                                                 maintainAspectRatio: false,
                                                 scales: {
                                                     y: {
                                                         beginAtZero: true
                                                     }
                                                 }
                                             }
                                         });
                                     }

                                     // Payment Methods Chart
                                     const paymentMethodsChartElement = document.getElementById('payment-methods-chart');
                                     if (paymentMethodsChartElement) {
                                         const chartData = JSON.parse(paymentMethodsChartElement.getAttribute('data-chart'));
                                         new Chart(paymentMethodsChartElement, {
                                             type: 'pie',
                                             data: chartData,
                                             options: {
                                                 responsive: true,
                                                 maintainAspectRatio: false
                                             }
                                         });
                                     }
                                 }
                             });
                             </script>

                             <jsp:include page="/views/common/admin-footer.jsp" />