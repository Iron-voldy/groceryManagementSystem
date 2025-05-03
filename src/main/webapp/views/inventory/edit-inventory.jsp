<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Edit Inventory" />
    <jsp:param name="active" value="inventory" />
</jsp:include>

<div class="container inventory-form">
    <div class="card">
        <div class="card-header">
            <h2>Edit Inventory Record</h2>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/inventory/update" method="post">
                <input type="hidden" name="inventoryId" value="${inventory.inventoryId}">

                <div class="form-group">
                    <label>Product</label>
                    <input type="text" value="${inventory.productName}" class="form-control" disabled>
                    <input type="hidden" name="productId" value="${inventory.productId}">
                </div>

                <div class="form-group">
                    <label for="currentStock">Current Stock</label>
                    <input type="number" id="currentStock" name="currentStock"
                           class="form-control" value="${inventory.currentStock}" required min="0">
                </div>

                <div class="form-group">
                    <label for="minimumStockLevel">Minimum Stock Level</label>
                    <input type="number" id="minimumStockLevel" name="minimumStockLevel"
                           class="form-control" value="${inventory.minimumStockLevel}" required min="0">
                </div>

                <div class="form-group">
                    <label for="maximumStockLevel">Maximum Stock Level</label>
                    <input type="number" id="maximumStockLevel" name="maximumStockLevel"
                           class="form-control" value="${inventory.maximumStockLevel}" required min="1">
                </div>

                <div class="form-group">
                    <label for="warehouseLocation">Warehouse Location</label>
                    <select id="warehouseLocation" name="warehouseLocation" class="form-control" required>
                        <option value="Main Warehouse" ${inventory.warehouseLocation == 'Main Warehouse' ? 'selected' : ''}>
                            Main Warehouse
                        </option>
                        <option value="North Warehouse" ${inventory.warehouseLocation == 'North Warehouse' ? 'selected' : ''}>
                            North Warehouse
                        </option>
                        <option value="South Warehouse" ${inventory.warehouseLocation == 'South Warehouse' ? 'selected' : ''}>
                            South Warehouse
                        </option>
                        <option value="East Warehouse" ${inventory.warehouseLocation == 'East Warehouse' ? 'selected' : ''}>
                            East Warehouse
                        </option>
                        <option value="West Warehouse" ${inventory.warehouseLocation == 'West Warehouse' ? 'selected' : ''}>
                            West Warehouse
                        </option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Current Status</label>
                    <span class="status-badge status-${fn:toLowerCase(inventory.status)}">
                        ${inventory.status}
                    </span>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update Inventory</button>
                    <a href="${pageContext.request.contextPath}/inventory/list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
/* Same as add-inventory.jsp */
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