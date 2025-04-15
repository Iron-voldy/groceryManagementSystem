package com.grocerymanagement.util;

import com.grocerymanagement.model.Review;

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

        return reviewText.trim();
    }

    // Get review status based on conditions
    public static Review.ReviewStatus determineReviewStatus(boolean hasPurchased) {
        return hasPurchased ?
                Review.ReviewStatus.APPROVED :
                Review.ReviewStatus.PENDING;
    }
}