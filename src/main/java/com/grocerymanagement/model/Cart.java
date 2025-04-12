package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Cart implements Serializable {
    private String cartId;
    private String userId;
    private List<CartItem> items;
    private LocalDateTime lastUpdated;

    public static class CartItem implements Serializable {
        private String productId;
        private int quantity;
        private BigDecimal price;

        public CartItem(String productId, int quantity, BigDecimal price) {
            this.productId = productId;
            this.quantity = quantity;
            this.price = price;
        }

        // Getters and setters
        public String getProductId() { return productId; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public BigDecimal getPrice() { return price; }

        public String toFileString() {
            return String.join("|", productId, String.valueOf(quantity), price.toString());
        }

        public static CartItem fromFileString(String line) {
            String[] parts = line.split("\\|");
            return new CartItem(parts[0], Integer.parseInt(parts[1]), new BigDecimal(parts[2]));
        }
    }

    public Cart() {
        this.cartId = UUID.randomUUID().toString();
        this.items = new ArrayList<>();
        this.lastUpdated = LocalDateTime.now();
    }

    public Cart(String userId) {
        this();
        this.userId = userId;
    }

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

    public BigDecimal calculateTotal() {
        return items.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // Getters and setters
    public String getCartId() { return cartId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public List<CartItem> getItems() { return items; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }

    public String toFileString() {
        List<String> itemStrings = items.stream()
                .map(CartItem::toFileString)
                .toList();

        return String.join("||",
                cartId,
                userId,
                String.join(";", itemStrings),
                lastUpdated.toString()
        );
    }

    public static Cart fromFileString(String line) {
        String[] parts = line.split("\\|\\|");
        Cart cart = new Cart();
        cart.cartId = parts[0];
        cart.userId = parts[1];

        // Parse items
        if (parts.length > 2 && !parts[2].isEmpty()) {
            String[] itemStrings = parts[2].split(";");
            for (String itemString : itemStrings) {
                cart.items.add(CartItem.fromFileString(itemString));
            }
        }

        cart.lastUpdated = LocalDateTime.parse(parts[3]);
        return cart;
    }
}
