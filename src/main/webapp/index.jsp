<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Home" />
    <jsp:param name="active" value="home" />
</jsp:include>

<!-- Hero Banner -->
<section class="hero-banner">
    <div class="hero-content">
        <h1>Fresh Groceries Delivered to Your Door</h1>
        <p>Shop for the finest selection of fresh produce, pantry essentials, and household items.</p>
        <a href="<c:url value='/product/list'/>" class="btn btn-lg">Shop Now</a>
    </div>
</section>

<!-- Featured Categories -->
<section class="section">
    <h2 class="section-title">Shop by Category</h2>
    <div class="categories-grid">
        <a href="<c:url value='/product/category?category=Fresh+Products'/>" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥩</div>
            <h3>Fresh Products</h3>
        </a>
        <a href="<c:url value='/product/category?category=Dairy'/>" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥛</div>
            <h3>Dairy</h3>
        </a>
        <a href="<c:url value='/product/category?category=Vegetables'/>" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥦</div>
            <h3>Vegetables</h3>
        </a>
        <a href="<c:url value='/product/category?category=Fruits'/>" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🍎</div>
            <h3>Fruits</h3>
        </a>
        <a href="<c:url value='/product/category?category=Pantry+Items'/>" class="category-card">
            <div class="category-img" style="background-color: #4a5568;">🥫</div>
            <h3>Pantry Items</h3>
        </a>
    </div>
</section>

<!-- Featured Products -->
<section class="section">
    <h2 class="section-title">Featured Products</h2>
    <div class="grid">
        <c:forEach var="product" items="${featuredProducts}" varStatus="status">
            <div class="product-card">
                <div class="product-img">🛒</div>
                <div class="product-details">
                    <h3 class="product-title">${product.name}</h3>
                    <div class="product-category">${product.category}</div>
                    <div class="product-price">$${product.price}</div>
                    <p class="product-description">${product.description.length() > 80 ? product.description.substring(0, 80).concat('...') : product.description}</p>
                    <div class="product-actions">
                        <a href="<c:url value='/product/details?productId=${product.productId}'/>" class="btn btn-sm">View</a>
                        <button onclick="addToCart('${product.productId}')" class="btn btn-sm btn-secondary">Add to Cart</button>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <div class="view-all-button">
        <a href="<c:url value='/product/list'/>" class="btn">View All Products</a>
    </div>
</section>

<!-- Remaining sections remain the same as in the previous index.jsp -->
<section class="section cta-section">
    <div class="cta-content">
        <h2>Ready to Start Shopping?</h2>
        <p>Join thousands of satisfied customers and experience the convenience of online grocery shopping.</p>
        <a href="<c:url value='/product/list'/>" class="btn btn-lg">Shop Now</a>
    </div>
</section>

<style>
/* Previous styles remain the same */
</style>

<script>
// Previous script remains the same
function addToCart(productId) {
    fetch(`${contextPath}/cart/add`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}&quantity=1`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Product added to cart');
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
</script>

<jsp:include page="/views/common/footer.jsp" />