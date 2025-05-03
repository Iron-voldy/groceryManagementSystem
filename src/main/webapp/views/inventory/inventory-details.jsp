<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Inventory Details" />
    <jsp:param name="active" value="inventory" />
</jsp:include>

<div class="container inventory-details">
    <div class="card">
        <div class="card-header">
            <h2>Inventory Details: ${inventory.productName}</h2>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <h3>Product Information</h3>
                    <table class="details-table">
                        <tr>
                            <th>Product ID</th>
                            <td>${inventory.productId}</td>
                        </tr>
                        <tr>
                            <th>Product Name</th>
                            <td>${inventory.productName}</td>
                        </tr>
                    </table>
                </div>
                <div class="col-md-6">
                    <h3>Inventory Metrics</h3>
                    <table class="details-table">
                        <tr>
                            <th>Current Stock</th>
                            <td>${inventory.currentStock}</td>
                        </tr>
                        <tr>
                            <th>Minimum Stock Level</th>
                            <td>${inventory.minimumStockLevel}</td>
                        </tr>
                        <tr>
                            <th>Maximum Stock Level</th>
                            <td>${inventory.maximumStockLevel}</td>
                        </tr>
                        <tr>
                            <th>Warehouse Location</th>
                            <td>${inventory.warehouseLocation}</td>
                        </tr>
                    </table>
                </div>
            </div>

            <div class="inventory-status">
                <h3>Inventory Status</h3>
                <span class="status-badge status-${fn:toLowerCase(inventory.status)}">
                    ${inventory.status}
                </span>
                <p class="status-description">
                    <c:choose>
                        <c:when test="${inventory.status == 'LOW_STOCK'}">
                            Your stock is running low. Consider restocking soon.
                        </c:when>
                        <c:when test="${inventory.status == 'OUT_OF_STOCK'}">
                            This product is currently out of stock.
                        </c:when>
                        <c:when test="${inventory.status == 'OVERSTOCKED'}">
                            You have more stock than the maximum recommended level.
                        </c:when>
                        <c:otherwise>
                            Stock levels are normal.
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>

            <div class="inventory-history">
                <h3>Last Updated</h3>
                <p>
                    <c:choose>
                        <c:when test="${inventory.lastUpdated != null}">
                            <%
                                java.time.LocalDateTime lastUpdated = ((com.grocerymanagement.model.Inventory)request.getAttribute("inventory")).getLastUpdated();
                                java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MMMM dd, yyyy HH:mm:ss");
                                out.print(lastUpdated.format(formatter));
                            %>
                        </c:when>
                        <c:otherwise>
                            Not available
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/inventory/update?productId=${inventory.productId}"
                   class="btn btn-primary">Edit Inventory</a>
                <a href="${pageContext.request.contextPath}/inventory/list"
                   class="btn btn-secondary">Back to Inventory</a>
            </div>
        </div>
    </div>
</div>

<style>
/* Previous styles remain the same */
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