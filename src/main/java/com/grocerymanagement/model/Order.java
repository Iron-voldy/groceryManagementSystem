package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class Order implements Serializable {
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
        PENDING,       // Order created but not processed
        PROCESSING,    // Order is being prepared
        SHIPPED,       // Order has been shipped
        DELIVERED,     // Order successfully delivered
        CANCELLED,     // Order cancelled by user or system
        REFUNDED       // Order refunded
    }

    // Inner class for shipping details
    public static class ShippingDetails implements Serializable {
        private String recipientName;
        private String addressLine1;
        private String addressLine2;
        private String city;
        private String state;
        private String postalCode;
        private String country;
        private String phoneNumber;

        public ShippingDetails() {}

        public ShippingDetails(String recipientName, String addressLine1, String city,
                               String state, String postalCode, String country, String phoneNumber) {
            this.recipientName = recipientName;
            this.addressLine1 = addressLine1;
            this.city = city;
            this.state = state;
            this.postalCode = postalCode;
            this.country = country;
            this.phoneNumber = phoneNumber;
        }

        // Getters and setters
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

        public String toFileString() {
            return String.join("|",
                    nullToEmpty(recipientName),
                    nullToEmpty(addressLine1),
                    nullToEmpty(addressLine2),
                    nullToEmpty(city),
                    nullToEmpty(state),
                    nullToEmpty(postalCode),
                    nullToEmpty(country),
                    nullToEmpty(phoneNumber)
            );
        }

        public static ShippingDetails fromFileString(String line) {
            if (line == null || line.trim().isEmpty()) {
                return null;
            }

            String[] parts = line.split("\\|");
            ShippingDetails details = new ShippingDetails();
            details.recipientName = emptyToNull(parts[0]);
            details.addressLine1 = emptyToNull(parts[1]);
            details.addressLine2 = emptyToNull(parts[2]);
            details.city = emptyToNull(parts[3]);
            details.state = emptyToNull(parts[4]);
            details.postalCode = emptyToNull(parts[5]);
            details.country = emptyToNull(parts[6]);
            details.phoneNumber = emptyToNull(parts[7]);
            return details;
        }

        private static String nullToEmpty(String str) {
            return str == null ? "" : str;
        }

        private static String emptyToNull(String str) {
            return str == null || str.trim().isEmpty() ? null : str;
        }
    }

    // Inner class for order items
    public static class OrderItem implements Serializable {
        private String productId;
        private int quantity;
        private BigDecimal price;
        private String productName;  // Optional: for easier display

        public OrderItem() {}

        public OrderItem(String productId, int quantity, BigDecimal price) {
            this.productId = productId;
            this.quantity = quantity;
            this.price = price;
        }

        public OrderItem(String productId, String productName, int quantity, BigDecimal price) {
            this(productId, quantity, price);
            this.productName = productName;
        }

        // Getters and setters
        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        // Calculate total price for this order item
        public BigDecimal getTotalPrice() {
            return price.multiply(BigDecimal.valueOf(quantity));
        }

        public String toFileString() {
            return String.join("|",
                    productId,
                    String.valueOf(quantity),
                    price.toString(),
                    nullToEmpty(productName)
            );
        }

        public static OrderItem fromFileString(String line) {
            String[] parts = line.split("\\|");
            OrderItem item = new OrderItem(
                    parts[0],
                    Integer.parseInt(parts[1]),
                    new BigDecimal(parts[2])
            );

            // Set product name if available
            if (parts.length > 3 && !parts[3].isEmpty()) {
                item.productName = parts[3];
            }

            return item;
        }

        private static String nullToEmpty(String str) {
            return str == null ? "" : str;
        }
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

    // Business logic methods
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

    public void removeItem(String productId) {
        items.removeIf(item -> item.getProductId().equals(productId));
        recalculateTotalAmount();
    }

    private void recalculateTotalAmount() {
        totalAmount = items.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // Getter and Setter methods
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

    // Serialization method to convert Order to file string
    public String toFileString() {
        // Prepare items as a semicolon-separated string
        String itemsString = items.stream()
                .map(OrderItem::toFileString)
                .collect(Collectors.joining(";"));

        // Prepare shipping details
        String shippingDetailsString = shippingDetails != null
                ? shippingDetails.toFileString()
                : "";

        // Combine all Order details into a pipe-separated string
        return String.join("||",
                orderId,
                userId,
                itemsString,
                totalAmount.toString(),
                status.name(),
                orderDate.toString(),
                lastUpdated.toString(),
                shippingDetailsString
        );
    }

    // Deserialization method to create Order from file string
    public static Order fromFileString(String line) {
        String[] parts = line.split("\\|\\|");

        Order order = new Order();
        order.orderId = parts[0];
        order.userId = parts[1];

        // Parse items
        if (parts.length > 2 && !parts[2].isEmpty()) {
            String[] itemStrings = parts[2].split(";");
            order.items = new ArrayList<>();
            for (String itemString : itemStrings) {
                order.items.add(OrderItem.fromFileString(itemString));
            }
        }

        order.totalAmount = new BigDecimal(parts[3]);
        order.status = OrderStatus.valueOf(parts[4]);
        order.orderDate = LocalDateTime.parse(parts[5]);
        order.lastUpdated = LocalDateTime.parse(parts[6]);

        // Parse shipping details if available
        if (parts.length > 7 && !parts[7].isEmpty()) {
            order.shippingDetails = ShippingDetails.fromFileString(parts[7]);
        } else {
            order.shippingDetails = new ShippingDetails();
        }

        return order;
    }

    // Helper method to calculate total number of items
    public int getTotalItemCount() {
        return items.stream()
                .mapToInt(OrderItem::getQuantity)
                .sum();
    }
}