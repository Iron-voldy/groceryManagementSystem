<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Add Inventory" />
    <jsp:param name="active" value="inventory" />
</jsp:include>

<div class="container inventory-form">
    <div class="card">
        <div class="card-header">
            <h2>Add Inventory Record</h2>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/inventory/add" method="post">
                <div class="form-group">
                    <label for="productId">Product</label>
                    <select id="productId" name="productId" class="form-control" required>
                        <option value="">Select Product</option>
                        <c:forEach var="product" items="${products}">
                            <option value="${product.productId}">${product.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="currentStock">Current Stock</label>
                    <input type="number" id="currentStock" name="currentStock"
                           class="form-control" required min="0">
                </div>

                <div class="form-group">
                    <label for="minimumStockLevel">Minimum Stock Level</label>
                    <input type="number" id="minimumStockLevel" name="minimumStockLevel"
                           class="form-control" required min="0">
                </div>

                <div class="form-group">
                    <label for="maximumStockLevel">Maximum Stock Level</label>
                    <input type="number" id="maximumStockLevel" name="maximumStockLevel"
                           class="form-control" required min="1">
                </div>

                <div class="form-group">
                    <label for="warehouseLocation">Warehouse Location</label>
                    <select id="warehouseLocation" name="warehouseLocation" class="form-control" required>
                        <option value="Main Warehouse">Main Warehouse</option>
                        <option value="North Warehouse">North Warehouse</option>
                        <option value="South Warehouse">South Warehouse</option>
                        <option value="East Warehouse">East Warehouse</option>
                        <option value="West Warehouse">West Warehouse</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Inventory</button>
                    <a href="${pageContext.request.contextPath}/inventory/list" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
.inventory-form .card {
    max-width: 600px;
    margin: 0 auto;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.inventory-form .card-header {
    background-color: var(--dark-surface-hover);
    padding: 15px;
    border-bottom: 1px solid #333;
}

.inventory-form .card-body {
    padding: 20px;
}

.inventory-form .form-group {
    margin-bottom: 15px;
}

.inventory-form label {
    display: block;
    margin-bottom: 5px;
}

.inventory-form .form-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
}
</style>

<jsp:include page="/views/common/admin-footer.jsp" />