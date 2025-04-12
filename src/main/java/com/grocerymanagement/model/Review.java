package com.grocerymanagement.model;

import java.io.Serializable;
import java.time.LocalDateTime;
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

    public Review() {
        this.reviewId = UUID.randomUUID().toString();
        this.reviewDate = LocalDateTime.now();
        this.status = ReviewStatus.PENDING;
    }

    public Review(String userId, String productId, int rating, String reviewText) {
        this();
        this.userId = userId;
        this.productId = productId;
        this.rating = rating;
        this.reviewText = reviewText;
    }

    // Getters and setters
    public String getReviewId() { return reviewId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getReviewText() { return reviewText; }
    public void setReviewText(String reviewText) { this.reviewText = reviewText; }
    public LocalDateTime getReviewDate() { return reviewDate; }
    public ReviewStatus getStatus() { return status; }
    public void setStatus(ReviewStatus status) { this.status = status; }

    public String toFileString() {
        return String.join("|",
                reviewId,
                userId,
                productId,
                String.valueOf(rating),
                reviewText.replace("|", "&#124;"),
                reviewDate.toString(),
                status.name()
        );
    }

    public static Review fromFileString(String line) {
        String[] parts = line.split("\\|");
        Review review = new Review();
        review.reviewId = parts[0];
        review.userId = parts[1];
        review.productId = parts[2];
        review.rating = Integer.parseInt(parts[3]);
        review.reviewText = parts[4].replace("&#124;", "|");
        review.reviewDate = LocalDateTime.parse(parts[5]);
        review.status = ReviewStatus.valueOf(parts[6]);
        return review;
    }
}
