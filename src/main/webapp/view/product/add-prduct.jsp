<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Add New Product" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="admin-add-product">
    <div class="page-header">
        <h1 class="page-title">Add New Product</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left">←</i> Back to Products
            </a>
        </div>
    </div>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/product/add" method="post" class="product-form" data-validate="true">
            <div class="form-card">
                <h2 class="form-card-title">Product Information</h2>

                <div class="form-group">
                    <label for="name">Product Name*</label>
                    <input type="text" id="name" name="name" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="category">Category*</label>
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
                        <label for="price">Price ($)*</label>
                        <input type="number" id="price" name="price" min="0.01" step="0.01" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="stockQuantity">Stock Quantity*</label>
                    <input type="number" id="stockQuantity" name="stockQuantity" min="0" required>
                </div>

                <div class="form-group">
                    <label for="description">Description*</label>
                    <textarea id="description" name="description" rows="6" required></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Save Product</button>
                <button type="reset" class="btn btn-secondary">Reset</button>
            </div>
        </form>
    </div>
</div>

<style>
.admin-add-product {
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

.form-container {
    max-width: 800px;
}

.form-card {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 30px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.form-card-title {
    margin-top: 0;
    margin-bottom: 25px;
    padding-bottom: 15px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.form-row {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.form-row .form-group {
    flex: 1;
    min-width: 200px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    color: var(--dark-text);
}

.form-group input,
.form-group select,
.form-group textarea {
    width: 100%;
    padding: 12px;
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
    border: 1px solid #333;
    border-radius: var(--border-radius);
    transition: var(--transition);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.3);
}

.form-group textarea {
    resize: vertical;
}

.form-actions {
    display: flex;
    gap: 15px;
}

@media (max-width: 768px) {
    .page-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
    }

    .form-row {
        flex-direction: column;
        gap: 0;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Form validation
    const form = document.querySelector('.product-form');

    form.addEventListener('submit', function(e) {
        if (!validateForm()) {
            e.preventDefault();
        }
    });

    function validateForm() {
        let valid = true;

        // Validate name
        const nameInput = document.getElementById('name');
        if (!nameInput.value.trim()) {
            showError(nameInput, 'Product name is required');
            valid = false;
        } else {
            clearError(nameInput);
        }

        // Validate category
        const categoryInput = document.getElementById('category');
        if (!categoryInput.value) {
            showError(categoryInput, 'Please select a category');
            valid = false;
        } else {
            clearError(categoryInput);
        }

        // Validate price
        const priceInput = document.getElementById('price');
        if (!priceInput.value || parseFloat(priceInput.value) <= 0) {
            showError(priceInput, 'Please enter a valid price');
            valid = false;
        } else {
            clearError(priceInput);
        }

        // Validate stock
        const stockInput = document.getElementById('stockQuantity');
        if (!stockInput.value || parseInt(stockInput.value) < 0) {
            showError(stockInput, 'Please enter a valid stock quantity');
            valid = false;
        } else {
            clearError(stockInput);
        }

        // Validate description
        const descriptionInput = document.getElementById('description');
        if (!descriptionInput.value.trim()) {
            showError(descriptionInput, 'Product description is required');
            valid = false;
        } else {
            clearError(descriptionInput);
        }

        return valid;
    }

    function showError(input, message) {
        clearError(input);

        const errorElement = document.createElement('div');
        errorElement.className = 'form-error';
        errorElement.textContent = message;

        input.classList.add('is-invalid');
        input.parentNode.appendChild(errorElement);
    }

    function clearError(input) {
        input.classList.remove('is-invalid');

        const errorElement = input.parentNode.querySelector('.form-error');
        if (errorElement) {
            errorElement.remove();
        }
    }
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />