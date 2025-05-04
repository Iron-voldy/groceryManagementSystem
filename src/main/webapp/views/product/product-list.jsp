<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Shop Products - FreshCart" />
    <jsp:param name="active" value="products" />
</jsp:include>

<main class="container product-listing-page">
    <div class="page-header">
        <c:choose>
            <c:when test="${not empty category}">
                <h1 class="page-title">${category} Products</h1>
                <p class="page-description">Browse our selection of high-quality ${fn:toLowerCase(category)}</p>
            </c:when>
            <c:otherwise>
                <h1 class="page-title">All Products</h1>
                <p class="page-description">Browse our complete inventory of fresh groceries</p>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Filters & Sorting Section -->
    <div class="filters-section">
        <div class="filter-controls">
            <div class="filter-group">
                <label for="category-filter">Category</label>
                <select id="category-filter" class="form-control" onchange="filterByCategory(this.value)">
                    <option value="">All Categories</option>
                    <option value="Fresh Products" ${category eq 'Fresh Products' ? 'selected' : ''}>Fresh Products</option>
                    <option value="Dairy" ${category eq 'Dairy' ? 'selected' : ''}>Dairy</option>
                    <option value="Vegetables" ${category eq 'Vegetables' ? 'selected' : ''}>Vegetables</option>
                    <option value="Fruits" ${category eq 'Fruits' ? 'selected' : ''}>Fruits</option>
                    <option value="Pantry Items" ${category eq 'Pantry Items' ? 'selected' : ''}>Pantry Items</option>
                </select>
            </div>
        </div>

        <div class="sort-controls">
            <span class="sort-label">Sort by:</span>
            <div class="sort-options">
                <a href="#" class="sort-option ${currentSortBy eq 'name' ? 'active' : ''}"
                   onclick="setSorting('name', '${currentSortBy eq 'name' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')">
                    Name
                    <c:if test="${currentSortBy eq 'name'}">
                        <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                    </c:if>
                </a>
                <a href="#" class="sort-option ${currentSortBy eq 'category' ? 'active' : ''}"
                   onclick="setSorting('category', '${currentSortBy eq 'category' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')">
                    Category
                    <c:if test="${currentSortBy eq 'category'}">
                        <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                    </c:if>
                </a>
                <a href="#" class="sort-option ${currentSortBy eq 'price' ? 'active' : ''}"
                   onclick="setSorting('price', '${currentSortBy eq 'price' && currentSortOrder eq 'asc' ? 'desc' : 'asc'}')">
                    Price
                    <c:if test="${currentSortBy eq 'price'}">
                        <i class="fas fa-sort-${currentSortOrder eq 'asc' ? 'up' : 'down'}"></i>
                    </c:if>
                </a>
            </div>
        </div>
    </div>

    <!-- Sorting Information -->
    <div class="sort-info">
        <p>
            <c:if test="${not empty currentSortBy}">
                Sorted by: <strong>${currentSortBy}</strong>
                <c:if test="${not empty currentSortOrder}">
                    (${currentSortOrder eq 'asc' ? 'ascending' : 'descending'})
                </c:if>
            </c:if>
        </p>
    </div>

    <!-- Products Grid -->
    <div class="products-section">
        <c:choose>
            <c:when test="${not empty products}">
                <div class="products-grid">
                    <c:forEach var="product" items="${products}">
                        <div class="product-card">
                            <div class="product-badge ${product.stockQuantity < 10 ? 'low-stock' : ''}">
                                ${product.stockQuantity < 10 ? 'Low Stock' : 'In Stock'}
                            </div>
                            <a href="<c:url value='/product/details?productId=${product.productId}'/>" class="product-img-container">
                                <c:choose>
                                    <c:when test="${not empty product.imagePath}">
                                        <img src="${pageContext.request.contextPath}${product.imagePath}" alt="${product.name}" class="product-img">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/assets/images/product-placeholder.jpg" alt="${product.name}" class="product-img">
                                    </c:otherwise>
                                </c:choose>
                            </a>
                            <div class="product-info">
                                <a href="<c:url value='/product/category?category=${product.category}'/>" class="product-category">${product.category}</a>
                                <h3 class="product-name">
                                    <a href="<c:url value='/product/details?productId=${product.productId}'/>">${product.name}</a>
                                </h3>
                                <div class="product-price">
                                    <span class="current-price">$<fmt:formatNumber value="${product.price}" pattern="#,##0.00"/></span>
                                </div>
                                <div class="product-description">
                                    <p>${fn:substring(product.description, 0, 60)}${fn:length(product.description) > 60 ? '...' : ''}</p>
                                </div>
                                <div class="product-actions">
                                    <button onclick="addToCart('${product.productId}', 1)" class="btn btn-primary btn-add-cart">
                                        <i class="fas fa-cart-plus"></i> Add to Cart
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="no-products">
                    <p>No products found${not empty category ? ' in category ' : ''}${not empty category ? category : ''}.</p>
                    <a href="<c:url value='/product/list'/>" class="btn btn-primary">View All Products</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<style>
/* Product Listing Styles */
.product-listing-page {
    padding: 2rem 0;
}

.page-header {
    text-align: center;
    margin-bottom: 2rem;
}

.page-title {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    color: #333;
}

.page-description {
    color: #6c757d;
    font-size: 1.1rem;
    max-width: 600px;
    margin: 0 auto;
}

.filters-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding: 1rem;
    background-color: #f8f9fa;
    border-radius: 10px;
}

.filter-controls, .sort-controls {
    display: flex;
    align-items: center;
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
    border: 1px solid #dee2e6;
    border-radius: 5px;
    min-width: 150px;
}

.sort-label {
    font-weight: 600;
    color: #6c757d;
}

.sort-options {
    display: flex;
    gap: 1rem;
}

.sort-option {
    padding: 0.5rem 1rem;
    border-radius: 20px;
    background-color: #fff;
    color: #6c757d;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.sort-option:hover {
    background-color: #e9ecef;
    color: #495057;
}

.sort-option.active {
    background-color: #4CAF50;
    color: white;
}

.sort-info {
    margin-bottom: 1.5rem;
    color: #6c757d;
    font-size: 0.9rem;
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 2rem;
}

.product-card {
    background-color: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    position: relative;
}

.product-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
}

.product-badge {
    position: absolute;
    top: 1rem;
    right: 1rem;
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 700;
    background-color: #4CAF50;
    color: white;
    z-index: 2;
}

.product-badge.low-stock {
    background-color: #FFC107;
    color: #212529;
}

.product-img-container {
    display: block;
    height: 200px;
    overflow: hidden;
}

.product-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
}

.product-card:hover .product-img {
    transform: scale(1.1);
}

.product-info {
    padding: 1.5rem;
}

.product-category {
    display: inline-block;
    font-size: 0.8rem;
    color: #6c757d;
    margin-bottom: 0.5rem;
    text-decoration: none;
}

.product-category:hover {
    text-decoration: underline;
}

.product-name {
    font-size: 1.2rem;
    margin-bottom: 0.75rem;
}

.product-name a {
    color: #212529;
    text-decoration: none;
    transition: color 0.3s ease;
}

.product-name a:hover {
    color: #4CAF50;
}

.product-price {
    margin-bottom: 0.75rem;
}

.current-price {
    font-size: 1.5rem;
    font-weight: 700;
    color: #4CAF50;
}

.product-description {
    color: #6c757d;
    font-size: 0.9rem;
    margin-bottom: 1rem;
    height: 40px;
    overflow: hidden;
}

.product-actions {
    display: flex;
    justify-content: center;
}

.btn-add-cart {
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 5px;
    font-weight: 600;
    transition: background-color 0.3s ease;
    cursor: pointer;
}

.btn-add-cart:hover {
    background-color: #388E3C;
}

.no-products {
    text-align: center;
    padding: 3rem;
    background-color: #f8f9fa;
    border-radius: 10px;
    color: #6c757d;
}

.no-products p {
    font-size: 1.1rem;
    }

    .no-products .btn {
        background-color: #4CAF50;
        color: white;
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: 5px;
        text-decoration: none;
        font-weight: 600;
        transition: background-color 0.3s ease;
    }

    .no-products .btn:hover {
        background-color: #388E3C;
    }

    @media (max-width: 768px) {
        .filters-section {
            flex-direction: column;
            gap: 1rem;
            align-items: flex-start;
        }

        .page-title {
            font-size: 2rem;
        }

        .products-grid {
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        }
    }
    </style>

    <script>
    // Function to add product to cart
    function addToCart(productId, quantity) {
        // Check if user is logged in
        const isLoggedIn = ${not empty sessionScope.user};

        if (!isLoggedIn) {
            window.location.href = "${pageContext.request.contextPath}/views/user/login.jsp";
            return;
        }

        fetch(`${pageContext.request.contextPath}/cart/add`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `productId=${productId}&quantity=${quantity}`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('Product added to cart', 'success');
                updateCartCount(data.cartItemCount);
            } else {
                showNotification(data.message || 'Failed to add product to cart', 'error');
            }
        })
        .catch(error => {
            console.error('Error adding to cart:', error);
            showNotification('An error occurred. Please try again.', 'error');
        });
    }

    // Function to show notification
    function showNotification(message, type) {
        const notificationContainer = document.getElementById('notification-container') || createNotificationContainer();

        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;

        const icon = type === 'success' ? '<i class="fas fa-check-circle"></i>' : '<i class="fas fa-exclamation-circle"></i>';
        notification.innerHTML = `${icon} ${message}`;

        notificationContainer.appendChild(notification);

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

    // Function to create notification container if it doesn't exist
    function createNotificationContainer() {
        const container = document.createElement('div');
        container.id = 'notification-container';
        container.className = 'notification-container';
        document.body.appendChild(container);
        return container;
    }

    // Function to update cart count
    function updateCartCount(count) {
        const cartCountElements = document.querySelectorAll('.cart-count');
        cartCountElements.forEach(element => {
            element.textContent = count;
            if (count > 0) {
                element.classList.add('has-items');
            } else {
                element.classList.remove('has-items');
            }
        });
    }

    // Function to filter by category
    function filterByCategory(category) {
        if (category) {
            window.location.href = "${pageContext.request.contextPath}/product/category?category=" + encodeURIComponent(category);
        } else {
            window.location.href = "${pageContext.request.contextPath}/product/list";
        }
    }

    // Function to set sorting
    function setSorting(sortBy, sortOrder) {
        const urlParams = new URLSearchParams(window.location.search);

        // Keep existing parameters
        const category = urlParams.get('category');
        const searchTerm = urlParams.get('searchTerm');

        // Build redirect URL
        let url = "${pageContext.request.contextPath}/product/sort?sortBy=" + sortBy + "&sortOrder=" + sortOrder;

        if (category) {
            url += "&category=" + encodeURIComponent(category);
        }

        if (searchTerm) {
            url += "&searchTerm=" + encodeURIComponent(searchTerm);
        }

        window.location.href = url;
    }
    </script>

    <jsp:include page="/views/common/footer.jsp" />