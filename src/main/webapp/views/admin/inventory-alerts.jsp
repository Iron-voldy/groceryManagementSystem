<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Low Stock Alerts" />
    <jsp:param name="active" value="inventory" />
</jsp:include>

<div class="admin-inventory-alerts">
    <div class="page-header">
        <h1 class="page-title">Low Stock Alerts</h1>
    </div>

    <div class="table-container">
        <table class="data-table" id="low-stock-table">
            <thead>
                <tr>
                    <th>Product ID</th>
                    <th>Product Name</th>
                    <th>Current Stock</th>
                    <th>Min Stock Level</th>
                    <th>Warehouse</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="inventory" items="${lowStockInventory}">
                    <tr>
                        <td>${inventory.productId}</td>
                        <td>${inventory.productName}</td>
                        <td class="text-danger">${inventory.currentStock}</td>
                        <td>${inventory.minimumStockLevel}</td>
                        <td>${inventory.warehouseLocation}</td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/inventory/update?productId=${inventory.productId}" class="btn btn-sm btn-warning">Restock</a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty lowStockInventory}">
                    <tr>
                        <td colspan="6" class="text-center">No low stock items found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/views/common/admin-footer.jsp" />