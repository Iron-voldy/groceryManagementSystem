package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        productDAO = new ProductDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Fetch featured products (e.g., first 4 products or randomly selected)
        List<Product> featuredProducts;

        try {
            featuredProducts = productDAO.getAllProducts().stream()
                    .limit(4)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            // Log the error or handle it appropriately
            featuredProducts = createDefaultFeaturedProducts();
        }

        // If no products found in database, use default products
        if (featuredProducts.isEmpty()) {
            featuredProducts = createDefaultFeaturedProducts();
        }

        request.setAttribute("featuredProducts", featuredProducts);

        // Direct rendering instead of forwarding
        request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
    }

    private List<Product> createDefaultFeaturedProducts() {
        // Create some default products if database is empty or there's an error
        List<Product> defaultProducts = new ArrayList<>();

        // Product 1: Fresh Organic Apples
        Product applesProduct = new Product();
        applesProduct.setName("Fresh Organic Apples");
        applesProduct.setCategory("Fruits");
        applesProduct.setPrice(BigDecimal.valueOf(2.99));
        applesProduct.setStockQuantity(50);
        applesProduct.setDescription("Sweet and juicy organic apples, perfect for healthy snacking.");
        defaultProducts.add(applesProduct);

        // Product 2: Organic Whole Milk
        Product milkProduct = new Product();
        milkProduct.setName("Organic Whole Milk");
        milkProduct.setCategory("Dairy");
        milkProduct.setPrice(BigDecimal.valueOf(3.49));
        milkProduct.setStockQuantity(30);
        milkProduct.setDescription("Farm-fresh organic whole milk, rich in calcium and nutrients.");
        defaultProducts.add(milkProduct);

        // Product 3: Fresh Broccoli
        Product broccoliProduct = new Product();
        broccoliProduct.setName("Fresh Broccoli");
        broccoliProduct.setCategory("Vegetables");
        broccoliProduct.setPrice(BigDecimal.valueOf(1.99));
        broccoliProduct.setStockQuantity(40);
        broccoliProduct.setDescription("Fresh and crunchy broccoli, packed with vitamins and minerals.");
        defaultProducts.add(broccoliProduct);

        // Product 4: Whole Grain Bread
        Product breadProduct = new Product();
        breadProduct.setName("Whole Grain Bread");
        breadProduct.setCategory("Pantry Items");
        breadProduct.setPrice(BigDecimal.valueOf(2.79));
        breadProduct.setStockQuantity(25);
        breadProduct.setDescription("Freshly baked whole grain bread, nutritious and delicious.");
        defaultProducts.add(breadProduct);

        return defaultProducts;
    }
}