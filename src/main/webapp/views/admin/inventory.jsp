<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Inventory Management" />
    <jsp:param name="active" value="inventory" />
</jsp:include>


<div class="admin-inventory">
    <div class="page-header">
        <h1 class="page-title">Inventory Management</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/inventory/add" class="btn btn-primary">
                <i class="fas fa-plus">+</i> Add Inventory
            </a>
            <a href="${pageContext.request.contextPath}/inventory/low-stock" class="btn btn-warning">
                <i class="fas fa-exclamation-triangle">⚠️</i> Low Stock Alerts
            </a>
        </div>
    </div>

    <div class="table-container">
        <table class="data-table" id="inventory-table">
            <thead>
                <tr>
                    <th>Product ID</th>
                    <th>Product Name</th>
                    <th>Current Stock</th>
                    <th>Min Stock Level</th>
                    <th>Max Stock Level</th>
                    <th>Warehouse</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="inventory" items="${inventoryList}">
                    <tr>
                        <td>${inventory.productId}</td>
                        <td>${inventory.productName}</td>
                        <td>${inventory.currentStock}</td>
                        <td>${inventory.minimumStockLevel}</td>
                        <td>${inventory.maximumStockLevel}</td>
                        <td>${inventory.warehouseLocation}</td>
                        <td>
                            <span class="status-badge status-${fn:toLowerCase(inventory.status)}">
                                ${inventory.status}
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/inventory/details?productId=${inventory.productId}" class="btn btn-sm">View</a>
                                <a href="${pageContext.request.contextPath}/inventory/update?productId=${inventory.productId}" class="btn btn-sm btn-primary">Edit</a>
                                <button class="btn btn-sm btn-danger delete-btn" data-id="${inventory.productId}">Delete</button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<style>
    /* Similar styling to other admin pages */
    .status-badge {
        display: inline-block;
        padding: 5px 10px;
        border-radius: 20px;
        font-size: 12px;
    }
    .status-in_stock { background-color: rgba(76, 175, 80, 0.2); color: var(--success); }
    .status-low_stock { background-color: rgba(255, 152, 0, 0.2); color: var(--warning); }
    .status-out_of_stock { background-color: rgba(244, 67, 54, 0.2); color: var(--danger); }
    .status-overstocked { background-color: rgba(33, 150, 243, 0.2); color: var(--info); }
</style>

<jsp:include page="/views/common/admin-footer.jsp" />