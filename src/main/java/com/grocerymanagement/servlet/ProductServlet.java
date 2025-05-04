package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.ReviewDAO;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.Review;
import com.grocerymanagement.model.User;
import com.grocerymanagement.service.ProductSortingService;

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
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet("/product/*")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 10,  // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProductServlet extends HttpServlet {
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
            // Redirect to list products when no specific path is specified
            response.sendRedirect(request.getContextPath() + "/product/list");
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
            case "/sort":
                sortProducts(request, response);
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
                response.sendRedirect(request.getContextPath() + "/views/admin/products.jsp");
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
        // Existing update product implementation...
        // Code omitted for brevity
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Existing delete product implementation...
        // Code omitted for brevity
    }

    /**
     * Lists all products with optional sorting.
     */
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get sort parameters
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        // Get all products
        List<Product> products = productDAO.getAllProducts();

        // Apply sorting if requested
        if (sortBy != null && !sortBy.isEmpty()) {
            products = applySorting(products, sortBy, sortOrder);
        }

        // Set products as request attribute
        request.setAttribute("products", products);
        request.setAttribute("totalProducts", products.size());
        request.setAttribute("currentSortBy", sortBy); // For highlighting active sort option
        request.setAttribute("currentSortOrder", sortOrder); // For toggling sort direction

        // Check if request is coming from admin area
        String referer = request.getHeader("Referer");
        boolean isAdminRequest = referer != null && referer.contains("/admin/");

        // Forward to admin or customer product page based on context
        if (isAdminRequest || isAdminUser(request.getSession(false))) {
            request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
        }
    }

    /**
     * Dedicated endpoint for sorting products.
     */
    private void sortProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String category = request.getParameter("category");
        String searchTerm = request.getParameter("searchTerm");

        List<Product> products;

        // Get the appropriate product list based on context
        if (category != null && !category.isEmpty()) {
            products = productDAO.getProductsByCategory(category);
        } else if (searchTerm != null && !searchTerm.isEmpty()) {
            products = productDAO.searchProductsByName(searchTerm);
        } else {
            products = productDAO.getAllProducts();
        }

        // Apply Merge Sort
        products = applySorting(products, sortBy, sortOrder);

        // Set attributes
        request.setAttribute("products", products);
        request.setAttribute("totalProducts", products.size());
        request.setAttribute("category", category);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);

        // Determine appropriate view
        String view = "/views/product/product-list.jsp";
        if (category != null && !category.isEmpty()) {
            view = "/views/product/product-list.jsp";
        } else if (searchTerm != null && !searchTerm.isEmpty()) {
            view = "/views/product/product-search.jsp";
        }

        request.getRequestDispatcher(view).forward(request, response);
    }

    /**
     * Apply Merge Sort based on specified criteria.
     */
    private List<Product> applySorting(List<Product> products, String sortBy, String sortOrder) {
        Comparator<Product> comparator;

        // Determine sort criterion
        switch (sortBy) {
            case "name":
                comparator = ProductSortingService.sortByName();
                break;
            case "category":
                comparator = ProductSortingService.sortByCategory();
                break;
            case "price":
                comparator = ProductSortingService.sortByPrice();
                break;
            case "stock":
                comparator = ProductSortingService.sortByStock();
                break;
            default:
                // Default sort by name
                comparator = ProductSortingService.sortByName();
                break;
        }

        // Apply reverse order if requested
        if ("desc".equals(sortOrder)) {
            comparator = comparator.reversed();
        }

        // Apply Merge Sort algorithm
        return ProductSortingService.mergeSort(products, comparator);
    }

    private void searchProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("searchTerm");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        List<Product> products = productDAO.searchProductsByName(searchTerm);

        // Apply sorting if requested
        if (sortBy != null && !sortBy.isEmpty()) {
            products = applySorting(products, sortBy, sortOrder);
        }

        request.setAttribute("products", products);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);
        request.getRequestDispatcher("/views/product/product-search.jsp").forward(request, response);
    }

    private void listProductsByCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = request.getParameter("category");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        List<Product> products = productDAO.getProductsByCategory(category);

        // Apply sorting if requested
        if (sortBy != null && !sortBy.isEmpty()) {
            products = applySorting(products, sortBy, sortOrder);
        }

        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    private void getProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Existing product details implementation...
        // Code omitted for brevity
    }

    // Additional helper methods remain unchanged
    // Code omitted for brevity

    private boolean isAdminUser(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

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