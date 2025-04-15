package com.grocerymanagement.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * A display model class for reviews that includes additional
 * information beyond what's in the basic Review model.
 * This is used for presentation purposes only.
 */
public class ReviewDisplayModel implements Serializable {
    private Review review;
    private String productName;
    private String productImagePath;
    private String productCategory;
    private String userName;
    private boolean verifiedPurchase;

    public ReviewDisplayModel(Review review) {
        this.review = review;
    }

    public ReviewDisplayModel(Review review, Product product, User user, boolean verifiedPurchase) {
        this.review = review;
        if (product != null) {
            this.productName = product.getName();
            this.productImagePath = product.getImagePath();
            this.productCategory = product.getCategory();
        }
        if (user != null) {
            this.userName = user.getUsername();
        } else {
            this.userName = review.getUserId();
        }
        this.verifiedPurchase = verifiedPurchase;
    }

    // Delegate methods to the Review object
    public String getReviewId() { return review.getReviewId(); }
    public String getUserId() { return review.getUserId(); }
    public String getProductId() { return review.getProductId(); }
    public int getRating() { return review.getRating(); }
    public String getReviewText() { return review.getReviewText(); }
    public LocalDateTime getReviewDate() { return review.getReviewDate(); }
    public Review.ReviewStatus getStatus() { return review.getStatus(); }

    // Additional display properties
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductImagePath() { return productImagePath; }
    public void setProductImagePath(String productImagePath) { this.productImagePath = productImagePath; }

    public String getProductCategory() { return productCategory; }
    public void setProductCategory(String productCategory) { this.productCategory = productCategory; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public boolean isVerifiedPurchase() { return verifiedPurchase; }
    public void setVerifiedPurchase(boolean verifiedPurchase) { this.verifiedPurchase = verifiedPurchase; }

    // Get the underlying Review object
    public Review getReview() { return review; }
}