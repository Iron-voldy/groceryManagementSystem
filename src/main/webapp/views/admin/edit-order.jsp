<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.Date" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Edit Order" />
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="container edit-order">
    <div class="page-header">
        <h1>Edit Order #${fn:substring(order.orderId, 0, 8)}</h1>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/order/update" method="post" id="edit-order-form">
        <input type="hidden" name="orderId" value="${order.orderId}">

        <div class="form-section">
            <h2>Order Information</h2>

            <div class="form-group">
                <label for="status">Order Status</label>
                <select name="status" id="status" class="form-control">
                    <option value="PENDING" ${order.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                    <option value="PROCESSING" ${order.status == 'PROCESSING' ? 'selected' : ''}>Processing</option>
                    <option value="SHIPPED" ${order.status == 'SHIPPED' ? 'selected' : ''}>Shipped</option>
                    <option value="DELIVERED" ${order.status == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                    <option value="CANCELLED" ${order.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                </select>
            </div>

            <div class="form-group">
                <label>User ID</label>
                <input type="text" class="form-control" value="${order.userId}" readonly>
            </div>

            <div class="form-group">
                <label>Order Date</label>
                <input type="text" class="form-control" value="${order.orderDate}" readonly>
            </div>
        </div>

        <div class="form-section">
            <h2>Order Items</h2>

            <div class="order-items-container">
                <c:forEach var="item" items="${order.items}" varStatus="status">
                    <div class="order-item-row">
                        <div class="form-group">
                            <label>Product</label>
                            <select name="productId" class="form-control product-select">
                                <c:forEach var="product" items="${products}">
                                    <option value="${product.productId}" ${item.productId == product.productId ? 'selected' : ''}>
                                        ${product.name} - $${product.price}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Quantity</label>
                            <input type="number" name="quantity" class="form-control" value="${item.quantity}" min="1">
                        </div>

                        <button type="button" class="btn btn-danger remove-item">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </c:forEach>
            </div>

            <button type="button" id="add-item" class="btn btn-secondary">
                <i class="fas fa-plus"></i> Add Item
            </button>
        </div>

        <div class="form-actions">
            <a href="${pageContext.request.contextPath}/order/details?orderId=${order.orderId}" class="btn btn-secondary">
                Cancel
            </a>
            <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
    </form>
</div>

<template id="item-template">
    <div class="order-item-row">
        <div class="form-group">
            <label>Product</label>
            <select name="productId" class="form-control product-select">
                <c:forEach var="product" items="${products}">
                    <option value="${product.productId}">
                        ${product.name} - $${product.price}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label>Quantity</label>
            <input type="number" name="quantity" class="form-control" value="1" min="1">
        </div>

        <button type="button" class="btn btn-danger remove-item">
            <i class="fas fa-trash"></i>
        </button>
    </div>
</template>

<style>
.edit-order {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.page-header {
    margin-bottom: 30px;
}

.form-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.form-section h2 {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    font-size: 1.5rem;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #444;
    border-radius: var(--border-radius);
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
}

.order-items-container {
    margin-bottom: 20px;
}

.order-item-row {
    display: flex;
    gap: 15px;
    align-items: flex-end;
    margin-bottom: 15px;
    padding-bottom: 15px;
    border-bottom: 1px solid #333;
}

.order-item-row .form-group {
    flex: 1;
    margin-bottom: 0;
}

.btn {
    display: inline-block;
    padding: 10px 15px;
    border-radius: var(--border-radius);
    border: none;
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    text-align: center;
}

.btn-primary {
    background-color: var(--primary-color);
    color: white;
}

.btn-secondary {
    background-color: #6c757d;
    color: white;
}

.btn-danger {
    background-color: var(--danger);
    color: white;
}

.form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 15px;
    margin-top: 30px;
}

.alert {
    padding: 15px;
    border-radius: var(--border-radius);
    margin-bottom: 20px;
}

.alert-danger {
    background-color: rgba(244, 67, 54, 0.1);
    color: #F44336;
    border: 1px solid #F44336;
}

@media (max-width: 768px) {
    .order-item-row {
        flex-direction: column;
        align-items: stretch;
        gap: 10px;
    }

    .form-actions {
        flex-direction: column-reverse;
        gap: 10px;
    }

    .form-actions .btn {
        width: 100%;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Add new item
    const addItemBtn = document.getElementById('add-item');
    const itemTemplate = document.getElementById('item-template');
    const itemsContainer = document.querySelector('.order-items-container');

    addItemBtn.addEventListener('click', function() {
        const newItem = document.importNode(itemTemplate.content, true);
        itemsContainer.appendChild(newItem);

        // Add event listener to new remove button
        const removeBtn = itemsContainer.lastElementChild.querySelector('.remove-item');
        removeBtn.addEventListener('click', removeItem);
    });

    // Remove item
    const removeButtons = document.querySelectorAll('.remove-item');
    removeButtons.forEach(btn => {
        btn.addEventListener('click', removeItem);
    });

    function removeItem() {
        this.closest('.order-item-row').remove();
    }

    // Form validation
    const form = document.getElementById('edit-order-form');
    form.addEventListener('submit', function(e) {
        const items = document.querySelectorAll('.order-item-row');

        if (items.length === 0) {
            e.preventDefault();
            alert('An order must have at least one item');
        }
    });
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />