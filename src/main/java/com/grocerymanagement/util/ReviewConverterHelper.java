package com.grocerymanagement.util;

import com.grocerymanagement.model.Review;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.ReviewDisplayModel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Helper class for transforming Review objects into display models
 * and providing utility methods for review display.
 */
public class ReviewConverterHelper {

    /**
     * Creates a display model for a review with product and user info
     */
    public static ReviewDisplayModel createDisplayModel(
            Review review,
            ProductDAO productDAO,
            UserDAO userDAO,
            OrderDAO orderDAO) {

        Product product = null;
        User user = null;
        boolean verifiedPurchase = false;

        // Get product
        Optional<Product> productOpt = productDAO.getProductById(review.getProductId());
        if (productOpt.isPresent()) {
            product = productOpt.get();
        }

        // Get user
        Optional<User> userOpt = userDAO.getUserById(review.getUserId());
        if (userOpt.isPresent()) {
            user = userOpt.get();
        }

        // Check if verified purchase
        if (orderDAO != null) {
            verifiedPurchase = isVerifiedPurchase(review.getUserId(), review.getProductId(), orderDAO);
        }

        return new ReviewDisplayModel(review, product, user, verifiedPurchase);
    }

    /**
     * Creates a list of display models for a list of reviews
     */
    public static List<ReviewDisplayModel> createDisplayModels(
            List<Review> reviews,
            ProductDAO productDAO,
            UserDAO userDAO,
            OrderDAO orderDAO) {

        List<ReviewDisplayModel> displayModels = new ArrayList<>();

        // Pre-fetch products and users to minimize database calls
        Map<String, Product> productMap = new HashMap<>();
        Map<String, User> userMap = new HashMap<>();

        // Collect unique IDs
        List<String> productIds = new ArrayList<>();
        List<String> userIds = new ArrayList<>();

        for (Review review : reviews) {
            if (!productIds.contains(review.getProductId())) {
                productIds.add(review.getProductId());
            }
            if (!userIds.contains(review.getUserId())) {
                userIds.add(review.getUserId());
            }
        }

        // Fetch products
        for (String productId : productIds) {
            Optional<Product> productOpt = productDAO.getProductById(productId);
            if (productOpt.isPresent()) {
                productMap.put(productId, productOpt.get());
            }
        }

        // Fetch users
        for (String userId : userIds) {
            Optional<User> userOpt = userDAO.getUserById(userId);
            if (userOpt.isPresent()) {
                userMap.put(userId, userOpt.get());
            }
        }

        // Create display models
        for (Review review : reviews) {
            Product product = productMap.get(review.getProductId());
            User user = userMap.get(review.getUserId());
            boolean verifiedPurchase = false;

            if (orderDAO != null) {
                verifiedPurchase = isVerifiedPurchase(review.getUserId(), review.getProductId(), orderDAO);
            }

            displayModels.add(new ReviewDisplayModel(review, product, user, verifiedPurchase));
        }

        return displayModels;
    }

    /**
     * Determines if a user has purchased a product
     */
    private static boolean isVerifiedPurchase(String userId, String productId, OrderDAO orderDAO) {
        List<Order> userOrders = orderDAO.getOrdersByUserId(userId);

        return userOrders.stream()
                .flatMap(order -> order.getItems().stream())
                .anyMatch(item -> item.getProductId().equals(productId));
    }
}