package com.grocerymanagement.util;

import com.grocerymanagement.model.Order;
import java.math.BigDecimal;

public class OrderValidationUtil {
    public static boolean validateOrder(Order order) {
        if (order == null) return false;

        // Validate user ID
        if (order.getUserId() == null || order.getUserId().isEmpty()) {
            return false;
        }

        // Validate order items
        if (order.getItems() == null || order.getItems().isEmpty()) {
            return false;
        }

        // Validate each order item
        for (Order.OrderItem item : order.getItems()) {
            if (!validateOrderItem(item)) {
                return false;
            }
        }

        // Validate total amount
        if (order.getTotalAmount() == null ||
                order.getTotalAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        return true;
    }

    private static boolean validateOrderItem(Order.OrderItem item) {
        return item.getProductId() != null && !item.getProductId().isEmpty() &&
                item.getQuantity() > 0 &&
                item.getPrice() != null &&
                item.getPrice().compareTo(BigDecimal.ZERO) >= 0;
    }

    public static BigDecimal calculateOrderTotal(Order order) {
        return order.getItems().stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}