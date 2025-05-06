<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Add New Product" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="admin-add-product container">
    <div class="page-header">
        <h1 class="page-title">Add New Product</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Products
            </a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            ${error}
        </div>
    </c:if>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/product/add" method="post"
              class="product-form" enctype="multipart/form-data" onsubmit="return validateForm()">

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Product Information</h2>
                </div>
                <div class="card-body">
                    <div class="form-group">
                        <label for="name">Product Name*</label>
                        <input type="text" class="form-control" id="name" name="name"
                               placeholder="Enter product name" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="category">Category*</label>
                            <select class="form-control" id="category" name="category" required>
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
                            <input type="number" class="form-control" id="price" name="price"
                                   min="0.01" step="0.01" placeholder="Enter price" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="stockQuantity">Stock Quantity*</label>
                        <input type="number" class="form-control" id="stockQuantity"
                               name="stockQuantity" min="0" placeholder="Enter stock quantity" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Description*</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" placeholder="Enter product description" required></textarea>
                    </div>

                    <div class="form-group">
                        <label for="productImage">Product Image</label>
                        <input type="file" class="form-control-file" id="productImage"
                               name="productImage" accept="image/*">
                        <small class="form-text text-muted">
                            Upload product image (JPG, PNG, GIF). Max size: 10MB
                        </small>
                    </div>

                    <div class="image-preview-container">
                        <div id="imagePreview" class="image-preview">
                            No image selected
                        </div>
                    </div>
                </div>

                <div class="card-footer">
                    <button type="submit" class="btn btn-primary">Add Product</button>
                    <button type="reset" class="btn btn-secondary">Reset</button>
                </div>
            </div>
        </form>
    </div>
</div>

<style>
.admin-add-product {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.form-row {
    display: flex;
    gap: 15px;
}

.form-row .form-group {
    flex: 1;
}

.image-preview {
    width: 200px;
    height: 200px;
    border: 2px dashed #ccc;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-top: 15px;
    background-color: #f9f9f9;
}

.image-preview img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}
</style>

<script>
function validateForm() {
    let isValid = true;

    // Name validation
    const nameInput = document.getElementById('name');
    if (!nameInput.value.trim()) {
        showError(nameInput, 'Product name is required');
        isValid = false;
    }

    // Category validation
    const categoryInput = document.getElementById('category');
    if (!categoryInput.value) {
        showError(categoryInput, 'Please select a category');
        isValid = false;
    }

    // Price validation
    const priceInput = document.getElementById('price');
    if (!priceInput.value || parseFloat(priceInput.value) <= 0) {
        showError(priceInput, 'Please enter a valid price');
        isValid = false;
    }

    // Stock quantity validation
    const stockInput = document.getElementById('stockQuantity');
    if (!stockInput.value || parseInt(stockInput.value) < 0) {
        showError(stockInput, 'Please enter a valid stock quantity');
        isValid = false;
    }

    // Description validation
    const descriptionInput = document.getElementById('description');
    if (!descriptionInput.value.trim()) {
        showError(descriptionInput, 'Product description is required');
        isValid = false;
    }

    // Image file size validation
    const imageInput = document.getElementById('productImage');
    if (imageInput.files.length > 0) {
        const fileSize = imageInput.files[0].size;
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (fileSize > maxSize) {
            showError(imageInput, 'Image file size should not exceed 10MB');
            isValid = false;
        }
    }

    return isValid;
}

function showError(input, message) {
    // Remove existing error
    const existingError = input.parentNode.querySelector('.error-message');
    if (existingError) {
        existingError.remove();
    }

    // Create and add error message
    const errorElement = document.createElement('div');
    errorElement.className = 'error-message text-danger';
    errorElement.textContent = message;
    input.parentNode.appendChild(errorElement);

    // Highlight input
    input.classList.add('is-invalid');
}

// Image preview functionality
document.getElementById('productImage').addEventListener('change', function(event) {
    const file = event.target.files[0];
    const imagePreview = document.getElementById('imagePreview');

    if (file) {
        const reader = new FileReader();

        reader.onload = function(e) {
            imagePreview.innerHTML = '';
            const img = document.createElement('img');
            img.src = e.target.result;
            imagePreview.appendChild(img);
        }

        reader.readAsDataURL(file);
    } else {
        imagePreview.innerHTML = 'No image selected';
    }
});

// Reset form handling
document.querySelector('form').addEventListener('reset', function() {
    // Clear error messages and validation styling
    const errorMessages = document.querySelectorAll('.error-message');
    errorMessages.forEach(el => el.remove());

    const invalidInputs = document.querySelectorAll('.is-invalid');
    invalidInputs.forEach(input => input.classList.remove('is-invalid'));

    // Reset image preview
    const imagePreview = document.getElementById('imagePreview');
    imagePreview.innerHTML = 'No image selected';
});
</script>

<jsp:include page="/views/common/admin-footer.jsp" />