package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Review;
import com.grocerymanagement.util.FileHandlerUtil;
import com.grocerymanagement.util.ReviewValidationUtil;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

public class ReviewDAO {
    private String reviewFilePath;

    public ReviewDAO(FileInitializationUtil fileInitUtil) {
        this.reviewFilePath = fileInitUtil.getDataFilePath("reviews.txt");
    }

    // Create a new review with validation
    public boolean createReview(Review review) {
        // Validate review before creating
        if (!ReviewValidationUtil.isValidReview(review)) {
            return false;
        }

        // Sanitize review text
        review.setReviewText(
                ReviewValidationUtil.sanitizeReviewText(review.getReviewText())
        );

        // Add to file
        FileHandlerUtil.writeToFile(
                reviewFilePath,
                review.toFileString(),
                true
        );
        return true;
    }

    // Get review by ID
    public Optional<Review> getReviewById(String reviewId) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getReviewId().equals(reviewId))
                .findFirst();
    }

    // Get reviews by product ID with sorting and filtering
    public List<Review> getReviewsByProductId(
            String productId,
            Review.ReviewStatus status,
            Integer minRating,
            Comparator<Review> sortOrder
    ) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getProductId().equals(productId))
                .filter(review -> status == null || review.getStatus() == status)
                .filter(review -> minRating == null || review.getRating() >= minRating)
                .sorted(sortOrder != null ? sortOrder : Comparator.comparing(Review::getReviewDate).reversed())
                .collect(Collectors.toList());
    }

    // Get reviews by user ID
    public List<Review> getReviewsByUserId(String userId) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getUserId().equals(userId))
                .sorted(Comparator.comparing(Review::getReviewDate).reversed())
                .collect(Collectors.toList());
    }

    // Update review with validation
    public boolean updateReview(Review updatedReview) {
        // Validate review
        if (!ReviewValidationUtil.isValidReview(updatedReview)) {
            return false;
        }

        // Sanitize review text
        updatedReview.setReviewText(
                ReviewValidationUtil.sanitizeReviewText(updatedReview.getReviewText())
        );

        List<String> lines = FileHandlerUtil.readFromFile(reviewFilePath);
        boolean reviewFound = false;

        for (int i = 0; i < lines.size(); i++) {
            Review existingReview = Review.fromFileString(lines.get(i));
            if (existingReview.getReviewId().equals(updatedReview.getReviewId())) {
                lines.set(i, updatedReview.toFileString());
                reviewFound = true;
                break;
            }
        }

        if (reviewFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(reviewFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating review: " + e.getMessage());
                return false;
            }
        }

        return reviewFound;
    }

    // Delete review
    public boolean deleteReview(String reviewId) {
        List<String> lines = FileHandlerUtil.readFromFile(reviewFilePath);
        boolean reviewRemoved = false;

        // Use an iterator-style removal to avoid mutability issues
        lines = lines.stream()
                .filter(line -> {
                    Review review = Review.fromFileString(line);
                    boolean shouldKeep = !review.getReviewId().equals(reviewId);
                    if (!shouldKeep) {
                        reviewRemoved = true;
                    }
                    return shouldKeep;
                })
                .collect(Collectors.toList());

        if (reviewRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(reviewFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting review: " + e.getMessage());
                return false;
            }
        }

        return reviewRemoved;
    }

    // Calculate average rating for a product
    public double calculateAverageRatingForProduct(String productId) {
        List<Review> approvedReviews = getReviewsByProductId(
                productId,
                Review.ReviewStatus.APPROVED,
                null,
                null
        );

        return approvedReviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);
    }

    // Get review statistics for a product
    public ReviewStatistics getProductReviewStatistics(String productId) {
        List<Review> reviews = getReviewsByProductId(
                productId,
                Review.ReviewStatus.APPROVED,
                null,
                null
        );

        ReviewStatistics stats = new ReviewStatistics();
        stats.totalReviews = reviews.size();
        stats.averageRating = calculateAverageRatingForProduct(productId);

        // Rating distribution
        Map<Integer, Integer> distribution = new HashMap<>();
        for (int rating = 1; rating <= 5; rating++) {
            final int currentRating = rating;
            int count = (int) reviews.stream()
                    .filter(r -> r.getRating() == currentRating)
                    .count();
            distribution.put(currentRating, count);
        }
        stats.ratingDistribution = distribution;

        return stats;
    }

    // Inner class for review statistics
    public static class ReviewStatistics {
        public int totalReviews;
        public double averageRating;
        public Map<Integer, Integer> ratingDistribution = new HashMap<>();
    }
}