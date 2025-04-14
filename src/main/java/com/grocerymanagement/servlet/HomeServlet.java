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
    private FileInitializationUtil fileInitUtil;

    @Override
    public void init() throws ServletException {
        fileInitUtil = new FileInitializationUtil(getServletContext());
        productDAO = new ProductDAO(fileInitUtil);

        // Ensure data directory and files are initialized
        ensureDirectoriesAndFiles();
    }

    private void ensureDirectoriesAndFiles() {
        // Ensure product file exists and has at least one product
        if (productDAO.getAllProducts().isEmpty()) {
            createDefaultProducts();
        }
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
            System.err.println("Error loading products: " + e.getMessage());
            featuredProducts = createDefaultFeaturedProducts();
        }

        // If no products found in database, use default products
        if (featuredProducts.isEmpty()) {
            featuredProducts = createDefaultFeaturedProducts();

            // Save these default products to the database
            for (Product product : featuredProducts) {
                productDAO.createProduct(product);
            }
        }

        request.setAttribute("featuredProducts", featuredProducts);

        // Direct rendering instead of forwarding
        request.getRequestDispatcher("/index.jsp").forward(request, response);
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

    private void createDefaultProducts() {
        List<Product> defaultProducts = createDefaultFeaturedProducts();

        // Add some more variety
        Product bananas = new Product();
        bananas.setName("Organic Bananas");
        bananas.setCategory("Fruits");
        bananas.setPrice(BigDecimal.valueOf(1.49));
        bananas.setStockQuantity(60);
        bananas.setDescription("Sweet, ripe organic bananas sourced from sustainable farms.");
        defaultProducts.add(bananas);

        Product eggs = new Product();
        eggs.setName("Free-Range Eggs");
        eggs.setCategory("Fresh Products");
        eggs.setPrice(BigDecimal.valueOf(4.99));
        eggs.setStockQuantity(40);
        eggs.setDescription("Farm-fresh free-range eggs from cage-free hens.");
        defaultProducts.add(eggs);

        Product cheese = new Product();
        cheese.setName("Cheddar Cheese");
        cheese.setCategory("Dairy");
        cheese.setPrice(BigDecimal.valueOf(3.99));
        cheese.setStockQuantity(35);
        cheese.setDescription("Premium aged cheddar cheese, perfect for sandwiches and snacking.");
        defaultProducts.add(cheese);

        Product rice = new Product();
        rice.setName("Organic Brown Rice");
        rice.setCategory("Pantry Items");
        rice.setPrice(BigDecimal.valueOf(5.99));
        rice.setStockQuantity(45);
        rice.setDescription("Nutritious organic brown rice, a wholesome addition to any meal.");
        defaultProducts.add(rice);

        // Save all default products
        for (Product product : defaultProducts) {
            productDAO.createProduct(product);
        }
    }
}