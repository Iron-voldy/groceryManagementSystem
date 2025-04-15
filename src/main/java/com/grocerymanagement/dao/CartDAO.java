package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Cart;
import com.grocerymanagement.util.FileHandlerUtil;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class CartDAO {
    private String cartFilePath;

    public CartDAO(FileInitializationUtil fileInitUtil) {
        this.cartFilePath = fileInitUtil.getDataFilePath("cart.txt");
    }

    // Create a new cart
    public boolean createCart(Cart cart) {
        // Validate cart before creating
        if (cart == null || cart.getUserId() == null || cart.getUserId().isEmpty()) {
            return false;
        }

        // Check if a cart already exists for this user
        if (getCartByUserId(cart.getUserId()).isPresent()) {
            return false;
        }

        FileHandlerUtil.writeToFile(cartFilePath, cart.toFileString(), true);
        return true;
    }

    // Get cart by user ID
    public Optional<Cart> getCartByUserId(String userId) {
        return FileHandlerUtil.readFromFile(cartFilePath).stream()
                .map(Cart::fromFileString)
                .filter(cart -> cart.getUserId().equals(userId))
                .findFirst();
    }

    // Get cart by cart ID
    public Optional<Cart> getCartById(String cartId) {
        return FileHandlerUtil.readFromFile(cartFilePath).stream()
                .map(Cart::fromFileString)
                .filter(cart -> cart.getCartId().equals(cartId))
                .findFirst();
    }

    // Update an existing cart
    public boolean updateCart(Cart updatedCart) {
        List<String> lines = FileHandlerUtil.readFromFile(cartFilePath);

        // Find and replace the cart
        boolean cartFound = false;
        for (int i = 0; i < lines.size(); i++) {
            Cart existingCart = Cart.fromFileString(lines.get(i));
            if (existingCart.getCartId().equals(updatedCart.getCartId())) {
                lines.set(i, updatedCart.toFileString());
                cartFound = true;
                break;
            }
        }

        // If cart not found by cartId, try to update by userId
        if (!cartFound) {
            for (int i = 0; i < lines.size(); i++) {
                Cart existingCart = Cart.fromFileString(lines.get(i));
                if (existingCart.getUserId().equals(updatedCart.getUserId())) {
                    lines.set(i, updatedCart.toFileString());
                    cartFound = true;
                    break;
                }
            }
        }

        // Write updated lines back to file
        if (cartFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(cartFilePath)) {
                lines.forEach(writer::println);
                return true;
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating cart: " + e.getMessage());
                return false;
            }
        }

        return false;
    }

    // Delete a cart
    public boolean deleteCart(String cartId) {
        List<String> lines = FileHandlerUtil.readFromFile(cartFilePath);

        boolean cartRemoved = lines.removeIf(line -> {
            Cart cart = Cart.fromFileString(line);
            return cart.getCartId().equals(cartId);
        });

        if (cartRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(cartFilePath)) {
                lines.forEach(writer::println);
                return true;
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting cart: " + e.getMessage());
                return false;
            }
        }

        return false;
    }

    // Get all carts (for admin use)
    public List<Cart> getAllCarts() {
        return FileHandlerUtil.readFromFile(cartFilePath).stream()
                .map(Cart::fromFileString)
                .collect(Collectors.toList());
    }
}