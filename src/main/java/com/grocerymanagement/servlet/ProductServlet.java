package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@WebServlet("/product/*")
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
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

        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stockQuantity");
        String description = request.getParameter("description");

        try {
            BigDecimal price = new BigDecimal(priceStr);
            int stockQuantity = Integer.parseInt(stockStr);

            Product newProduct = new Product(name, category, price, stockQuantity, description);

            if (productDAO.createProduct(newProduct)) {
                request.setAttribute("success", "Product added successfully");
                request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
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

        if (productOptional.isEmpty()) {
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

            if (productDAO.updateProduct(product)) {
                request.setAttribute("success", "Product updated successfully");
                request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
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

        if (productDAO.deleteProduct(productId)) {
            request.setAttribute("success", "Product deleted successfully");
            request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to delete product");
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
}