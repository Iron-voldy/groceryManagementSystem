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
                case "/delete":
                    deleteReview(request, response);
                    break;
                case "/update-status":
                    updateReviewStatus(request, response);
                    break;
                case "/bulk-action":
                    // bulkActionReviews(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

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

        System.out.println("Creating review - ProductID: " + productId +
                ", Rating: " + ratingStr +
                ", Text length: " + (reviewText != null ? reviewText.length() : "null") +
                ", User: " + currentUser.getUserId());

        String reviewFilePath = fileInitUtil.getDataFilePath("reviews.txt");
        System.out.println("Reviews file path: " + reviewFilePath);

        if (productId == null || productId.isEmpty()) {
            request.setAttribute("error", "Product ID is missing");
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        if (ratingStr == null || ratingStr.isEmpty()) {
            request.setAttribute("error", "Rating is required");
            request.setAttribute("reviewText", reviewText);
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

        if (reviewText.trim().length() < 10) {
            request.setAttribute("error", "Review text must be at least 10 characters long");
            request.setAttribute("reviewText", reviewText);
            request.setAttribute("product", productDAO.getProductById(productId).orElse(null));
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        Product product = productOptional.get();

        int rating;
        try {
            rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                throw new NumberFormatException("Rating must be between 1 and 5");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid rating. Please provide a rating between 1 and 5");
            request.setAttribute("reviewText", reviewText);
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        boolean hasReviewed = reviewDAO.hasUserReviewedProduct(currentUser.getUserId(), productId);
        if (hasReviewed) {
            request.setAttribute("error", "You have already reviewed this product");
            request.setAttribute("reviewText", reviewText);
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            return;
        }

        try {
            Review newReview = new Review(currentUser.getUserId(), productId, rating, reviewText);
            newReview.setProductName(product.getName());
            newReview.setUserName(currentUser.getUsername());

            boolean hasPurchased = hasUserPurchasedProduct(currentUser.getUserId(), productId);
            if (hasPurchased || currentUser.getRole() == User.UserRole.ADMIN) {
                newReview.setStatus(Review.ReviewStatus.APPROVED);
            } else {
                newReview.setStatus(Review.ReviewStatus.PENDING);
            }

            boolean created = reviewDAO.createReview(newReview);
            if (created) {
                request.setAttribute("success", "Review submitted successfully. " +
                        (!hasPurchased && currentUser.getRole() != User.UserRole.ADMIN ?
                                "Your review will be visible after moderation." : ""));
                request.setAttribute("review", newReview);
                request.getRequestDispatcher("/views/review/success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to submit review. Please try again.");
                request.setAttribute("reviewText", reviewText);
                request.setAttribute("product", productOptional.get());
                request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.setAttribute("reviewText", reviewText);
            request.setAttribute("product", productOptional.get());
            request.getRequestDispatcher("/views/review/create-review.jsp").forward(request, response);
        }
    }

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
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                request.setAttribute("product", productOptional.get());
            }
            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
            return;
        }

        try {
            review.setRating(rating);
            review.setReviewText(reviewText);
            if (currentUser.getRole() != User.UserRole.ADMIN &&
                    review.getStatus() == Review.ReviewStatus.APPROVED) {
                review.setStatus(Review.ReviewStatus.PENDING);
            }

            if (reviewDAO.updateReview(review)) {
                request.setAttribute("success", "Review updated successfully");
                response.sendRedirect(request.getContextPath() + "/review/details?reviewId=" + reviewId);
            } else {
                request.setAttribute("error", "Failed to update review. Please try again.");
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
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                request.setAttribute("product", productOptional.get());
            }
            request.setAttribute("review", review);
            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
        }
    }

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
            request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to edit this review");
            return;
        }

        Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
        request.setAttribute("review", review);
        if (productOptional.isPresent()) {
            request.setAttribute("product", productOptional.get());
        }
        request.getRequestDispatcher("/views/review/edit-review.jsp").forward(request, response);
    }

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
            request.setAttribute("review", null);
            request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
        request.setAttribute("review", review);
        if (productOptional.isPresent()) {
            request.setAttribute("product", productOptional.get());
        }
        request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
    }

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

        List<Review> reviews = reviewDAO.getReviewsByProductId(
                productId,
                Review.ReviewStatus.APPROVED,
                null,
                Comparator.comparing(Review::getReviewDate).reversed()
        );

        double averageRating = reviewDAO.calculateAverageRatingForProduct(productId);
        ReviewDAO.ReviewStatistics stats = reviewDAO.getProductReviewStatistics(productId);

        request.setAttribute("product", productOptional.get());
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/views/review/product-reviews.jsp").forward(request, response);
    }

    private void listUserReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<Review> reviews = reviewDAO.getReviewsByUserId(currentUser.getUserId());

        Map<String, Product> productMap = new HashMap<>();
        for (Review review : reviews) {
            Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
            if (productOptional.isPresent()) {
                productMap.put(review.getProductId(), productOptional.get());
                if (review.getProductName() == null || review.getProductName().isEmpty()) {
                    review.setProductName(productOptional.get().getName());
                }
            }
            if (review.getUserName() == null || review.getUserName().isEmpty()) {
                review.setUserName(currentUser.getUsername());
            }
        }

        request.setAttribute("reviews", reviews);
        request.setAttribute("productMap", productMap);
        request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
    }

    private void listAllReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendRedirect(request.getContextPath() + "/review/user");
            return;
        }

        String statusFilter = request.getParameter("status");
        String ratingFilter = request.getParameter("rating");
        String sortBy = request.getParameter("sort");

        List<Review> reviews;
        if (statusFilter != null && !statusFilter.isEmpty()) {
            try {
                Review.ReviewStatus status = Review.ReviewStatus.valueOf(statusFilter);
                reviews = reviewDAO.getReviewsByProductId(null, status, null, null);
            } catch (IllegalArgumentException e) {
                reviews = getAllReviews();
            }
        } else {
            reviews = getAllReviews();
        }

        for (Review review : reviews) {
            if (review.getProductName() == null || review.getProductName().isEmpty()) {
                Optional<Product> productOptional = productDAO.getProductById(review.getProductId());
                if (productOptional.isPresent()) {
                    review.setProductName(productOptional.get().getName());
                }
            }
            if (review.getUserName() == null || review.getUserName().isEmpty()) {
                Optional<User> userOptional = userDAO.getUserById(review.getUserId());
                if (userOptional.isPresent()) {
                    review.setUserName(userOptional.get().getUsername());
                }
            }
        }

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

    private List<Review> getAllReviews() {
        return reviewDAO.getAllReviews();
    }

    private boolean hasUserPurchasedProduct(String userId, String productId) {
        List<Order> userOrders = orderDAO.getOrdersByUserId(userId);
        return userOrders.stream()
                .flatMap(order -> order.getItems().stream())
                .anyMatch(item -> item.getProductId().equals(productId));
    }

    private boolean isAdminUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return false;
        }
        User user = (User) session.getAttribute("user");
        return user.getRole() == User.UserRole.ADMIN;
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
        out.flush();
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        e.printStackTrace();
        request.setAttribute("error", "An error occurred: " + e.getMessage());
        request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
    }

    private void updateReviewStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (!isAdminUser(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendJsonResponse(response, false, "Admin access required");
            return;
        }

        String reviewId = request.getParameter("reviewId");
        String statusStr = request.getParameter("status");

        if (reviewId == null || statusStr == null || reviewId.trim().isEmpty() || statusStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendJsonResponse(response, false, "Missing or empty required parameters");
            return;
        }

        try {
            Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
            if (!reviewOptional.isPresent()) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendJsonResponse(response, false, "Review not found");
                return;
            }

            Review review = reviewOptional.get();
            Review.ReviewStatus newStatus = Review.ReviewStatus.valueOf(statusStr.toUpperCase());
            review.setStatus(newStatus);

            boolean updated = reviewDAO.updateReview(review);
            if (updated) {
                sendJsonResponse(response, true, "Review status updated successfully");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                sendJsonResponse(response, false, "Failed to update review status");
            }
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendJsonResponse(response, false, "Invalid status value");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendJsonResponse(response, false, "An error occurred: " + e.getMessage());
        }
    }

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