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

    public boolean createCart(Cart cart) {
        if (!validateCart(cart)) {
            return false;
        }

        FileHandlerUtil.writeToFile(cartFilePath, cart.toFileString(), true);
        return true;
    }

    public Optional<Cart> getCartByUserId(String userId) {
        return FileHandlerUtil.readFromFile(cartFilePath).stream()
                .map(Cart::fromFileString)
                .filter(cart -> cart.getUserId().equals(userId))
                .findFirst();
    }

    public Optional<Cart> getCartById(String cartId) {
        return FileHandlerUtil.readFromFile(cartFilePath).stream()
                .map(Cart::fromFileString)
                .filter(cart -> cart.getCartId().equals(cartId))
                .findFirst();
    }

    public boolean updateCart(Cart updatedCart) {
        List<String> lines = FileHandlerUtil.readFromFile(cartFilePath);
        boolean cartFound = false;

        for (int i = 0; i < lines.size(); i++) {
            Cart existingCart = Cart.fromFileString(lines.get(i));
            if (existingCart.getCartId().equals(updatedCart.getCartId())) {
                lines.set(i, updatedCart.toFileString());
                cartFound = true;
                break;
            }
        }

        if (cartFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(cartFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating cart: " + e.getMessage());
                return false;
            }
        }

        return cartFound;
    }

    public boolean deleteCart(String cartId) {
        List<String> lines = FileHandlerUtil.readFromFile(cartFilePath);
        boolean cartRemoved = lines.removeIf(line -> {
            Cart cart = Cart.fromFileString(line);
            return cart.getCartId().equals(cartId);
        });

        if (cartRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(cartFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting cart: " + e.getMessage());
                return false;
            }
        }

        return cartRemoved;
    }

    private boolean validateCart(Cart cart) {
        return cart.getUserId() != null && !cart.getUserId().isEmpty();
    }
}
