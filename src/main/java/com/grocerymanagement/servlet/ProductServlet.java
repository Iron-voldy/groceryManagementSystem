package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;
import javax.servlet.ServletException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@WebServlet("/product/*")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 10,  // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;
    private FileInitializationUtil fileInitUtil;

    @Override
    public void init() throws ServletException {
        fileInitUtil = new FileInitializationUtil(getServletContext());
        productDAO = new ProductDAO(fileInitUtil);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        switch (pathInfo) {
            case "/add":
                addProduct(request, response);
                break;
            case "/update":
                updateProduct(request, response);
                break;
            case "/delete":
                deleteProduct(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        switch (pathInfo) {
            case "/list":
                listProducts(request, response);
                break;
            case "/search":
                searchProducts(request, response);
                break;
            case "/category":
                listProductsByCategory(request, response);
                break;
            case "/details":
                getProductDetails(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void addProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Extract product information from form
        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stockQuantity");
        String description = request.getParameter("description");

        try {
            BigDecimal price = new BigDecimal(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);

            Product newProduct = new Product(name, category, price, stockQuantity, description);

            // Handle image upload
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getSubmittedFileName(filePart);

                // Generate a unique filename to prevent duplicates
                String fileExtension = "";
                if (fileName.contains(".")) {
                    fileExtension = fileName.substring(fileName.lastIndexOf("."));
                }
                String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

                // Save the file
                String uploadPath = fileInitUtil.getImageUploadPath();
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String filePath = new File(uploadDir, uniqueFileName).getAbsolutePath();

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                }

                // Save the relative path to the database
                newProduct.setImagePath("/uploads/images/" + uniqueFileName);
            }

            if (productDAO.createProduct(newProduct)) {
                request.setAttribute("success", "Product added successfully");
                response.sendRedirect(request.getContextPath() + "/product/list");
            } else {
                request.setAttribute("error", "Failed to add product");
                request.getRequestDispatcher("/views/product/add-product.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or stock quantity");
            request.getRequestDispatcher("/views/product/add-product.jsp").forward(request, response);
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String productId = request.getParameter("productId");
        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        Product product = productOptional.get();

        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stockQuantity");
        String description = request.getParameter("description");

        try {
            if (name != null && !name.isEmpty()) product.setName(name);
            if (category != null && !category.isEmpty()) product.setCategory(category);
            if (priceStr != null && !priceStr.isEmpty()) product.setPrice(new BigDecimal(priceStr));
            if (stockStr != null && !stockStr.isEmpty()) product.setStockQuantity(Integer.parseInt(stockStr));
            if (description != null && !description.isEmpty()) product.setDescription(description);

            // Handle image upload
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getSubmittedFileName(filePart);

                // Generate a unique filename to prevent duplicates
                String fileExtension = "";
                if (fileName.contains(".")) {
                    fileExtension = fileName.substring(fileName.lastIndexOf("."));
                }
                String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

                // Save the file
                String uploadPath = fileInitUtil.getImageUploadPath();
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String filePath = new File(uploadDir, uniqueFileName).getAbsolutePath();

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                }

                // Delete old image if it exists
                if (product.getImagePath() != null && !product.getImagePath().isEmpty()) {
                    String oldImageFilePath = getServletContext().getRealPath(product.getImagePath());
                    Files.deleteIfExists(Paths.get(oldImageFilePath));
                }

                // Save the relative path to the database
                product.setImagePath("/uploads/images/" + uniqueFileName);
            }

            if (productDAO.updateProduct(product)) {
                request.setAttribute("success", "Product updated successfully");
                response.sendRedirect(request.getContextPath() + "/product/list");
            } else {
                request.setAttribute("error", "Failed to update product");
                request.getRequestDispatcher("/views/product/product-edit.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or stock quantity");
            request.getRequestDispatcher("/views/product/product-edit.jsp").forward(request, response);
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String productId = request.getParameter("productId");

        // Get product to retrieve image path
        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (productOptional.isPresent()) {
            Product product = productOptional.get();

            if (productDAO.deleteProduct(productId)) {
                // Delete product image if it exists
                if (product.getImagePath() != null && !product.getImagePath().isEmpty()) {
                    String imagePath = getServletContext().getRealPath(product.getImagePath());
                    Files.deleteIfExists(Paths.get(imagePath));
                }

                request.setAttribute("success", "Product deleted successfully");
                response.sendRedirect(request.getContextPath() + "/product/list");
            } else {
                request.setAttribute("error", "Failed to delete product");
                request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("error", "Product not found");
            request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void searchProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("searchTerm");
        List<Product> products = productDAO.searchProductsByName(searchTerm);
        request.setAttribute("products", products);
        request.setAttribute("searchTerm", searchTerm);
        request.getRequestDispatcher("/views/product/product-search.jsp").forward(request, response);
    }

    private void listProductsByCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = request.getParameter("category");
        List<Product> products = productDAO.getProductsByCategory(category);
        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void getProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productId = request.getParameter("productId");
        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (productOptional.isPresent()) {
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/product/product-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
        }
    }

    private boolean isAdminUser(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

    // Helper method to get the submitted filename
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf('/') + 1)
                        .substring(fileName.lastIndexOf('\\') + 1);
            }
        }
        return null;
    }
}