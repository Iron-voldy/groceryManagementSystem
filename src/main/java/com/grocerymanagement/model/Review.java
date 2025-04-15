package com.grocerymanagement.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.UUID;

public class Review implements Serializable {
    private String reviewId;
    private String userId;
    private String productId;
    private int rating;
    private String reviewText;
    private LocalDateTime reviewDate;
    private ReviewStatus status;

    public enum ReviewStatus {
        APPROVED, PENDING, REJECTED
    }

    // Default constructor
    public Review() {
        this.reviewId = UUID.randomUUID().toString();
        this.reviewDate = LocalDateTime.now();
        this.status = ReviewStatus.PENDING;
    }

    // Constructor with parameters
    public Review(String userId, String productId, int rating, String reviewText) {
        this();
        this.userId = userId;
        this.productId = productId;
        this.rating = rating;
        this.reviewText = reviewText;
    }

    // Getters and setters
    public String getReviewId() { return reviewId; }
    public void setReviewId(String reviewId) { this.reviewId = reviewId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getReviewText() { return reviewText; }
    public void setReviewText(String reviewText) { this.reviewText = reviewText; }

    public LocalDateTime getReviewDate() { return reviewDate; }
    public void setReviewDate(LocalDateTime reviewDate) { this.reviewDate = reviewDate; }

    public ReviewStatus getStatus() { return status; }
    public void setStatus(ReviewStatus status) { this.status = status; }

    // Convert to file string format for storage
    public String toFileString() {
        try {
            // Replace any pipe characters in the text with a safe substitute to avoid parsing issues
            String sanitizedText = reviewText != null ? reviewText.replace("|", "&#124;") : "";

            return String.join("|",
                    reviewId,
                    userId,
                    productId,
                    String.valueOf(rating),
                    sanitizedText,
                    reviewDate.toString(),
                    status.name()
            );
        } catch (Exception e) {
            // For debugging purposes
            System.err.println("Error in toFileString: " + e.getMessage());
            throw e;
        }
    }

    // Create a Review object from a file string
    public static Review fromFileString(String line) {
        try {
            String[] parts = line.split("\\|");
            if (parts.length < 7) {
                throw new IllegalArgumentException("Invalid review data format: " + line);
            }

            Review review = new Review();
            review.reviewId = parts[0];
            review.userId = parts[1];
            review.productId = parts[2];

            try {
                review.rating = Integer.parseInt(parts[3]);
            } catch (NumberFormatException e) {
                // Default to 3 stars if rating is invalid
                review.rating = 3;
                System.err.println("Invalid rating format in review: " + parts[3]);
            }

            review.reviewText = parts[4].replace("&#124;", "|");

            try {
                review.reviewDate = LocalDateTime.parse(parts[5]);
            } catch (DateTimeParseException e) {
                // Default to current time if date is invalid
                review.reviewDate = LocalDateTime.now();
                System.err.println("Invalid date format in review: " + parts[5]);
            }

            try {
                review.status = ReviewStatus.valueOf(parts[6]);
            } catch (IllegalArgumentException e) {
                // Default to PENDING if status is invalid
                review.status = ReviewStatus.PENDING;
                System.err.println("Invalid status in review: " + parts[6]);
            }

            return review;
        } catch (Exception e) {
            // For debugging purposes
            System.err.println("Error in fromFileString: " + e.getMessage() + " for line: " + line);
            throw e;
        }
    }

    @Override
    public String toString() {
        return "Review{" +
                "reviewId='" + reviewId + '\'' +
                ", userId='" + userId + '\'' +
                ", productId='" + productId + '\'' +
                ", rating=" + rating +
                ", status=" + status +
                ", reviewDate=" + reviewDate +
                '}';
    }
}