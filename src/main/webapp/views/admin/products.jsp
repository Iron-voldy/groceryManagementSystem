<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Product Management - Admin Dashboard" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="admin-container">
    <div class="admin-header">
        <h1 class="admin-title">Product Management</h1>
        <div class="admin-actions">
            <a href="${pageContext.request.contextPath}/views/admin/add-product.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add New Product
            </a>
        </div>
    </div>

    <!-- Filters & Sorting Section -->
    <div class="admin-filters">
        <div class="filter-section">
            <div class="filter-group">
                <label for="category-filter">Category</label>
                <select id="category-filter" class="form-control" onchange="filterProducts('category', this.value)">
                    <option value="">All Categories</option>
                    <option value="Fresh Products" ${param.category eq 'Fresh Products' ? 'selected' : ''}>Fresh Products</option>
                    <option value="Dairy" ${param.category eq 'Dairy' ? 'selected' : ''}>Dairy</option>
                    <option value="Vegetables" ${param.category eq 'Vegetables' ? 'selected' : ''}>Vegetables</option>
                    <option value="Fruits" ${param.category eq 'Fruits' ? 'selected' : ''}>Fruits</option>
                    <option value="Pantry Items" ${param.category eq 'Pantry Items' ? 'selected' : ''}>Pantry Items</option>
                </select>
            </div>

            <div class="filter-group">
                <label for="stock-filter">Stock Status</label>
                <select id="stock-filter" class="form-control" onchange="filterProducts('stock', this.value)">
                    <option value="">All Stock Levels</option>
                    <option value="instock" ${param.stock eq 'instock' ? 'selected' : ''}>In Stock</option>
                    <option value="lowstock" ${param.stock eq 'lowstock' ? 'selected' : ''}>Low Stock (≤ 10)</option>
                    <option value="outofstock" ${param.stock eq 'outofstock' ? 'selected' : ''}>Out of Stock</option>
                </select>
            </div>
        </div>

        <div class="search-section">
            <div class="search-box">
                <input type="text" id="search-input" placeholder="Search products..." value="${param.search}">
                <button onclick="searchProducts()" class="search-btn">
                    <i class="fas fa-search"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- Sort Controls -->
    <div class="admin-sort-controls">
        <div class="sort-label">Sort by:</div>
        <div class="sort-options">
            <a href="#" onclick="sortProducts('name', '${currentSortBy eq 'name' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')"
               class="sort-option ${currentSortBy eq 'name' ? 'active' : ''}">
                Name
                <c:if test="${currentSortBy eq 'name'}">
                    <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                </c:if>
            </a>

            <a href="#" onclick="sortProducts('category', '${currentSortBy eq 'category' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')"
               class="sort-option ${currentSortBy eq 'category' ? 'active' : ''}">
                Category
                <c:if test="${currentSortBy eq 'category'}">
                    <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                </c:if>
            </a>

            <a href="#" onclick="sortProducts('price', '${currentSortBy eq 'price' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')"
               class="sort-option ${currentSortBy eq 'price' ? 'active' : ''}">
                Price
                <c:if test="${currentSortBy eq 'price'}">
                    <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                </c:if>
            </a>

            <a href="#" onclick="sortProducts('stock', '${currentSortBy eq 'stock' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')"
               class="sort-option ${currentSortBy eq 'stock' ? 'active' : ''}">
                Stock
                <c:if test="${currentSortBy eq 'stock'}">
                    <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                </c:if>
            </a>
        </div>
    </div>

    <!-- Sort Info -->
    <c:if test="${not empty currentSortBy}">
        <div class="sort-info">
            <p>
                Sorted by: <strong>${currentSortBy}</strong>
                (${currentSortOrder eq 'asc' ? 'ascending' : 'descending'})
            </p>
        </div>
    </c:if>

    <!-- Product Table -->
    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Image</th>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Last Updated</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty products}">
                        <c:forEach var="product" items="${products}">
                            <tr>
                                <td class="product-image">
                                    <c:choose>
                                        <c:when test="${not empty product.imagePath}">
                                            <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}" class="thumbnail" onerror="this.src='/uploads/images/no-image.jpg';">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="/Uploads/images/no-image.jpg" alt="No Image" class="thumbnail">
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${fn:substring(product.productId, 0, 8)}...</td>
                                <td>${product.name}</td>
                                <td>${product.category}</td>
                                <td>$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></td>
                                <td>
                                    <span class="stock-badge ${product.stockQuantity == 0 ? 'out-of-stock' : (product.stockQuantity <= 10 ? 'low-stock' : 'in-stock')}">
                                        ${product.stockQuantity}
                                    </span>
                                </td>
                                <td><fmt:formatDate value="${product.lastUpdatedAsDate}" pattern="MMM dd, yyyy" /></td>
                                <td class="actions">
                                    <div class="action-buttons">
                                        <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="btn btn-sm btn-info" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/views/admin/edit-product.jsp?productId=${product.productId}" class="btn btn-sm btn-warning" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button onclick="confirmDelete('${product.productId}', '${product.name}')" class="btn btn-sm btn-danger" title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="8" class="no-data">No products found. Try adjusting your filters or add a new product.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Pagination (if needed) -->
    <c:if test="${totalProducts > 10}">
        <div class="pagination">
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                <a href="${pageContext.request.contextPath}/admin/products?page=${pageNum}${not empty param.category ? '&category='.concat(param.category) : ''}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.stock ? '&stock='.concat(param.stock) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}${not empty param.sortOrder ? '&sortOrder='.concat(param.sortOrder) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>

    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Confirm Delete</h2>
                <span class="close" onclick="closeModal()">×</span>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete the product: <span id="deleteProductName"></span>?</p>
                <p class="warning">This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button onclick="closeModal()" class="btn btn-secondary">Cancel</button>
                <button onclick="deleteProduct()" class="btn btn-danger">Delete</button>
            </div>
        </div>
    </div>
</div>

<style>
.admin-container {
    padding: 2rem;
}

.admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.admin-title {
    font-size: 1.8rem;
    font-weight: 600;
    color: #333;
}

.admin-filters {
    display: flex;
    justify-content: space-between;
    margin-bottom: 1.5rem;
    padding: 1rem;
    background-color: #f5f7fb;
    border-radius: 10px;
}

.filter-section {
    display: flex;
    gap: 1rem;
}

.filter-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.filter-group label {
    font-size: 0.8rem;
    font-weight: 600;
    color: #6c757d;
}

.form-control {
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 5px;
    min-width: 150px;
}

.search-section {
    display: flex;
    align-items: flex-end;
}

.search-box {
    position: relative;
    min-width: 300px;
}

.search-box input {
    width: 100%;
    padding: 0.5rem 2.5rem 0.5rem 1rem;
    border: 1px solid #ddd;
    border-radius: 5px;
}

.search-btn {
    position: absolute;
    right: 0;
    top: 0;
    height: 100%;
    padding: 0 0.75rem;
    background: none;
    border: none;
    color: #6c757d;
    cursor: pointer;
}

.admin-sort-controls {
    display: flex;
    align-items: center;
    margin-bottom: 1rem;
}

.sort-label {
    font-weight: 600;
    margin-right: 1rem;
    color: #6c757d;
}

.sort-options {
    display: flex;
    gap: 0.75rem;
}

.sort-option {
    padding: 0.5rem 1rem;
    border-radius: 5px;
    background-color: #f8f9fa;
    color: #6c757d;
    text-decoration: none;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.sort-option:hover {
    background-color: #e9ecef;
}

.sort-option.active {
    background-color: #4CAF50;
    color: white;
}

.sort-info {
    margin-bottom: 1rem;
    font-size: 0.9rem;
    color: #6c757d;
}

.table-responsive {
    overflow-x: auto;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
}

.admin-table {
    width: 100%;
    border-collapse: collapse;
}

.admin-table th, .admin-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
}

.admin-table th {
    background-color: #f5f7fb;
    font-weight: 600;
    color: #333;
}

.admin-table tr:last-child td {
    border-bottom: none;
}

.admin-table tr:hover {
    background-color: #f9f9f9;
}

.thumbnail {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 5px;
}

.no-image {
    width: 50px;
    height: 50px;
    background-color: #eee;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.7rem;
    color: #999;
    border-radius: 5px;
}

.stock-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 5px;
    font-weight: 600;
    text-align: center;
    min-width: 40px;
}

.in-stock {
    background-color: rgba(76, 175, 80, 0.1);
    color: #4CAF50;
}

.low-stock {
    background-color: rgba(255, 193, 7, 0.1);
    color: #FFC107;
}

.out-of-stock {
    background-color: rgba(244, 67, 54, 0.1);
    color: #F44336;
}

.action-buttons {
    display: flex;
    gap: 0.5rem;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem 1rem;
    border-radius: 5px;
    border: none;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.3s ease;
    gap: 0.5rem;
}

.btn-sm {
    padding: 0.35rem 0.5rem;
    font-size: 0.85rem;
}

.btn-primary {
    background-color: #4CAF50;
    color: white;
}

.btn-primary:hover {
    background-color: #388E3C;
}

.btn-secondary {
    background-color: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background-color: #5a6268;
}

.btn-info {
    background-color: #17a2b8;
    color: white;
}

.btn-info:hover {
    background-color: #138496;
}

.btn-warning {
    background-color: #ffc107;
    color: #212529;
}

.btn-warning:hover {
    background-color: #e0a800;
}

.btn-danger {
    background-color: #dc3545;
    color: white;
}

.btn-danger:hover {
    background-color: #c82333;
}

.no-data {
    text-align: center;
    padding: 2rem;
    color: #6c757d;
}

.pagination {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    margin-top: 2rem;
}

.pagination a {
    padding: 0.5rem 1rem;
    border-radius: 5px;
    background-color: #f8f9fa;
    color: #6c757d;
    text-decoration: none;
}

.pagination a.active {
    background-color: #4CAF50;
    color: white;
}

.pagination a:hover {
    background-color: #e9ecef;
}

/* Modal Styles */
.modal {
    display: none;
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
}

.modal-content {
    background-color: white;
    margin: 10% auto;
    width: 500px;
    max-width: 90%;
    border-radius: 10px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
    overflow: hidden;
}

.modal-header {
    padding: 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #eee;
}

.modal-header h2 {
    margin: 0;
    font-size: 1.5rem;
    color: #333;
}

.close {
    font-size: 1.5rem;
    cursor: pointer;
}

.modal-body {
    padding: 1.5rem;
}

.modal-footer {
    padding: 1rem;
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    border-top: 1px solid #eee;
}

.warning {
    color: #dc3545;
    font-weight: 500;
}

@media (max-width: 992px) {
    .admin-filters {
        flex-direction: column;
        gap: 1rem;
    }

    .search-section {
        width: 100%;
    }

    .search-box {
        width: 100%;
    }
}
</style>

<script>
// Current product ID to delete
let currentProductIdToDelete = null;

// Function to filter products
function filterProducts(type, value) {
    const urlParams = new URLSearchParams(window.location.search);

    // Remove page parameter to reset pagination
    urlParams.delete('page');

    // Set the new filter parameter
    if (value) {
        urlParams.set(type, value);
    } else {
        urlParams.delete(type);
    }

    window.location.href = "${pageContext.request.contextPath}/admin/products?" + urlParams.toString();
}

// Function to search products
function searchProducts() {
    const searchTerm = document.getElementById('search-input').value.trim();
    const urlParams = new URLSearchParams(window.location.search);

    // Remove page parameter to reset pagination
    urlParams.delete('page');

    if (searchTerm) {
        urlParams.set('search', searchTerm);
    } else {
        urlParams.delete('search');
    }

    window.location.href = "${pageContext.request.contextPath}/admin/products?" + urlParams.toString();
}

// Function to sort products
function sortProducts(sortBy, sortOrder) {
    const urlParams = new URLSearchParams(window.location.search);

    // Remove page parameter to reset pagination
    urlParams.delete('page');

    urlParams.set('sortBy', sortBy);
    urlParams.set('sortOrder', sortOrder);

    window.location.href = "${pageContext.request.contextPath}/admin/products?" + urlParams.toString();
}

// Function to confirm delete
function confirmDelete(productId, name) {
    currentProductIdToDelete = productId;
    document.getElementById('deleteProductName').textContent = name;
    document.getElementById('deleteModal').style.display = 'block';
}

// Function to close modal
function closeModal() {
    document.getElementById('deleteModal').style.display = 'none';
    currentProductIdToDelete = null;
}

// Function to delete product
function deleteProduct() {
    if (currentProductIdToDelete) {
        fetch('${pageContext.request.contextPath}/product/delete', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'productId=' + encodeURIComponent(currentProductIdToDelete)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Remove the row from the table
                const row = document.querySelector(`tr[data-id="${currentProductIdToDelete}"]`);
                if (row) row.remove();
                showNotification('Product deleted successfully');
            } else {
                showNotification(data.message || 'Failed to delete product', 'error');
            }
        })
        .catch(error => {
            console.error('Error deleting product:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }
    closeModal();
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

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById('deleteModal');
    if (event.target === modal) {
        closeModal();
    }
}

// Add event listener to search input
document.getElementById('search-input').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        searchProducts();
    }
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />