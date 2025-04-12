<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Products" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="product-list-header">
    <h1 class="page-title">
        <c:choose>
            <c:when test="${not empty category}">
                ${category} Products
            </c:when>
            <c:when test="${not empty searchTerm}">
                Search Results for "${searchTerm}"
            </c:when>
            <c:otherwise>
                All Products
            </c:otherwise>
        </c:choose>
    </h1>

    <div class="product-filters">
        <div class="search-container">
            <form action="${pageContext.request.contextPath}/product/search" method="get">
                <input type="text" name="searchTerm" placeholder="Search products..." value="${searchTerm}">
                <button type="submit" class="search-btn">🔍</button>
            </form>
        </div>

        <div class="filter-controls">
            <div class="filter-group">
                <label for="category-filter">Category</label>
                <select id="category-filter" onchange="filterByCategory(this.value)">
                    <option value="">All Categories</option>
                    <option value="Fresh Products" ${category == 'Fresh Products' ? 'selected' : ''}>Fresh Products</option>
                    <option value="Dairy" ${category == 'Dairy' ? 'selected' : ''}>Dairy</option>
                    <option value="Vegetables" ${category == 'Vegetables' ? 'selected' : ''}>Vegetables</option>
                    <option value="Fruits" ${category == 'Fruits' ? 'selected' : ''}>Fruits</option>
                    <option value="Pantry Items" ${category == 'Pantry Items' ? 'selected' : ''}>Pantry Items</option>
                </select>
            </div>

            <div class="filter-group">
                <label for="sort-by">Sort By</label>
                <select id="sort-by" onchange="sortProducts(this.value)">
                    <option value="name-asc">Name (A-Z)</option>
                    <option value="name-desc">Name (Z-A)</option>
                    <option value="price-asc">Price (Low to High)</option>
                    <option value="price-desc">Price (High to Low)</option>
                </select>
            </div>
        </div>
    </div>
</div>

<div class="product-grid">
    <c:choose>
        <c:when test="${not empty products}">
            <c:forEach var="product" items="${products}">
                <div class="product-card">
                    <div class="product-img">
                        <!-- Product image placeholder -->
                        <div class="product-img-placeholder">${product.category.substring(0, 1)}</div>
                    </div>
                    <div class="product-details">
                        <h3 class="product-title">${product.name}</h3>
                        <div class="product-category">${product.category}</div>
                        <div class="product-price">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></div>
                        <p class="product-description">
                            ${product.description.length() > 80 ? product.description.substring(0, 80).concat('...') : product.description}
                        </p>
                        <div class="product-meta">
                            <span class="stock-info ${product.stockQuantity > 10 ? 'in-stock' : product.stockQuantity > 0 ? 'low-stock' : 'out-of-stock'}">
                                ${product.stockQuantity > 10 ? 'In Stock' : product.stockQuantity > 0 ? 'Low Stock' : 'Out of Stock'}
                            </span>
                        </div>
                        <div class="product-actions">
                            <a href="${pageContext.request.contextPath}/product/details?productId=${product.productId}" class="btn btn-sm">View Details</a>
                            <button onclick="addToCart('${product.productId}')" class="btn btn-sm btn-secondary"
                                ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                                Add to Cart
                            </button>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="no-products">
                <h3>No products found</h3>
                <p>Try adjusting your search or filter criteria.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Pagination -->
<c:if test="${not empty products && totalPages > 1}">
    <div class="pagination">
        <c:forEach begin="1" end="${totalPages}" var="pageNum">
            <a href="${pageContext.request.contextPath}/product/list?page=${pageNum}${not empty category ? '&category='.concat(category) : ''}${not empty searchTerm ? '&searchTerm='.concat(searchTerm) : ''}"
               class="${currentPage == pageNum ? 'active' : ''}">${pageNum}</a>
        </c:forEach>
    </div>
</c:if>

<style>
.product-list-header {
    margin-bottom: 30px;
}

.page-title {
    margin-bottom: 20px;
    color: var(--dark-text);
}

.product-filters {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
}

.search-container {
    position: relative;
    flex: 1;
    max-width: 400px;
}

.search-container input {
    width: 100%;
    padding-right: 40px;
}

.search-btn {
    position: absolute;
    right: 0;
    top: 0;
    height: 100%;
    width: 40px;
    background: none;
    border: none;
    cursor: pointer;
    color: var(--light-text);
}

.filter-controls {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-top: 10px;
}

.filter-group {
    display: flex;
    flex-direction: column;
}

.filter-group label {
    margin-bottom: 5px;
    font-size: 14px;
}

.product-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.product-card {
    display: flex;
    flex-direction: column;
    height: 100%;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    overflow: hidden;
    transition: var(--transition);
    box-shadow: var(--card-shadow);
}

.product-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
}

.product-img {
    position: relative;
    height: 180px;
    background-color: var(--dark-surface-hover);
    display: flex;
    justify-content: center;
    align-items: center;
}

.product-img-placeholder {
    font-size: 3rem;
    color: var(--dark-text);
}

.product-details {
    padding: 15px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.product-title {
    font-size: 18px;
    margin-bottom: 8px;
    color: var(--dark-text);
}

.product-category {
    display: inline-block;
    padding: 3px 8px;
    background-color: var(--dark-surface-hover);
    border-radius: 20px;
    font-size: 12px;
    margin-bottom: 8px;
    color: var(--light-text);
}

.product-price {
    font-size: 20px;
    font-weight: 600;
    color: var(--secondary);
    margin-bottom: 10px;
}

.product-description {
    margin-bottom: 15px;
    color: var(--light-text);
    flex-grow: 1;
}

.product-meta {
    margin-bottom: 15px;
}

.stock-info {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 20px;
    font-size: 12px;
    background-color: var(--dark-surface-hover);
}

.in-stock {
    color: var(--success);
}

.low-stock {
    color: var(--warning);
}

.out-of-stock {
    color: var(--danger);
}

.product-actions {
    display: flex;
    justify-content: space-between;
    gap: 10px;
}

.product-actions .btn {
    flex: 1;
}

.no-products {
    grid-column: 1 / -1;
    text-align: center;
    padding: 40px;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
}

@media (max-width: 768px) {
    .product-filters {
        flex-direction: column;
        align-items: stretch;
    }

    .search-container {
        max-width: none;
        margin-bottom: 15px;
    }

    .filter-controls {
        flex-direction: column;
    }
}
</style>

<script>
function filterByCategory(category) {
    if (category) {
        window.location.href = '${pageContext.request.contextPath}/product/category?category=' + encodeURIComponent(category);
    } else {
        window.location.href = '${pageContext.request.contextPath}/product/list';
    }
}

function sortProducts(sortOption) {
    // This would typically be handled server-side
    // For this demo, we're just sorting the existing products client-side
    const [field, direction] = sortOption.split('-');
    const productCards = Array.from(document.querySelectorAll('.product-card'));
    const productGrid = document.querySelector('.product-grid');

    productCards.sort((a, b) => {
        let valueA, valueB;

        if (field === 'name') {
            valueA = a.querySelector('.product-title').textContent;
            valueB = b.querySelector('.product-title').textContent;
            return direction === 'asc' ? valueA.localeCompare(valueB) : valueB.localeCompare(valueA);
        } else if (field === 'price') {
            valueA = parseFloat(a.querySelector('.product-price').textContent.replace('$', ''));
            valueB = parseFloat(b.querySelector('.product-price').textContent.replace('$', ''));
            return direction === 'asc' ? valueA - valueB : valueB - valueA;
        }

        return 0;
    });

    // Clear and append sorted cards
    productGrid.innerHTML = '';
    productCards.forEach(card => productGrid.appendChild(card));
}
</script>

<jsp:include page="/views/common/footer.jsp">
    <jsp:param name="scripts" value="main" />
</jsp:include>