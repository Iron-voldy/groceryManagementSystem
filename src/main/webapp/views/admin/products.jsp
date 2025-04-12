<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Manage Products" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="admin-products">
    <div class="page-header">
        <h1 class="page-title">Products</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/views/product/add-product.jsp" class="btn btn-primary">
                <i class="fas fa-plus">+</i> Add New Product
            </a>
        </div>
    </div>

    <!-- Filter and Search -->
    <div class="filter-section">
        <form id="filter-form" action="${pageContext.request.contextPath}/product/list" method="get">
            <div class="filter-row">
                <div class="filter-group">
                    <input type="text" name="searchTerm" placeholder="Search products..." value="${param.searchTerm}">
                </div>

                <div class="filter-group">
                    <select name="category">
                        <option value="">All Categories</option>
                        <option value="Fresh Products" ${param.category == 'Fresh Products' ? 'selected' : ''}>Fresh Products</option>
                        <option value="Dairy" ${param.category == 'Dairy' ? 'selected' : ''}>Dairy</option>
                        <option value="Vegetables" ${param.category == 'Vegetables' ? 'selected' : ''}>Vegetables</option>
                        <option value="Fruits" ${param.category == 'Fruits' ? 'selected' : ''}>Fruits</option>
                        <option value="Pantry Items" ${param.category == 'Pantry Items' ? 'selected' : ''}>Pantry Items</option>
                    </select>
                </div>

                <div class="filter-group">
                    <select name="stock">
                        <option value="">All Stock</option>
                        <option value="in-stock" ${param.stock == 'in-stock' ? 'selected' : ''}>In Stock</option>
                        <option value="low-stock" ${param.stock == 'low-stock' ? 'selected' : ''}>Low Stock</option>
                        <option value="out-of-stock" ${param.stock == 'out-of-stock' ? 'selected' : ''}>Out of Stock</option>
                    </select>
                </div>

                <div class="filter-group">
                    <select name="sort">
                        <option value="name-asc" ${param.sort == 'name-asc' ? 'selected' : ''}>Name (A-Z)</option>
                        <option value="name-desc" ${param.sort == 'name-desc' ? 'selected' : ''}>Name (Z-A)</option>
                        <option value="price-asc" ${param.sort == 'price-asc' ? 'selected' : ''}>Price (Low to High)</option>
                        <option value="price-desc" ${param.sort == 'price-desc' ? 'selected' : ''}>Price (High to Low)</option>
                        <option value="stock-asc" ${param.sort == 'stock-asc' ? 'selected' : ''}>Stock (Low to High)</option>
                        <option value="stock-desc" ${param.sort == 'stock-desc' ? 'selected' : ''}>Stock (High to Low)</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/product/list" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>

    <!-- Bulk Actions -->
    <div class="bulk-actions">
        <div class="bulk-action-group">
            <select id="bulk-action">
                <option value="">Bulk Actions</option>
                <option value="delete">Delete</option>
                <option value="update-stock">Update Stock</option>
                <option value="update-category">Update Category</option>
            </select>
            <button id="apply-bulk-action" class="btn btn-sm">Apply</button>
        </div>

        <div id="product-table-stats" class="table-stats">
            Showing ${products.size()} of ${totalProducts} products
        </div>
    </div>

    <!-- Products Table -->
    <div class="table-container">
        <table class="data-table" id="products-table" data-item-type="product">
            <thead>
                <tr>
                    <th width="30">
                        <input type="checkbox" id="select-all">
                    </th>
                    <th data-sort="id">ID</th>
                    <th data-sort="name" data-default-sort="asc">Product Name</th>
                    <th data-sort="category">Category</th>
                    <th data-sort="price">Price</th>
                    <th data-sort="stock">Stock</th>
                    <th data-sort="updated">Last Updated</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="product" items="${products}">
                    <tr data-id="${product.productId}">
                        <td>
                            <input type="checkbox" name="selected-items" value="${product.productId}">
                        </td>
                        <td>${product.productId.substring(0, 8)}</td>
                        <td>${product.name}</td>
                        <td>${product.category}</td>
                        <td data-price="${product.price}">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></td>
                        <td data-stock="${product.stockQuantity}">
                            <span class="stock-badge ${product.stockQuantity > 10 ? 'in-stock' : product.stockQuantity > 0 ? 'low-stock' : 'out-of-stock'}">
                                ${product.stockQuantity}
                            </span>
                        </td>
                        <td data-date="${product.lastUpdated.getTime()}">
                            <fmt:formatDate value="${product.lastUpdated}" pattern="MMM d, yyyy" />
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="btn btn-sm">View</a>
                                <a href="${pageContext.request.contextPath}/views/product/product-edit.jsp?productId=${product.productId}" class="btn btn-sm">Edit</a>
                                <button class="btn btn-sm btn-danger delete-btn" data-id="${product.productId}">Delete</button>
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
                <a href="${pageContext.request.contextPath}/product/list?page=${pageNum}${not empty param.searchTerm ? '&searchTerm='.concat(param.searchTerm) : ''}${not empty param.category ? '&category='.concat(param.category) : ''}${not empty param.stock ? '&stock='.concat(param.stock) : ''}${not empty param.sort ? '&sort='.concat(param.sort) : ''}"
                   class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
        </div>
    </c:if>

    <!-- Add/Edit Product Modal -->
    <div id="product-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modal-title">Add New Product</h2>
                <span class="close-modal">&times;</span>
            </div>
            <div class="modal-body">
                <form id="product-form" action="${pageContext.request.contextPath}/product/add" method="post" data-validate="true">
                    <input type="hidden" id="product-id" name="productId">

                    <div class="form-group">
                        <label for="name">Product Name</label>
                        <input type="text" id="name" name="name" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="category">Category</label>
                            <select id="category" name="category" required>
                                <option value="">Select Category</option>
                                <option value="Fresh Products">Fresh Products</option>
                                <option value="Dairy">Dairy</option>
                                <option value="Vegetables">Vegetables</option>
                                <option value="Fruits">Fruits</option>
                                <option value="Pantry Items">Pantry Items</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="price">Price ($)</label>
                            <input type="number" id="price" name="price" min="0.01" step="0.01" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="stockQuantity">Stock Quantity</label>
                        <input type="number" id="stockQuantity" name="stockQuantity" min="0" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" rows="4" required></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Save Product</button>
                        <button type="button" class="btn btn-secondary close-modal">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<style>
.admin-products {
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

.stock-badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 12px;
}

.in-stock {
    background-color: rgba(76, 175, 80, 0.2);
    color: var(--success);
}

.low-stock {
    background-color: rgba(255, 152, 0, 0.2);
    color: var(--warning);
}

.out-of-stock {
    background-color: rgba(244, 67, 54, 0.2);
    color: var(--danger);
}

.action-buttons {
    display: flex;
    gap: 5px;
}

/* Modal Styles */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0, 0, 0, 0.5);
}

.modal-content {
    background-color: var(--dark-surface);
    margin: 50px auto;
    border-radius: var(--border-radius);
    width: 90%;
    max-width: 600px;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
    animation: modalFadeIn 0.3s;
}

@keyframes modalFadeIn {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    border-bottom: 1px solid #333;
}

.modal-header h2 {
    margin: 0;
    font-size: 20px;
    color: var(--dark-text);
}

.close-modal {
    color: var(--light-text);
    font-size: 24px;
    cursor: pointer;
}

.close-modal:hover {
    color: var(--danger);
}

.modal-body {
    padding: 20px;
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
}
</style>

<script>
// Show/hide modal
document.addEventListener('DOMContentLoaded', function() {
    const modal = document.getElementById('product-modal');
    const addButton = document.querySelector('.page-actions .btn-primary');
    const closeButtons = document.querySelectorAll('.close-modal');

    // Show modal when add button is clicked
    if (addButton) {
        addButton.addEventListener('click', function(e) {
            e.preventDefault();
            // Reset form
            document.getElementById('product-form').reset();
            document.getElementById('product-id').value = '';
            document.getElementById('modal-title').textContent = 'Add New Product';
            document.getElementById('product-form').action = '${pageContext.request.contextPath}/product/add';

            // Show modal
            modal.style.display = 'block';
        });
    }

    // Close modal when close button is clicked
    closeButtons.forEach(button => {
        button.addEventListener('click', function() {
            modal.style.display = 'none';
        });
    });

    // Close modal when clicking outside the modal
    window.addEventListener('click', function(event) {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });

    // Edit product
    const editButtons = document.querySelectorAll('.action-buttons .btn:nth-child(2)');
    editButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const productId = this.closest('tr').getAttribute('data-id');

            // Fetch product details and populate form
            fetch(`${pageContext.request.contextPath}/product/details?productId=${productId}&format=json`)
            .then(response => response.json())
            .then(product => {
                document.getElementById('product-id').value = product.productId;
                document.getElementById('name').value = product.name;
                document.getElementById('category').value = product.category;
                document.getElementById('price').value = product.price;
                document.getElementById('stockQuantity').value = product.stockQuantity;
                document.getElementById('description').value = product.description;

                document.getElementById('modal-title').textContent = 'Edit Product';
                document.getElementById('product-form').action = '${pageContext.request.contextPath}/product/update';

                // Show modal
                modal.style.display = 'block';
            })
            .catch(error => {
                console.error('Error fetching product details:', error);
                alert('Failed to load product details. Please try again.');
            });
        });
    });

    // Delete product
    const deleteButtons = document.querySelectorAll('.delete-btn');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function() {
            const productId = this.getAttribute('data-id');
            if (confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
                window.location.href = `${pageContext.request.contextPath}/product/delete?productId=${productId}`;
            }
        });
    });
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />