package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.util.FileHandlerUtil;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class OrderDAO {
    // File path for storing orders
    private String orderFilePath;

    /**
     * Constructor
     * @param fileInitUtil Utility for file initialization
     */
    public OrderDAO(FileInitializationUtil fileInitUtil) {
        this.orderFilePath = fileInitUtil.getDataFilePath("orders.txt");
    }

    /**
     * Retrieve all orders from the file with robust parsing
     * @return List of all orders
     */
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        try {
            List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);

            for (String line : lines) {
                if (line == null || line.trim().isEmpty()) {
                    continue; // Skip empty lines
                }

                try {
                    Order order = Order.fromFileString(line.trim());
                    if (order != null) {
                        orders.add(order);
                    }
                } catch (Exception e) {
                    System.err.println("Error parsing individual order: " + line);
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading orders file: " + e.getMessage());
            e.printStackTrace();
        }

        // Sort orders by date, most recent first
        orders.sort((o1, o2) -> o2.getOrderDate().compareTo(o1.getOrderDate()));

        return orders;
    }

    /**
     * Retrieve orders for a specific user
     * @param userId User's unique identifier
     * @return List of orders for the user
     */
    public List<Order> getOrdersByUserId(String userId) {
        return getAllOrders().stream()
                .filter(order -> order.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    /**
     * Retrieve a specific order by its ID
     * @param orderId Unique order identifier
     * @return Optional containing the order if found
     */
    public Optional<Order> getOrderById(String orderId) {
        return getAllOrders().stream()
                .filter(order -> order.getOrderId().equals(orderId))
                .findFirst();
    }

    /**
     * Retrieve orders with pagination and filtering
     * @param page Page number
     * @param pageSize Number of orders per page
     * @param status Optional order status filter
     * @param searchTerm Optional search term
     * @return Paginated and filtered list of orders
     */
    public List<Order> getOrdersWithFilter(
            int page,
            int pageSize,
            Order.OrderStatus status,
            String searchTerm) {

        // Get all orders
        List<Order> allOrders = getAllOrders();

        // Apply filters
        List<Order> filteredOrders = allOrders.stream()
                .filter(order -> {
                    // Status filter
                    if (status != null && order.getStatus() != status) {
                        return false;
                    }

                    // Search term filter
                    if (searchTerm != null && !searchTerm.isEmpty()) {
                        String searchLower = searchTerm.toLowerCase();
                        return order.getOrderId().toLowerCase().contains(searchLower) ||
                                order.getUserId().toLowerCase().contains(searchLower);
                    }

                    return true;
                })
                .collect(Collectors.toList());

        // Calculate pagination
        int totalOrders = filteredOrders.size();
        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalOrders);

        // Return paginated results
        return startIndex < totalOrders
                ? filteredOrders.subList(startIndex, endIndex)
                : new ArrayList<>();
    }

    /**
     * Get total number of orders after filtering
     * @param status Optional order status filter
     * @param searchTerm Optional search term
     * @return Total number of orders matching the filter
     */
    public int getTotalOrderCount(Order.OrderStatus status, String searchTerm) {
        List<Order> allOrders = getAllOrders();

        return (int) allOrders.stream()
                .filter(order -> {
                    // Status filter
                    if (status != null && order.getStatus() != status) {
                        return false;
                    }

                    // Search term filter
                    if (searchTerm != null && !searchTerm.isEmpty()) {
                        String searchLower = searchTerm.toLowerCase();
                        return order.getOrderId().toLowerCase().contains(searchLower) ||
                                order.getUserId().toLowerCase().contains(searchLower);
                    }

                    return true;
                })
                .count();
    }

    /**
     * Create a new order
     * @param order Order to be created
     * @return true if order was successfully created, false otherwise
     */
    public boolean createOrder(Order order) {
        try {
            // Ensure order has an ID if not already set
            if (order.getOrderId() == null || order.getOrderId().trim().isEmpty()) {
                order.setOrderId(java.util.UUID.randomUUID().toString());
            }

            // Ensure order date and last updated are set
            if (order.getOrderDate() == null) {
                order.setOrderDate(LocalDateTime.now());
            }
            if (order.getLastUpdated() == null) {
                order.setLastUpdated(LocalDateTime.now());
            }

            // Append the order to the file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(orderFilePath, true))) {
                writer.write(order.toFileString());
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error creating order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing order
     * @param updatedOrder Order with updated information
     * @return true if order was successfully updated, false otherwise
     */
    public boolean updateOrder(Order updatedOrder) {
        try {
            List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);

            boolean orderFound = false;
            for (int i = 0; i < lines.size(); i++) {
                Order existingOrder = Order.fromFileString(lines.get(i));
                if (existingOrder.getOrderId().equals(updatedOrder.getOrderId())) {
                    // Update last updated timestamp
                    updatedOrder.setLastUpdated(LocalDateTime.now());

                    // Replace the line with updated order
                    lines.set(i, updatedOrder.toFileString());
                    orderFound = true;
                    break;
                }
            }

            // Write updated lines back to file
            if (orderFound) {
                try (PrintWriter writer = new PrintWriter(orderFilePath)) {
                    lines.forEach(writer::println);
                }
                return true;
            }
            return false;
        } catch (Exception e) {
            System.err.println("Error updating order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete an order by its ID
     * @param orderId Unique order identifier
     * @return true if order was successfully deleted, false otherwise
     */
    public boolean deleteOrder(String orderId) {
        try {
            List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);

            boolean orderRemoved = lines.removeIf(line -> {
                Order order = Order.fromFileString(line);
                return order.getOrderId().equals(orderId);
            });

            // Write remaining lines back to file if an order was removed
            if (orderRemoved) {
                try (PrintWriter writer = new PrintWriter(orderFilePath)) {
                    lines.forEach(writer::println);
                }
                return true;
            }
            return false;
        } catch (Exception e) {
            System.err.println("Error deleting order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get orders by status
     * @param status Order status to filter
     * @return List of orders with the specified status
     */
    public List<Order> getOrdersByStatus(Order.OrderStatus status) {
        return getAllOrders().stream()
                .filter(order -> order.getStatus() == status)
                .collect(Collectors.toList());
    }

    /**
     * Get orders within a specific date range
     * @param startDate Start of the date range
     * @param endDate End of the date range
     * @return List of orders within the specified date range
     */
    public List<Order> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return getAllOrders().stream()
                .filter(order ->
                        !order.getOrderDate().isBefore(startDate) &&
                                !order.getOrderDate().isAfter(endDate)
                )
                .collect(Collectors.toList());
    }

    /**
     * Calculate total revenue from all orders
     * @return Total revenue as BigDecimal
     */
    public BigDecimal calculateTotalRevenue() {
        return getAllOrders().stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    /**
     * Get recent orders
     * @param limit Maximum number of recent orders to retrieve
     * @return List of recent orders sorted by date (most recent first)
     */
    public List<Order> getRecentOrders(int limit) {
        return getAllOrders().stream()
                .sorted((o1, o2) -> o2.getOrderDate().compareTo(o1.getOrderDate()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    /**
     * Check if a user has any orders
     * @param userId User's unique identifier
     * @return true if the user has orders, false otherwise
     */
    public boolean hasUserOrders(String userId) {
        return getAllOrders().stream()
                .anyMatch(order -> order.getUserId().equals(userId));
    }

    /**
     * Get order count by status
     * @param status Order status to count
     * @return Number of orders with the specified status
     */
    public int getOrderCountByStatus(Order.OrderStatus status) {
        return (int) getAllOrders().stream()
                .filter(order -> order.getStatus() == status)
                .count();
    }

    /**
     * Bulk update order statuses
     * @param orderIds List of order IDs to update
     * @param newStatus New status to set for the orders
     * @return Number of orders successfully updated
     */
    public int bulkUpdateOrderStatus(List<String> orderIds, Order.OrderStatus newStatus) {
        int updatedCount = 0;

        for (String orderId : orderIds) {
            Optional<Order> orderOptional = getOrderById(orderId);

            if (orderOptional.isPresent()) {
                Order order = orderOptional.get();
                order.setStatus(newStatus);

                if (updateOrder(order)) {
                    updatedCount++;
                }
            }
        }

        return updatedCount;
    }
}