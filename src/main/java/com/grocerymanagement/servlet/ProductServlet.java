package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.dao.ReviewDAO;
import com.grocerymanagement.model.Review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet({"/product/*", "/admin/products"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 10,  // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProductServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProductServlet.class.getName());
    private ProductDAO productDAO;
    private ReviewDAO reviewDAO;
    private FileInitializationUtil fileInitUtil;

    @Override
    public void init() throws ServletException {
        fileInitUtil = new FileInitializationUtil(getServletContext());
        productDAO = new ProductDAO(fileInitUtil);
        reviewDAO = new ReviewDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String servletPath = request.getServletPath();

        // Handle admin products route
        if ("/admin/products".equals(servletPath)) {
            listAdminProducts(request, response);
            return;
        }

        if (pathInfo == null) {
            pathInfo = "/list";
        }

        try {
            switch (pathInfo) {
                case "/list":
                    listProducts(request, response);
                    break;
                case "/details":
                    showProductDetails(request, response);
                    break;
                case "/category":
                    listProductsByCategory(request, response);
                    break;
                case "/sort":
                    sortProducts(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing product request", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "An error occurred while processing your request");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        try {
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
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing product post request", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "An error occurred while processing your request");
        }
    }

    private void addProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String description = request.getParameter("description");

            // Validate inputs
            if (name == null || name.trim().isEmpty() ||
                    category == null || category.trim().isEmpty() ||
                    priceStr == null || stockStr == null) {
                request.setAttribute("error", "All fields are required");
                request.getRequestDispatcher("/views/admin/add-product.jsp").forward(request, response);
                return;
            }

            BigDecimal price = new BigDecimal(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);

            Product newProduct = new Product(name, category, price, stockQuantity, description);

            // Handle image upload
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getSubmittedFileName(filePart);
                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

                String uploadPath = fileInitUtil.getImageUploadPath();
                Files.createDirectories(Paths.get(uploadPath));

                Path filePath = Paths.get(uploadPath, uniqueFileName);

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
                }

                // Save relative path to database
                newProduct.setImagePath("/uploads/images/" + uniqueFileName);
            }

            if (productDAO.createProduct(newProduct)) {
                // Redirect to product list with success message
                request.getSession().setAttribute("successMessage", "Product added successfully");
                response.sendRedirect(request.getContextPath() + "/admin/products");
            } else {
                request.setAttribute("error", "Failed to add product");
                request.getRequestDispatcher("/views/admin/add-product.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or stock quantity");
            request.getRequestDispatcher("/views/admin/add-product.jsp").forward(request, response);
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productId = request.getParameter("productId");
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stockQuantity");
            String description = request.getParameter("description");

            // Find existing product
            Optional<Product> existingProductOpt = productDAO.getProductById(productId);
            if (!existingProductOpt.isPresent()) {
                request.setAttribute("error", "Product not found");
                request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
                return;
            }

            Product product = existingProductOpt.get();
            product.setName(name);
            product.setCategory(category);
            product.setPrice(new BigDecimal(priceStr));
            product.setStockQuantity(Integer.parseInt(stockStr));
            product.setDescription(description);

            // Handle image upload
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getSubmittedFileName(filePart);
                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String uniqueFileName = UUID.randomUUID().toString() + fileExtension;

                String uploadPath = fileInitUtil.getImageUploadPath();
                Files.createDirectories(Paths.get(uploadPath));

                Path filePath = Paths.get(uploadPath, uniqueFileName);

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
                }

                // Save relative path to database
                product.setImagePath("/uploads/images/" + uniqueFileName);
            }

            if (productDAO.updateProduct(product)) {
                // Redirect to product list with success message
                request.getSession().setAttribute("successMessage", "Product updated successfully");
                response.sendRedirect(request.getContextPath() + "/admin/products");
            } else {
                request.setAttribute("error", "Failed to update product");
                request.getRequestDispatcher("/views/admin/edit-product.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price or stock quantity");
            request.getRequestDispatcher("/views/admin/edit-product.jsp").forward(request, response);
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productId = request.getParameter("productId");

            boolean deleted = productDAO.deleteProduct(productId);

            // Return JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            if (deleted) {
                response.getWriter().write("{\"success\": true, \"message\": \"Product deleted successfully\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to delete product\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting product", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"An error occurred: " + e.getMessage() + "\"}");
        }
    }

    private void listAdminProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = request.getParameter("category");
        String search = request.getParameter("search");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String stockFilter = request.getParameter("stock");

        List<Product> products = productDAO.getAllProducts();

        // Filter by category if specified
        if (category != null && !category.isEmpty()) {
            products = products.stream()
                    .filter(p -> p.getCategory().equalsIgnoreCase(category))
                    .collect(Collectors.toList());
        }

        // Filter by search term
        if (search != null && !search.isEmpty()) {
            products = products.stream()
                    .filter(p -> p.getName().toLowerCase().contains(search.toLowerCase()) ||
                            p.getCategory().toLowerCase().contains(search.toLowerCase()))
                    .collect(Collectors.toList());
        }

        // Filter by stock status
        if (stockFilter != null && !stockFilter.isEmpty()) {
            products = products.stream()
                    .filter(p -> {
                        switch (stockFilter) {
                            case "instock":
                                return p.getStockQuantity() > 10;
                            case "lowstock":
                                return p.getStockQuantity() > 0 && p.getStockQuantity() <= 10;
                            case "outofstock":
                                return p.getStockQuantity() == 0;
                            default:
                                return true;
                        }
                    })
                    .collect(Collectors.toList());
        }

        // Apply sorting if specified
        if (sortBy != null && !sortBy.isEmpty()) {
            Comparator<Product> comparator = createAdminComparator(sortBy);
            if (comparator != null) {
                if ("desc".equals(sortOrder)) {
                    comparator = comparator.reversed();
                }
                products = products.stream()
                        .sorted(comparator)
                        .collect(Collectors.toList());
            }
        }

        // Pagination
        int page = 1;
        int productsPerPage = 10;
        int totalProducts = products.size();
        int totalPages = (int) Math.ceil((double) totalProducts / productsPerPage);

        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }

        // Ensure page is within valid range
        page = Math.max(1, Math.min(page, totalPages));

        int start = (page - 1) * productsPerPage;
        int end = Math.min(start + productsPerPage, totalProducts);

        List<Product> paginatedProducts = products.subList(start, end);

        request.setAttribute("products", paginatedProducts);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);

        request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
        request.setAttribute("totalProducts", products.size());
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void listProductsByCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = request.getParameter("category");
        List<Product> products = productDAO.getProductsByCategory(category);
        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void showProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productId = request.getParameter("productId");

        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (productOptional.isPresent()) {
            Product product = productOptional.get();

            // Get reviews for this product
            double averageRating = reviewDAO.calculateAverageRatingForProduct(productId);

            // Get related products (same category)
            List<Product> relatedProducts = productDAO.getAllProducts().stream()
                    .filter(p -> p.getCategory().equals(product.getCategory()) &&
                            !p.getProductId().equals(productId))
                    .limit(4)
                    .collect(Collectors.toList());

            request.setAttribute("product", product);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("reviews", reviewDAO.getReviewsByProductId(
                    productId,
                    Review.ReviewStatus.APPROVED,
                    null,
                    Comparator.comparing(Review::getReviewDate).reversed()
            ));
            request.setAttribute("relatedProducts", relatedProducts);

            request.getRequestDispatcher("/views/product/product-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
        }
    }

    private void sortProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String category = request.getParameter("category");

        List<Product> products;
        if (category != null && !category.isEmpty()) {
            products = productDAO.getProductsByCategory(category);
        } else {
            products = productDAO.getAllProducts();
        }

        // Apply sorting
        Comparator<Product> comparator = createComparator(sortBy);

        if (comparator != null) {
            if ("desc".equals(sortOrder)) {
                comparator = comparator.reversed();
            }
            products = products.stream()
                    .sorted(comparator)
                    .collect(Collectors.toList());
        }

        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void sortAdminProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String category = request.getParameter("category");

        List<Product> products;
        if (category != null && !category.isEmpty()) {
            products = productDAO.getProductsByCategory(category);
        } else {
            products = productDAO.getAllProducts();
        }

        // Apply sorting
        Comparator<Product> comparator = createAdminComparator(sortBy);

        if (comparator != null) {
            if ("desc".equals(sortOrder)) {
                comparator = comparator.reversed();
            }
            products = products.stream()
                    .sorted(comparator)
                    .collect(Collectors.toList());
        }

        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);
        request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
    }

    private Comparator<Product> createComparator(String sortBy) {
        if (sortBy == null) return null;

        switch (sortBy) {
            case "name":
                return Comparator.comparing(Product::getName, String.CASE_INSENSITIVE_ORDER);
            case "category":
                return Comparator.comparing(Product::getCategory, String.CASE_INSENSITIVE_ORDER);
            case "price":
                return Comparator.comparing(Product::getPrice);
            case "stock":
                return Comparator.comparing(Product::getStockQuantity);
            default:
                return null;
        }
    }

    private Comparator<Product> createAdminComparator(String sortBy) {
        // This is essentially the same as createComparator, but having a separate method
        // allows for future customization if needed
        return createComparator(sortBy);
    }

    // Utility method to extract filename from a Part
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