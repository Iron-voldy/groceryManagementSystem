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

    public enum OrderStatus {
        PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
    }

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

    // OrderItem Inner Class
    public static class OrderItem implements Serializable {
        private String productId;
        private String productName;
        private int quantity;
        private BigDecimal price;

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

        public BigDecimal getTotalPrice() {
            return price.multiply(BigDecimal.valueOf(quantity));
        }
    }

    // Shipping Details Inner Class
    public static class ShippingDetails implements Serializable {
        private String recipientName;
        private String addressLine1;
        private String addressLine2;
        private String city;
        private String state;
        private String postalCode;
        private String country;
        private String phoneNumber;

        // Constructors, getters, and setters
        public ShippingDetails() {}

        public String getRecipientName() {
            return recipientName;
        }

        public void setRecipientName(String recipientName) {
            this.recipientName = recipientName;
        }

        public String getAddressLine1() {
            return addressLine1;
        }

        public void setAddressLine1(String addressLine1) {
            this.addressLine1 = addressLine1;
        }

        public String getAddressLine2() {
            return addressLine2;
        }

        public void setAddressLine2(String addressLine2) {
            this.addressLine2 = addressLine2;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getState() {
            return state;
        }

        public void setState(String state) {
            this.state = state;
        }

        public String getPostalCode() {
            return postalCode;
        }

        public void setPostalCode(String postalCode) {
            this.postalCode = postalCode;
        }

        public String getCountry() {
            return country;
        }

        public void setCountry(String country) {
            this.country = country;
        }

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public void setPhoneNumber(String phoneNumber) {
            this.phoneNumber = phoneNumber;
        }
    }

    // Business Logic Methods
    public void addItem(OrderItem item) {
        // Check if item exists and update quantity
        for (OrderItem existingItem : items) {
            if (existingItem.getProductId().equals(item.getProductId())) {
                existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
                recalculateTotalAmount();
                return;
            }
        }

        // Add new item
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

    // Serialization Methods
    public String toFileString() {
        // Convert items to file string
        String itemsString = items.stream()
                .map(this::orderItemToFileString)
                .collect(Collectors.joining(";"));

        return String.join("||",
                orderId,
                userId,
                itemsString,
                totalAmount.toString(),
                status.name(),
                orderDate.toString(),
                lastUpdated.toString()
        );
    }

    public static Order fromFileString(String line) {
        String[] parts = line.split("\\|\\|");

        Order order = new Order();
        order.orderId = parts[0];
        order.userId = parts[1];

        // Parse items
        if (!parts[2].isEmpty()) {
            String[] itemStrings = parts[2].split(";");
            order.items = new ArrayList<>();
            for (String itemString : itemStrings) {
                order.items.add(orderItemFromFileString(itemString));
            }
        }

        order.totalAmount = new BigDecimal(parts[3]);
        order.status = OrderStatus.valueOf(parts[4]);
        order.orderDate = LocalDateTime.parse(parts[5]);
        order.lastUpdated = LocalDateTime.parse(parts[6]);

        return order;
    }

    private String orderItemToFileString(OrderItem item) {
        return String.join("|",
                item.getProductId(),
                item.getProductName(),
                String.valueOf(item.getQuantity()),
                item.getPrice().toString()
        );
    }

    private static OrderItem orderItemFromFileString(String line) {
        String[] parts = line.split("\\|");
        return new OrderItem(
                parts[0],
                parts[1],
                Integer.parseInt(parts[2]),
                new BigDecimal(parts[3])
        );
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
}