package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ReviewDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.Review;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;
import com.grocerymanagement.model.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(urlPatterns = {"/review/*", "/review/delete"})
public class ReviewServlet extends HttpServlet {
    private ReviewDAO reviewDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;
    private OrderDAO orderDAO;
    private FileInitializationUtil fileInitUtil;

    @Override
    public void init() throws ServletException {
        fileInitUtil = new FileInitializationUtil(getServletContext());
        reviewDAO = new ReviewDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
        userDAO = new UserDAO(fileInitUtil);
        orderDAO = new OrderDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            pathInfo = "/list";
        }

        try {
            switch (pathInfo) {
                case "/create":
                case "/submit":
                    showCreateReviewForm(request, response);
                    break;
                case "/edit":
                    showEditReviewForm(request, response);
                    break;
                case "/delete":
                    deleteReview(request, response);
                    break;
                case "/details":
                    showReviewDetails(request, response);
                    break;
                case "/product":
                    showProductReviews(request, response);
                    break;
                case "/user":
                    listUserReviews(request, response);
                    break;
                case "/list":
                default:
                    listAllReviews(request, response);
                    break;
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Fix: Check for null pathInfo and provide a default
        if (pathInfo == null) {
            pathInfo = "/list";
        }

        try {
            switch (pathInfo) {
                case "/create":
                    createReview(request, response);
                    break;
                case "/update":
                    updateReview(request, response);
                    break;
                case "/moderate":
                    moderateReview(request, response);
                    break;
                case "/delete":  // Add support for POST delete
                    deleteReview(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    // Method to display the create review form
    private void showCreateReviewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        String productId = request.getParameter("productId");
        if (productId == null || productId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product/list");
            return;
        }

        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        request.setAttribute("product", productOptional.get());
        request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
    }

    // Method to submit a new review
    private void createReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        // Log the parameters for debugging
        System.out.println("Creating review - ProductID: " + productId +
                ", Rating: " + ratingStr +
                ", Text length: " + (reviewText != null ? reviewText.length() : "null") +
                ", User: " + currentUser.getUserId());

        // Debug to see if the file exists and is writable
        String reviewFilePath = fileInitUtil.getDataFilePath("reviews.txt");
        System.out.println("Reviews file path: " + reviewFilePath);

        // Detailed validation
        if (productId == null || productId.isEmpty()) {
            request.setAttribute("error", "Product ID is missing");
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        if (ratingStr == null || ratingStr.isEmpty()) {
            request.setAttribute("error", "Rating is required");
            request.setAttribute("reviewText", reviewText); // Preserve user input
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        if (reviewText == null || reviewText.trim().isEmpty()) {
            request.setAttribute("error", "Review text is required");
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        // Validate review text length (minimum 10 characters)
        if (reviewText.trim().length() < 10) {
            request.setAttribute("error", "Review text must be at least 10 characters long");
            request.setAttribute("reviewText", reviewText); // Preserve user input
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        int rating;
        try {
            rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                throw new NumberFormatException("Rating must be between 1 and 5");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid rating. Please provide a rating between 1 and 5");
            request.setAttribute("reviewText", reviewText); // Preserve user input
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        // Check if user has already reviewed this product
        boolean hasReviewed = reviewDAO.hasUserReviewedProduct(currentUser.getUserId(), productId);
        if (hasReviewed) {
            request.setAttribute("error", "You have already reviewed this product");
            request.setAttribute("reviewText", reviewText); // Preserve user input
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        try {
            // Create and save the new review
            Review newReview = new Review(currentUser.getUserId(), productId, rating, reviewText);

            // Check if user has purchased this product
            boolean hasPurchased = hasUserPurchasedProduct(currentUser.getUserId(), productId);

            // Verified purchasers' reviews are auto-approved, others need moderation
            if (hasPurchased || currentUser.getRole() == User.UserRole.ADMIN) {
                newReview.setStatus(Review.ReviewStatus.APPROVED);
            } else {
                newReview.setStatus(Review.ReviewStatus.PENDING);
            }

            // Try to create the review and handle the result
            boolean created = reviewDAO.createReview(newReview);

            if (created) {
                // Set a success message and the review as attributes
                request.setAttribute("success", "Review submitted successfully. " +
                        (!hasPurchased && currentUser.getRole() != User.UserRole.ADMIN ?
                                "Your review will be visible after moderation." : ""));
                request.setAttribute("review", newReview);

                // Redirect to success page or back to product
                request.getRequestDispatcher("/views/review/success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to submit review. Please try again.");
                request.setAttribute("reviewText", reviewText); // Preserve user input
                request.setAttribute("product", productOptional.get());
                request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Log the exception for debugging
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.setAttribute("reviewText", reviewText); // Preserve user input
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
        }
    }

    // Method to update an existing review
    private void updateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String reviewId = request.getParameter("reviewId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        if (reviewId == null || ratingStr == null || reviewText == null) {
            request.setAttribute("error", "All fields are required");
            response.sendRedirect(request.getContextPath() + "/review/user");
            return;
        }

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();

        // Ensure only the review owner or an admin can update
        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to update this review");
            return;
        }

        int rating;
        try {
            rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                throw new NumberFormatException("Rating must be between 1 and 5");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid rating. Please provide a rating between 1 and 5");
            request.setAttribute("review", review);

            // Get product for display
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                request.setAttribute("product", productOptional.get());
            }

            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
            return;
        }

        try {
            // Update review
            review.setRating(rating);
            review.setReviewText(reviewText);

            // If not admin, set back to pending for re-moderation
            if (currentUser.getRole() != User.UserRole.ADMIN &&
                    review.getStatus() == Review.ReviewStatus.APPROVED) {
                review.setStatus(Review.ReviewStatus.PENDING);
            }

            if (reviewDAO.updateReview(review)) {
                request.setAttribute("success", "Review updated successfully");
                response.sendRedirect(request.getContextPath() + "/review/details?reviewId=" + reviewId);
            } else {
                request.setAttribute("error", "Failed to update review. Please try again.");

                // Get product for display
                Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
                if (productOptional.isPresent()) {
                    request.setAttribute("product", productOptional.get());
                }

                request.setAttribute("review", review);
                request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());

            // Get product for display
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                request.setAttribute("product", productOptional.get());
            }

            request.setAttribute("review", review);
            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
        }
    }

    // Method to display the edit review form
    private void showEditReviewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String reviewId = request.getParameter("reviewId");

        if (reviewId == null || reviewId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/review/user");
            return;
        }

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            // Forward to the edit page which will handle the null review case
            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();

        // Ensure only the review owner or an admin can edit
        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to edit this review");
            return;
        }

        // Get product info
        Optional<Product> productOptional = productDAO.getProductById(review.getProductId());

        // Always set the review attribute
        request.setAttribute("review", review);

        if (productOptional.isPresent()) {
            request.setAttribute("product", productOptional.get());
        }

        request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
    }

    // Method to delete a review
    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            if (isAjaxRequest(request)) {
                sendJsonResponse(response, false, "You must be logged in to delete reviews");
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
                return;
            }
        }

        User currentUser = (User) session.getAttribute("user");
        String reviewId = request.getParameter("reviewId");

        if (reviewId == null || reviewId.trim().isEmpty()) {
            if (isAjaxRequest(request)) {
                sendJsonResponse(response, false, "Review ID is required");
            } else {
                request.setAttribute("error", "Review ID is required");
                response.sendRedirect(request.getContextPath() + "/review/user");
            }
            return;
        }

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            if (isAjaxRequest(request)) {
                sendJsonResponse(response, false, "Review not found");
            } else {
                request.setAttribute("error", "Review not found");
                response.sendRedirect(request.getContextPath() + "/review/user");
            }
            return;
        }

        Review review = reviewOptional.get();

        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            if (isAjaxRequest(request)) {
                sendJsonResponse(response, false, "You are not authorized to delete this review");
            } else {
                request.setAttribute("error", "You are not authorized to delete this review");
                response.sendRedirect(request.getContextPath() + "/review/user");
            }
            return;
        }

        try {
            boolean success = reviewDAO.deleteReview(reviewId);
            if (success) {
                if (isAjaxRequest(request)) {
                    sendJsonResponse(response, true, "Review deleted successfully");
                } else {
                    request.getSession().setAttribute("success", "Review deleted successfully");
                    response.sendRedirect(request.getContextPath() + "/review/user");
                }
            } else {
                if (isAjaxRequest(request)) {
                    sendJsonResponse(response, false, "Failed to delete review");
                } else {
                    request.getSession().setAttribute("error", "Failed to delete review");
                    response.sendRedirect(request.getContextPath() + "/review/user");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (isAjaxRequest(request)) {
                sendJsonResponse(response, false, "Error processing your request: " + e.getMessage());
            } else {
                request.setAttribute("error", "Error processing your request: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/review/user");
            }
        }
    }


    // Method to moderate a review (for admins)
    private void moderateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String reviewId = request.getParameter("reviewId");
        String statusStr = request.getParameter("status");

        if (reviewId == null || statusStr == null || statusStr.isEmpty()) {
            request.setAttribute("error", "Missing required parameters");
            request.getRequestDispatcher("/views/admin/reviews.jsp").forward(request, response);
            return;
        }

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        try {
            review.setStatus(Review.ReviewStatus.valueOf(statusStr));
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid status value");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            return;
        }

        if (reviewDAO.updateReview(review)) {
            request.setAttribute("success", "Review moderated successfully");
            response.sendRedirect(request.getContextPath() + "/review/details?reviewId=" + reviewId);
        } else {
            request.setAttribute("error", "Failed to moderate review");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // Method to show review details
    private void showReviewDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        String reviewId = request.getParameter("reviewId");
        if (reviewId == null || reviewId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/review/user");
            return;
        }

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            // Set null attributes so the JSP can handle the error case
            request.setAttribute("review", null);
            request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        Optional<Product> productOptional = productDAO.getProductById(review.getProductId());

        // Always set the review attribute
        request.setAttribute("review", review);

        if (productOptional.isPresent()) {
            request.setAttribute("product", productOptional.get());
        }

        request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
    }

    // Method to show all reviews for a product
    private void showProductReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productId = request.getParameter("productId");
        if (productId == null || productId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product/list");
            return;
        }

        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        // Get approved reviews for the product
        List<Review> reviews = reviewDAO.getReviewsByProductId(
                productId,
                Review.ReviewStatus.APPROVED,
                null,
                Comparator.comparing(Review::getReviewDate).reversed()
        );

        // Calculate average rating
        double averageRating = reviewDAO.calculateAverageRatingForProduct(productId);
        ReviewDAO.ReviewStatistics stats = reviewDAO.getProductReviewStatistics(productId);

        request.setAttribute("product", productOptional.get());
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/views/review/product-reviews.jsp").forward(request, response);
    }

    // Method to list all reviews for the logged-in user
    private void listUserReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<Review> reviews = reviewDAO.getReviewsByUserId(currentUser.getUserId());

        // Fetch product details for all reviews
        Map<String, Product> productMap = new HashMap<>();
        for (Review review : reviews) {
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                productMap.put(review.getProductId(), productOptional.get());
            }
        }

        request.setAttribute("reviews", reviews);
        request.setAttribute("productMap", productMap);
        request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
    }

    // Method to list all reviews (admin only)
    private void listAllReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendRedirect(request.getContextPath() + "/review/user");
            return;
        }

        // Get filters from request
        String statusFilter = request.getParameter("status");
        String ratingFilter = request.getParameter("rating");
        String sortBy = request.getParameter("sort");

        // Get all reviews with optional filtering
        List<Review> reviews;
        if (statusFilter != null && !statusFilter.isEmpty()) {
            try {
                Review.ReviewStatus status = Review.ReviewStatus.valueOf(statusFilter);
                reviews = reviewDAO.getReviewsByProductId(null, status, null, null);
            } catch (IllegalArgumentException e) {
                reviews = getAllReviews();
            }
        } else {
            // Get all reviews
            reviews = getAllReviews();
        }

        // Add product and user names to reviews
        for (Review review : reviews) {
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                // We could add product name to Review class, but for now we'll use request attribute
                request.setAttribute("product_" + review.getReviewId(), productOptional.get().getName());
            }

            Optional<User> userOptional = userDAO.getUserById(review.getUserId());
            if (userOptional.isPresent()) {
                request.setAttribute("user_" + review.getReviewId(), userOptional.get().getUsername());
            }
        }

        // Calculate review stats
        int totalReviews = reviews.size();
        int approvedReviews = (int) reviews.stream()
                .filter(r -> r.getStatus() == Review.ReviewStatus.APPROVED)
                .count();
        int pendingReviews = (int) reviews.stream()
                .filter(r -> r.getStatus() == Review.ReviewStatus.PENDING)
                .count();

        double averageRating = reviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);

        request.setAttribute("reviews", reviews);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("stats", new ReviewStats(totalReviews, approvedReviews, pendingReviews, averageRating));
        request.getRequestDispatcher("/views/admin/reviews.jsp").forward(request, response);
    }

    // Helper method to get all reviews
    private List<Review> getAllReviews() {
        // In a real database implementation, you'd have a method to get all reviews
        // For file-based implementation, we'll get for all products
        return reviewDAO.getAllReviews();
    }

    // Helper method to check if user has purchased a product
    private boolean hasUserPurchasedProduct(String userId, String productId) {
        List<Order> userOrders = orderDAO.getOrdersByUserId(userId);

        // Check if any order contains the product
        return userOrders.stream()
                .flatMap(order -> order.getItems().stream())
                .anyMatch(item -> item.getProductId().equals(productId));
    }

    // Helper method to check if the current user is an admin
    private boolean isAdminUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return false;
        }
        User user = (User) session.getAttribute("user");
        return user.getRole() == User.UserRole.ADMIN;
    }

    // Helper method to check if a request is an AJAX request
    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    // Helper method to send a JSON response
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + ",\"message\":\"" + message + "\"}");
        out.flush();
    }

    // Helper method to handle errors
    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        e.printStackTrace();
        request.setAttribute("error", "An error occurred: " + e.getMessage());
        request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
    }

    // Helper class for review statistics
    public static class ReviewStats {
        private int totalReviews;
        private int approvedReviews;
        private int pendingReviews;
        private double averageRating;
        private int approvedPercentage;
        private int pendingPercentage;

        public ReviewStats(int totalReviews, int approvedReviews, int pendingReviews, double averageRating) {
            this.totalReviews = totalReviews;
            this.approvedReviews = approvedReviews;
            this.pendingReviews = pendingReviews;
            this.averageRating = averageRating;

            if (totalReviews > 0) {
                this.approvedPercentage = (int) ((double) approvedReviews / totalReviews * 100);
                this.pendingPercentage = (int) ((double) pendingReviews / totalReviews * 100);
            }
        }

        public int getTotalReviews() { return totalReviews; }
        public int getApprovedReviews() { return approvedReviews; }
        public int getPendingReviews() { return pendingReviews; }
        public double getAverageRating() { return averageRating; }
        public int getApprovedPercentage() { return approvedPercentage; }
        public int getPendingPercentage() { return pendingPercentage; }
    }
}