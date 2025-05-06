package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    // Order attributes
    private String orderId;
    private String userId;
    private List<OrderItem> items;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private LocalDateTime orderDate;
    private LocalDateTime lastUpdated;
    private ShippingDetails shippingDetails;

    // Enum for order status
    public enum OrderStatus {
        PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
    }

    // Inner class for order items
    public static class OrderItem implements Serializable {
        private static final long serialVersionUID = 1L;

        private String productId;
        private String productName;
        private int quantity;
        private BigDecimal price;

        // Constructors
        public OrderItem() {}

        public OrderItem(String productId, String productName, int quantity, BigDecimal price) {
            this.productId = productId;
            this.productName = productName;
            this.quantity = quantity;
            this.price = price;
        }

        // Getters and Setters
        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }

        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }

        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }

        // Calculate total price for this item
        public BigDecimal getTotalPrice() {
            return price.multiply(BigDecimal.valueOf(quantity));
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            OrderItem orderItem = (OrderItem) o;
            return quantity == orderItem.quantity &&
                    Objects.equals(productId, orderItem.productId) &&
                    Objects.equals(productName, orderItem.productName) &&
                    Objects.equals(price, orderItem.price);
        }

        @Override
        public int hashCode() {
            return Objects.hash(productId, productName, quantity, price);
        }

        @Override
        public String toString() {
            return "OrderItem{" +
                    "productId='" + productId + '\'' +
                    ", productName='" + productName + '\'' +
                    ", quantity=" + quantity +
                    ", price=" + price +
                    '}';
        }
    }

    // Inner class for shipping details
    public static class ShippingDetails implements Serializable {
        private static final long serialVersionUID = 1L;

        private String recipientName;
        private String addressLine1;
        private String addressLine2;
        private String city;
        private String state;
        private String postalCode;
        private String country;
        private String phoneNumber;

        // Constructors
        public ShippingDetails() {}

        // Getters and Setters
        public String getRecipientName() { return recipientName; }
        public void setRecipientName(String recipientName) { this.recipientName = recipientName; }

        public String getAddressLine1() { return addressLine1; }
        public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }

        public String getAddressLine2() { return addressLine2; }
        public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }

        public String getCity() { return city; }
        public void setCity(String city) { this.city = city; }

        public String getState() { return state; }
        public void setState(String state) { this.state = state; }

        public String getPostalCode() { return postalCode; }
        public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

        public String getCountry() { return country; }
        public void setCountry(String country) { this.country = country; }

        public String getPhoneNumber() { return phoneNumber; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    }

    // Constructors
    public Order() {
        this.orderId = UUID.randomUUID().toString();
        this.items = new ArrayList<>();
        this.orderDate = LocalDateTime.now();
        this.lastUpdated = LocalDateTime.now();
        this.status = OrderStatus.PENDING;
        this.totalAmount = BigDecimal.ZERO;
        this.shippingDetails = new ShippingDetails();
    }

    public Order(String userId) {
        this();
        this.userId = userId;
    }

    // Method to add an item to the order
    public void addItem(OrderItem item) {
        // Check if item already exists and update quantity
        for (OrderItem existingItem : items) {
            if (existingItem.getProductId().equals(item.getProductId())) {
                existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
                recalculateTotalAmount();
                return;
            }
        }

        // If item not found, add new item
        items.add(item);
        recalculateTotalAmount();
    }

    // Recalculate total amount based on items
    private void recalculateTotalAmount() {
        this.totalAmount = items.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // Method to create an OrderItem directly
    public OrderItem createOrderItem(String productId, String productName, int quantity, BigDecimal price) {
        return new OrderItem(productId, productName, quantity, price);
    }

    // Static method to parse from file string
    // Static method to parse from file string with custom handling
    public static Order fromFileString(String line) {
        try {
            // Split the line using double pipe delimiter
            String[] parts = line.split("\\|\\|");

            if (parts.length < 7) {
                throw new IllegalArgumentException("Invalid order data format: " + line);
            }

            Order order = new Order();

            // Set order ID (first part)
            order.orderId = parts[0].trim();

            // Set user ID (second part)
            order.userId = parts[1].trim();

            // Parse order items (third part)
            order.items = new ArrayList<>();
            if (!parts[2].isEmpty()) {
                String[] itemParts = parts[2].split("\\|");

                // Custom parsing for the specific format
                if (itemParts.length >= 4) {
                    try {
                        OrderItem item = new OrderItem(
                                itemParts[0],      // productId
                                itemParts[1],      // productName
                                Integer.parseInt(itemParts[2]),  // quantity
                                new BigDecimal(itemParts[3])     // price
                        );
                        order.items.add(item);
                    } catch (NumberFormatException e) {
                        System.err.println("Error parsing order item: " + parts[2]);
                    }
                }
            }

            // Calculate total amount
            order.recalculateTotalAmount();

            // If total amount is zero, try to set from fourth part
            if (order.totalAmount.compareTo(BigDecimal.ZERO) == 0 &&
                    parts.length > 3 && !parts[3].isEmpty()) {
                try {
                    order.totalAmount = new BigDecimal(parts[3]);
                } catch (NumberFormatException e) {
                    // Log error, keep zero
                    System.err.println("Invalid total amount: " + parts[3]);
                }
            }

            // Set status
            try {
                order.status = OrderStatus.valueOf(parts[4].trim());
            } catch (IllegalArgumentException e) {
                // Default to PENDING if status is invalid
                order.status = OrderStatus.PENDING;
                System.err.println("Invalid order status: " + parts[4]);
            }

            // Parse order date
            try {
                order.orderDate = LocalDateTime.parse(parts[5].trim());
            } catch (Exception e) {
                // Default to current time if parsing fails
                order.orderDate = LocalDateTime.now();
                System.err.println("Invalid order date: " + parts[5]);
            }

            // Parse last updated date
            try {
                order.lastUpdated = LocalDateTime.parse(parts[6].trim());
            } catch (Exception e) {
                // Default to current time if parsing fails
                order.lastUpdated = LocalDateTime.now();
                System.err.println("Invalid last updated date: " + parts[6]);
            }

            return order;
        } catch (Exception e) {
            // Log the full error for debugging
            System.err.println("Comprehensive error parsing order: " + line);
            e.printStackTrace();

            // Return a minimal order to prevent total failure
            Order fallbackOrder = new Order();
            fallbackOrder.orderId = UUID.randomUUID().toString();
            fallbackOrder.status = OrderStatus.PENDING;
            return fallbackOrder;
        }
    }

    // Helper method to convert empty string to null and trim
    private static String nullToEmpty(String str) {
        return str == null || str.trim().isEmpty() ? "" : str.trim();
    }

    // Method to convert order to file string
    public String toFileString() {
        try {
            // Prepare order items
            String itemsString = items.stream()
                    .map(item -> String.join("|",
                            nullToEmpty(item.getProductId()),
                            nullToEmpty(item.getProductName()),
                            String.valueOf(item.getQuantity()),
                            item.getPrice().toString()
                    ))
                    .collect(Collectors.joining("|"));

            // Combine all parts with double pipe delimiter
            return String.join("||",
                    nullToEmpty(orderId),
                    nullToEmpty(userId),
                    itemsString,
                    totalAmount.toString(),
                    status.name(),
                    orderDate.toString(),
                    lastUpdated.toString()
            );
        } catch (Exception e) {
            System.err.println("Error converting order to file string: " + e.getMessage());
            e.printStackTrace();
            return "";
        }
    }

    // Getters and Setters
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) {
        this.items = items;
        recalculateTotalAmount();
    }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) {
        this.status = status;
        this.lastUpdated = LocalDateTime.now();
    }

    public LocalDateTime getOrderDate() { return orderDate; }
    public void setOrderDate(LocalDateTime orderDate) { this.orderDate = orderDate; }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    public ShippingDetails getShippingDetails() { return shippingDetails; }
    public void setShippingDetails(ShippingDetails shippingDetails) { this.shippingDetails = shippingDetails; }

    // Equals and HashCode
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Order order = (Order) o;
        return Objects.equals(orderId, order.orderId) &&
                Objects.equals(userId, order.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(orderId, userId);
    }

    // ToString for debugging
    @Override
    public String toString() {
        return "Order{" +
                "orderId='" + orderId + '\'' +
                ", userId='" + userId + '\'' +
                ", items=" + items +
                ", totalAmount=" + totalAmount +
                ", status=" + status +
                ", orderDate=" + orderDate +
                ", lastUpdated=" + lastUpdated +
                '}';
    }
}