package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class Cart implements Serializable {
    private String cartId;
    private String userId;
    private List<CartItem> items;
    private LocalDateTime lastUpdated;

    // Static formatter to ensure consistent date parsing
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    // Inner class for cart items
    public static class CartItem implements Serializable {
        private String productId;
        private int quantity;
        private BigDecimal price;
        private String productName; // Optional: for easier display

        // Constructors
        public CartItem() {}

        public CartItem(String productId, int quantity, BigDecimal price) {
            this.productId = productId;
            this.quantity = quantity;
            this.price = price;
        }

        public CartItem(String productId, int quantity, BigDecimal price, String productName) {
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

        // Serialize to file string
        public String toFileString() {
            return String.join("|",
                    nullToEmpty(productId),
                    String.valueOf(quantity),
                    price.toString(),
                    nullToEmpty(productName)
            );
        }

        // Deserialize from file string
        public static CartItem fromFileString(String line) {
            String[] parts = line.split("\\|");
            if (parts.length < 3) {
                throw new IllegalArgumentException("Invalid cart item format: " + line);
            }

            CartItem item = new CartItem(
                    emptyToNull(parts[0]),
                    Integer.parseInt(parts[1]),
                    new BigDecimal(parts[2])
            );

            // Set product name if available
            if (parts.length > 3) {
                item.productName = emptyToNull(parts[3]);
            }

            return item;
        }

        // Helper methods to handle null/empty strings
        private static String nullToEmpty(String str) {
            return str == null ? "" : str;
        }

        private static String emptyToNull(String str) {
            return str == null || str.trim().isEmpty() ? null : str;
        }
    }

    // Constructors
    public Cart() {
        this.cartId = UUID.randomUUID().toString();
        this.items = new ArrayList<>();
        this.lastUpdated = LocalDateTime.now();
    }

    public Cart(String userId) {
        this();
        this.userId = userId;
    }

    // Business logic methods
    public void addItem(CartItem item) {
        // Check if item already exists and update quantity
        for (CartItem existingItem : items) {
            if (existingItem.getProductId().equals(item.getProductId())) {
                existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
                lastUpdated = LocalDateTime.now();
                return;
            }
        }

        // If item not found, add new item
        items.add(item);
        lastUpdated = LocalDateTime.now();
    }

    public void removeItem(String productId) {
        items.removeIf(item -> item.getProductId().equals(productId));
        lastUpdated = LocalDateTime.now();
    }

    // Getters and setters
    public String getCartId() { return cartId; }
    public void setCartId(String cartId) { this.cartId = cartId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) {
        this.items = items;
        this.lastUpdated = LocalDateTime.now();
    }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    // Serialize to file string
    public String toFileString() {
        // Convert items to file string
        String itemsString = items.stream()
                .map(CartItem::toFileString)
                .collect(Collectors.joining(";"));

        return String.join("||",
                nullToEmpty(cartId),
                nullToEmpty(userId),
                itemsString,
                lastUpdated.format(DATE_FORMATTER)
        );
    }

    // Deserialize from file string
    public static Cart fromFileString(String line) {
        // Split the line, handling potential leading pipe
        String[] parts = line.startsWith("|") ? line.substring(1).split("\\|\\|") : line.split("\\|\\|");

        if (parts.length < 4) {
            throw new IllegalArgumentException("Invalid cart format: " + line);
        }

        Cart cart = new Cart();
        cart.cartId = emptyToNull(parts[0]);
        cart.userId = emptyToNull(parts[1]);

        // Parse items if present
        if (!parts[2].isEmpty()) {
            String[] itemStrings = parts[2].split(";");
            cart.items = new ArrayList<>();
            for (String itemString : itemStrings) {
                cart.items.add(CartItem.fromFileString(itemString));
            }
        }

        // Parse last updated timestamp
        try {
            cart.lastUpdated = LocalDateTime.parse(parts[3], DATE_FORMATTER);
        } catch (Exception e) {
            // If parsing fails, use current time
            cart.lastUpdated = LocalDateTime.now();
        }

        return cart;
    }

    // Helper methods to handle null/empty strings
    private static String nullToEmpty(String str) {
        return str == null ? "" : str;
    }

    private static String emptyToNull(String str) {
        return str == null || str.trim().isEmpty() ? null : str;
    }
}