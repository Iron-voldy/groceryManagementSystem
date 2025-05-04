package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.util.FileHandlerUtil;
import java.math.BigDecimal;
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

    public boolean createOrder(Order order) {
        if (!validateOrder(order)) {
            return false;
        }

        FileHandlerUtil.writeToFile(orderFilePath, order.toFileString(), true);
        return true;
    }

    public Optional<Order> getOrderById(String orderId) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getOrderId().equals(orderId))
                .findFirst();
    }

    public List<Order> getOrdersByUserId(String userId) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    public List<Order> getAllOrders() {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .collect(Collectors.toList());
    }

    public boolean updateOrder(Order updatedOrder) {
        List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);
        boolean orderFound = false;

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
                return true;
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating order: " + e.getMessage());
                return false;
            }
        }

        return false;
    }

    public boolean deleteOrder(String orderId) {
        List<String> lines = FileHandlerUtil.readFromFile(orderFilePath);
        boolean orderRemoved = lines.removeIf(line -> {
            Order order = Order.fromFileString(line);
            return order.getOrderId().equals(orderId);
        });

        if (orderRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(orderFilePath)) {
                lines.forEach(writer::println);
                return true;
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting order: " + e.getMessage());
                return false;
            }
        }

        return false;
    }

    public List<Order> getOrdersByStatus(Order.OrderStatus status) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order -> order.getStatus() == status)
                .collect(Collectors.toList());
    }

    public List<Order> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return FileHandlerUtil.readFromFile(orderFilePath).stream()
                .map(Order::fromFileString)
                .filter(order ->
                        !order.getOrderDate().isBefore(startDate) &&
                                !order.getOrderDate().isAfter(endDate)
                )
                .collect(Collectors.toList());
    }

    private boolean validateOrder(Order order) {
        return order != null &&
                order.getUserId() != null && !order.getUserId().isEmpty() &&
                order.getItems() != null && !order.getItems().isEmpty() &&
                order.getTotalAmount() != null && order.getTotalAmount().compareTo(BigDecimal.ZERO) > 0;
    }
}