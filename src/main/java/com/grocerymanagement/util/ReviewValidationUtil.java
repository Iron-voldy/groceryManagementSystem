package com.grocerymanagement.util;

import com.grocerymanagement.model.Review;

import java.util.regex.Pattern;

public class ReviewValidationUtil {
    // Validate review rating
    public static boolean isValidRating(int rating) {
        return rating >= 1 && rating <= 5;
    }

    // Validate review text length
    public static boolean isValidReviewText(String reviewText) {
        return reviewText != null &&
                reviewText.trim().length() >= 10 &&
                reviewText.trim().length() <= 500;
    }

    // Validate entire review object
    public static boolean isValidReview(Review review) {
        return review != null &&
                review.getUserId() != null && !review.getUserId().isEmpty() &&
                review.getProductId() != null && !review.getProductId().isEmpty() &&
                isValidRating(review.getRating()) &&
                isValidReviewText(review.getReviewText());
    }

    // Sanitize review text to prevent XSS
    public static String sanitizeReviewText(String reviewText) {
        if (reviewText == null) return null;

        // Remove HTML tags
        reviewText = reviewText.replaceAll("<[^>]*>", "");

        // Escape special characters
        reviewText = reviewText.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");

        // Normalize whitespace
        reviewText = reviewText.trim().replaceAll("\\s+", " ");

        return reviewText;
    }

    // Get review status based on conditions
    public static Review.ReviewStatus determineReviewStatus(boolean hasPurchased, boolean isAdmin) {
        if (hasPurchased || isAdmin) {
            return Review.ReviewStatus.APPROVED;
        } else {
            return Review.ReviewStatus.PENDING;
        }
    }

    // Check for profanity or inappropriate content
    public static boolean containsInappropriateContent(String reviewText) {
        if (reviewText == null) return false;

        // Simple example - in production, this would be a more comprehensive list
        String[] inappropriateWords = {"profanity", "explicit", "obscene"};

        String lowerText = reviewText.toLowerCase();
        for (String word : inappropriateWords) {
            if (lowerText.contains(word)) {
                return true;
            }
        }

        return false;
    }

    // Validate that the review is from a verified purchaser
    public static boolean isVerifiedPurchaser(String userId, String productId, boolean hasPurchasedProduct) {
        // This would need to check purchase history in a real implementation
        return hasPurchasedProduct;
    }
}