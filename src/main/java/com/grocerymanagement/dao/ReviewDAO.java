package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Review;
import com.grocerymanagement.util.FileHandlerUtil;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class ReviewDAO {
    private String reviewFilePath;

    public ReviewDAO(FileInitializationUtil fileInitUtil) {
        this.reviewFilePath = fileInitUtil.getDataFilePath("reviews.txt");
    }

    public boolean createReview(Review review) {
        if (!validateReview(review)) {
            return false;
        }

        FileHandlerUtil.writeToFile(reviewFilePath, review.toFileString(), true);
        return true;
    }

    public Optional<Review> getReviewById(String reviewId) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getReviewId().equals(reviewId))
                .findFirst();
    }

    public List<Review> getReviewsByProductId(String productId) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getProductId().equals(productId))
                .collect(Collectors.toList());
    }

    public List<Review> getReviewsByUserId(String userId) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    public List<Review> getReviewsByStatus(Review.ReviewStatus status) {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .filter(review -> review.getStatus() == status)
                .collect(Collectors.toList());
    }

    public List<Review> getAllReviews() {
        return FileHandlerUtil.readFromFile(reviewFilePath).stream()
                .map(Review::fromFileString)
                .collect(Collectors.toList());
    }

    public boolean updateReview(Review updatedReview) {
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

    public boolean deleteReview(String reviewId) {
        List<String> lines = FileHandlerUtil.readFromFile(reviewFilePath);
        boolean reviewRemoved = lines.removeIf(line -> {
            Review review = Review.fromFileString(line);
            return review.getReviewId().equals(reviewId);
        });

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

    public double calculateAverageRatingForProduct(String productId) {
        List<Review> productReviews = getReviewsByProductId(productId);

        return productReviews.stream()
                .filter(review -> review.getStatus() == Review.ReviewStatus.APPROVED)
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);
    }

    private boolean validateReview(Review review) {
        return review.getUserId() != null && !review.getUserId().isEmpty() &&
                review.getProductId() != null && !review.getProductId().isEmpty() &&
                review.getRating() >= 1 && review.getRating() <= 5;
    }
}
