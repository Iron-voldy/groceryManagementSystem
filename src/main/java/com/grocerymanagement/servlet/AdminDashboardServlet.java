package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.*;
import com.grocerymanagement.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private OrderDAO orderDAO;
    private UserDAO userDAO;
    private ProductDAO productDAO;
    private TransactionDAO transactionDAO;
    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        orderDAO = new OrderDAO(fileInitUtil);
        userDAO = new UserDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
        transactionDAO = new TransactionDAO(fileInitUtil);
        reviewDAO = new ReviewDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get statistics for dashboard
        Map<String, Object> stats = new HashMap<>();

        // Order stats
        List<Order> allOrders = orderDAO.getAllOrders();
        stats.put("totalOrders", allOrders.size());
        stats.put("orderChange", 5); // Example value, calculate real change

        // User stats
        List<User> allUsers = userDAO.getAllUsers();
        stats.put("totalUsers", allUsers.size());
        stats.put("userChange", 10); // Example value, calculate real change

        // Revenue stats
        BigDecimal totalRevenue = calculateTotalRevenue(allOrders);
        stats.put("totalRevenue", totalRevenue);
        stats.put("revenueChange", 15); // Example value, calculate real change

        // Product stats
        List<Product> allProducts = productDAO.getAllProducts();
        stats.put("totalProducts", allProducts.size());
        stats.put("productChange", 7); // Example value, calculate real change

        // Monthly sales data (example values)
        stats.put("monthlySales", "5000, 6000, 8000, 7500, 9000, 10000, 11000, 10500, 12000, 13000, 12000, 14000");
        stats.put("previousYearSales", "4000, 4500, 5500, 6000, 7500, 8000, 9500, 9000, 10000, 11000, 10500, 12000");

        // Category data (example values)
        stats.put("categoryLabels", "'Fresh Products', 'Dairy', 'Vegetables', 'Fruits', 'Pantry Items'");
        stats.put("categoryValues", "25, 20, 15, 30, 10");

        request.setAttribute("stats", stats);

        // Get recent orders
        List<Order> recentOrders = getRecentOrders(allOrders, 5);
        request.setAttribute("recentOrders", recentOrders);

        // Get recent users
        List<User> recentUsers = getRecentUsers(allUsers, 5);
        request.setAttribute("recentUsers", recentUsers);

        // Get low stock products
        List<Product> lowStockProducts = getLowStockProducts(allProducts, 5);
        request.setAttribute("lowStockProducts", lowStockProducts);

        // Set all users for order user lookup
        request.setAttribute("allUsers", allUsers);

        // Forward to dashboard
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    private BigDecimal calculateTotalRevenue(List<Order> orders) {
        return orders.stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private List<Order> getRecentOrders(List<Order> allOrders, int limit) {
        // Sort by order date descending and get the first 'limit' orders
        return allOrders.stream()
                .sorted((o1, o2) -> o2.getOrderDate().compareTo(o1.getOrderDate()))
                .limit(limit)
                .collect(java.util.stream.Collectors.toList());
    }

    private List<User> getRecentUsers(List<User> allUsers, int limit) {
        // Sort by registration date descending and get the first 'limit' users
        return allUsers.stream()
                .sorted((u1, u2) -> u2.getRegistrationDate().compareTo(u1.getRegistrationDate()))
                .limit(limit)
                .collect(java.util.stream.Collectors.toList());
    }

    private List<Product> getLowStockProducts(List<Product> allProducts, int limit) {
        // Get products with stock less than 10 and limit to 'limit'
        return allProducts.stream()
                .filter(product -> product.getStockQuantity() < 10)
                .limit(limit)
                .collect(java.util.stream.Collectors.toList());
    }
}