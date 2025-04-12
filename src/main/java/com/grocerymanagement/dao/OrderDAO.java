package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.util.FileHandlerUtil;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class OrderDAO {
    private String orderFilePath;

    public OrderDAO(FileInitializationUtil fileInitUtil) {
        this.orderFilePath = fileInitUtil.getDataFilePath("orders.txt");
    }

    /**
     * Creates a new order in the system
     * @param order The order to create
     * @return true if the order was created successfully, false otherwise
     */
    public boolean createOrder(Order order) {
        if (!validateOrder(order)) {
            return false;
        }

        // Ensure the order has creation and update timestamps
        if (order.getOrderDate() == null) {
            order.setOrderDate(LocalDateTime.now());
        }

        if (order.getLastUpdated() == null) {
            order.setLastUpdated(LocalDateTime.now());
        }

        FileHandlerUtil.writeToFile(orderFilePath, order.toFileString(), true);
        return true;
    }

    /**
     * Retrieves an order by its ID
     * @param orderId The ID of the order to retrieve
     * @return An Optional containing the order if found, or empty if not found
     */
    public Optional<Order> getOrderById(String orderId) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getOrderId().equals(orderId))
                .findFirst();
    }

    /**
     * Retrieves all orders placed by a specific user
     * @param userId The ID of the user
     * @return A list of orders placed by the user
     */
    public List<Order> getOrdersByUserId(String userId) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    /**
     * Retrieves all orders with a specific status
     * @param status The status to filter by
     * @return A list of orders with the specified status
     */
    public List<Order> getOrdersByStatus(Order.OrderStatus status) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getStatus() == status)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves orders placed within a date range
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return A list of orders placed within the date range
     */
    public List<Order> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> !order.getOrderDate().isBefore(startDate) &&
                        !order.getOrderDate().isAfter(endDate))
                .collect(Collectors.toList());
    }

    /**
     * Retrieves all orders in the system
     * @return A list of all orders
     */
    public List<Order> getAllOrders() {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .collect(Collectors.toList());
    }

    /**
     * Updates an existing order
     * @param updatedOrder The updated order details
     * @return true if the order was updated successfully, false otherwise
     */
    public boolean updateOrder(Order updatedOrder) {
        if (!validateOrder(updatedOrder)) {
            return false;
        }

        List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);
        boolean orderFound = false;

        // Update the lastUpdated timestamp
        updatedOrder.setLastUpdated(LocalDateTime.now());

        for (int i = 0; i < lines.size(); i++) {
            Order existingOrder = Order.fromFileString(lines.get(i));
            if (existingOrder.getOrderId().equals(updatedOrder.getOrderId())) {
                lines.set(i, updatedOrder.toFileString());
                orderFound = true;
                break;
            }
        }

        if (orderFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(orderFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating order: " + e.getMessage());
                return false;
            }
        }

        return orderFound;
    }

    /**
     * Updates the status of an order
     * @param orderId The ID of the order to update
     * @param newStatus The new status
     * @return true if the status was updated successfully, false otherwise
     */
    public boolean updateOrderStatus(String orderId, Order.OrderStatus newStatus) {
        Optional<Order> orderOptional = getOrderById(orderId);
        if (!orderOptional.isPresent()) {
            return false;
        }

        Order order = orderOptional.get();
        order.setStatus(newStatus);
        return updateOrder(order);
    }

    /**
     * Deletes an order from the system
     * @param orderId The ID of the order to delete
     * @return true if the order was deleted successfully, false otherwise
     */
    public boolean deleteOrder(String orderId) {
        List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);
        boolean orderRemoved = lines.removeIf(line -> {
            Order order = Order.fromFileString(line);
            return order.getOrderId().equals(orderId);
        });

        if (orderRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(orderFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting order: " + e.getMessage());
                return false;
            }
        }

        return orderRemoved;
    }

    /**
     * Gets the total number of orders in the system
     * @return The total number of orders
     */
    public int getTotalOrderCount() {
        return FileHandlerUtil.readFromFile(orderFilePath).size();
    }

    /**
     * Gets the total number of orders with a specific status
     * @param status The status to count
     * @return The number of orders with the specified status
     */
    public int getOrderCountByStatus(Order.OrderStatus status) {
        return getOrdersByStatus(status).size();
    }

    /**
     * Gets recent orders, limited by count
     * @param limit The maximum number of orders to return
     * @return A list of the most recent orders
     */
    public List<Order> getRecentOrders(int limit) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .sorted((o1, o2) -> o2.getOrderDate().compareTo(o1.getOrderDate()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    /**
     * Validates an order before creating or updating
     * @param order The order to validate
     * @return true if the order is valid, false otherwise
     */
    private boolean validateOrder(Order order) {
        return order != null &&
                order.getUserId() != null && !order.getUserId().isEmpty() &&
                order.getItems() != null && !order.getItems().isEmpty() &&
                order.getTotalAmount() != null &&
                order.getStatus() != null;
    }
}