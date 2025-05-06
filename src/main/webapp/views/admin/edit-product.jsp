<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page import="com.grocerymanagement.config.FileInitializationUtil" %>
<%@ page import="com.grocerymanagement.dao.ProductDAO" %>
<%@ page import="com.grocerymanagement.model.Product" %>
<%@ page import="java.util.Optional" %>

<%
    // Get product ID from request parameter
    String productId = request.getParameter("productId");

    // Load product details
    FileInitializationUtil fileInitUtil = new FileInitializationUtil(application);
    ProductDAO productDAO = new ProductDAO(fileInitUtil);
    Optional<Product> productOptional = productDAO.getProductById(productId);

    if (productOptional.isPresent()) {
        request.setAttribute("product", productOptional.get());
    }
%>

<jsp:include page="/views/common/admin-header.jsp">
    <jsp:param name="title" value="Edit Product" />
    <jsp:param name="active" value="products" />
</jsp:include>

<div class="admin-edit-product container">
    <div class="page-header">
        <h1 class="page-title">Edit Product</h1>
        <div class="page-actions">
            <a href="${pageContext.request.contextPath}/views/admin/products.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Products
            </a>
        </div>
    </div>

    <c:if test="${empty product}">
        <div class="alert alert-danger">
            Product not found. Please check the product ID and try again.
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            ${error}
        </div>
    </c:if>

    <c:if test="${not empty product}">
        <div class="form-container">
            <form action="${pageContext.request.contextPath}/product/update" method="post"
                  class="product-form" enctype="multipart/form-data" onsubmit="return validateForm()">

                <input type="hidden" name="productId" value="${product.productId}">

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Edit Product Details</h2>
                    </div>
                    <div class="card-body">
                        <div class="form-group">
                            <label for="name">Product Name*</label>
                            <input type="text" class="form-control" id="name" name="name"
                                   value="${product.name}" placeholder="Enter product name" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="category">Category*</label>
                                <select class="form-control" id="category" name="category" required>
                                    <option value="">Select Category</option>
                                    <option value="Fresh Products" ${product.category == 'Fresh Products' ? 'selected' : ''}>Fresh Products</option>
                                    <option value="Dairy" ${product.category == 'Dairy' ? 'selected' : ''}>Dairy</option>
                                    <option value="Vegetables" ${product.category == 'Vegetables' ? 'selected' : ''}>Vegetables</option>
                                    <option value="Fruits" ${product.category == 'Fruits' ? 'selected' : ''}>Fruits</option>
                                    <option value="Pantry Items" ${product.category == 'Pantry Items' ? 'selected' : ''}>Pantry Items</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="price">Price ($)*</label>
                                <input type="number" class="form-control" id="price" name="price"
                                       value="<fmt:formatNumber value='${product.price}' pattern='0.00'/>"
                                       min="0.01" step="0.01" placeholder="Enter price" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="stockQuantity">Stock Quantity*</label>
                            <input type="number" class="form-control" id="stockQuantity"
                                   name="stockQuantity" value="${product.stockQuantity}"
                                   min="0" placeholder="Enter stock quantity" required>
                        </div>

                        <div class="form-group">
                            <label for="description">Description*</label>
                            <textarea class="form-control" id="description" name="description"
                                      rows="4" placeholder="Enter product description" required>${product.description}</textarea>
                        </div>

                        <div class="form-group">
                            <label for="productImage">Product Image</label>
                            <input type="file" class="form-control-file" id="productImage"
                                   name="productImage" accept="image/*">
                            <small class="form-text text-muted">
                                Upload a new image to replace the current one (optional). Max size: 10MB
                            </small>
                        </div>

                        <div class="image-preview-container">
                            <div id="imagePreview" class="image-preview">
                                <c:choose>
                                    <c:when test="${not empty product.imagePath}">
                                        <img src="${pageContext.request.contextPath}${product.imagePath}"
                                             alt="${product.name}">
                                    </c:when>
                                    <c:otherwise>
                                        No image selected
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">Update Product</button>
                        <button type="reset" class="btn btn-secondary">Reset</button>
                    </div>
                </div>
            </form>
        </div>
    </c:if>
</div>

<style>
.admin-edit-product {
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

 .error-message {
     color: red;
     font-size: 0.8rem;
     margin-top: 5px;
 }

 .is-invalid {
     border-color: red;
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
     } else {
         clearError(nameInput);
     }

     // Category validation
     const categoryInput = document.getElementById('category');
     if (!categoryInput.value) {
         showError(categoryInput, 'Please select a category');
         isValid = false;
     } else {
         clearError(categoryInput);
     }

     // Price validation
     const priceInput = document.getElementById('price');
     if (!priceInput.value || parseFloat(priceInput.value) <= 0) {
         showError(priceInput, 'Please enter a valid price');
         isValid = false;
     } else {
         clearError(priceInput);
     }

     // Stock quantity validation
     const stockInput = document.getElementById('stockQuantity');
     if (!stockInput.value || parseInt(stockInput.value) < 0) {
         showError(stockInput, 'Please enter a valid stock quantity');
         isValid = false;
     } else {
         clearError(stockInput);
     }

     // Description validation
     const descriptionInput = document.getElementById('description');
     if (!descriptionInput.value.trim()) {
         showError(descriptionInput, 'Product description is required');
         isValid = false;
     } else {
         clearError(descriptionInput);
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
     clearError(input);

     // Create and add error message
     const errorElement = document.createElement('div');
     errorElement.className = 'error-message text-danger';
     errorElement.textContent = message;
     input.parentNode.appendChild(errorElement);

     // Highlight input
     input.classList.add('is-invalid');
 }

 function clearError(input) {
     // Remove existing error message
     const existingError = input.parentNode.querySelector('.error-message');
     if (existingError) {
         existingError.remove();
     }

     // Remove invalid highlighting
     input.classList.remove('is-invalid');
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
         // Restore original image if no new file selected
         const originalImagePath = '${product.imagePath}';
         if (originalImagePath) {
             const img = document.createElement('img');
             img.src = '${pageContext.request.contextPath}${product.imagePath}';
             img.alt = '${product.name}';
             imagePreview.innerHTML = '';
             imagePreview.appendChild(img);
         } else {
             imagePreview.innerHTML = 'No image selected';
         }
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
     const originalImagePath = '${product.imagePath}';
     if (originalImagePath) {
         const img = document.createElement('img');
         img.src = '${pageContext.request.contextPath}${product.imagePath}';
         img.alt = '${product.name}';
         imagePreview.innerHTML = '';
         imagePreview.appendChild(img);
     } else {
         imagePreview.innerHTML = 'No image selected';
     }
 });
 </script>

 <jsp:include page="/views/common/admin-footer.jsp" />