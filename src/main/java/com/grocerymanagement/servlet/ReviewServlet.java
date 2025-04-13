package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ReviewDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.Review;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@WebServlet("/review/*")
public class ReviewServlet extends HttpServlet {
    private ReviewDAO reviewDAO;
    private ProductDAO productDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        reviewDAO = new ReviewDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
        orderDAO = new OrderDAO(fileInitUtil);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        switch (pathInfo) {
            case "/submit":
                submitReview(request, response);
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
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        switch (pathInfo) {
            case "/product":
                getProductReviews(request, response);
                break;
            case "/user":
                getUserReviews(request, response);
                break;
            case "/details":
                getReviewDetails(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void submitReview(HttpServletRequest request, HttpServletResponse response)
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

        // Validate inputs
        if (productId == null || ratingStr == null || reviewText == null) {
            request.setAttribute("error", "Invalid review details");
            request.getRequestDispatcher("/views/review/submit-review.jsp").forward(request, response);
            return;
        }

        // Verify product exists
        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (!productOptional.isPresent()) {
            request.setAttribute("error", "Product not found");
            request.getRequestDispatcher("/views/review/submit-review.jsp").forward(request, response);
            return;
        }


        // Verify user has purchased the product (optional strict validation)
        List<Order> userOrders = orderDAO.getOrdersByUserId(currentUser.getUserId());
        boolean hasPurchased = userOrders.stream()
                .anyMatch(order -> order.getItems().stream()
                        .anyMatch(item -> item.getProductId().equals(productId)));

        // Create review
        Review newReview = new Review(
                currentUser.getUserId(),
                productId,
                Integer.parseInt(ratingStr),
                reviewText
        );

        // Set initial status based on user's purchase history
        newReview.setStatus(hasPurchased ?
                Review.ReviewStatus.APPROVED :
                Review.ReviewStatus.PENDING);

        if (reviewDAO.createReview(newReview)) {
            request.setAttribute("success", "Review submitted successfully");
            request.getRequestDispatcher("/views/review/review-confirmation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to submit review");
            request.getRequestDispatcher("/views/review/submit-review.jsp").forward(request, response);
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

        // Get existing review
        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);

        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/review/update-review.jsp").forward(request, response);
            return;
        }

        Review existingReview = reviewOptional.get();

        // Ensure only the review owner can update
        if (!existingReview.getUserId().equals(currentUser.getUserId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Update review details
        if (ratingStr != null) {
            existingReview.setRating(Integer.parseInt(ratingStr));
        }
        if (reviewText != null) {
            existingReview.setReviewText(reviewText);
        }

        // Reset status to pending for moderation
        existingReview.setStatus(Review.ReviewStatus.PENDING);

        if (reviewDAO.updateReview(existingReview)) {
            request.setAttribute("success", "Review updated successfully");
            request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update review");
            request.getRequestDispatcher("/views/review/update-review.jsp").forward(request, response);
        }
    }

    private void moderateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String reviewId = request.getParameter("reviewId");
        String statusStr = request.getParameter("status");

        // Get review
        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);

        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/review/update-review.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        review.setStatus(Review.ReviewStatus.valueOf(statusStr));

        if (reviewDAO.updateReview(review)) {
            request.setAttribute("success", "Review moderated successfully");
            request.getRequestDispatcher("/views/review/moderation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to moderate review");
            request.getRequestDispatcher("/views/review/moderation.jsp").forward(request, response);
        }
    }

    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String reviewId = request.getParameter("reviewId");

        // Get review
        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/review/update-review.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();

        // Ensure only the review owner or an admin can delete
        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        if (reviewDAO.deleteReview(reviewId)) {
            request.setAttribute("success", "Review deleted successfully");
            request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to delete review");
            request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
        }
    }

    private void getProductReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productId = request.getParameter("productId");

        // Verify product exists
        Optional<Product> productOptional = productDAO.getProductById(productId);

        if (!productOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        // Get approved reviews for the product
        List<Review> reviews = reviewDAO.getReviewsByProductId(productId).stream()
                .filter(review -> review.getStatus() == Review.ReviewStatus.APPROVED)
                .collect(Collectors.toList());

        // Calculate average rating
        double averageRating = reviewDAO.calculateAverageRatingForProduct(productId);

        request.setAttribute("product", productOptional.get());
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.getRequestDispatcher("/views/review/product-reviews.jsp").forward(request, response);
    }

    private void getUserReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<Review> userReviews = reviewDAO.getReviewsByUserId(currentUser.getUserId());

        request.setAttribute("reviews", userReviews);
        request.getRequestDispatcher("/views/review/user-reviews.jsp").forward(request, response);
    }

    private void getReviewDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String reviewId = request.getParameter("reviewId");

        // Get review
        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);

        if (!reviewOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Review not found");
            return;
        }

        Review review = reviewOptional.get();

        // Ensure only the review owner or an admin can view details
        if (!review.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Get associated product
        Optional<Product> productOptional = productDAO.getProductById(review.getProductId());

        request.setAttribute("review", review);
        request.setAttribute("product", productOptional.orElse(null));
        request.getRequestDispatcher("/views/review/review-details.jsp").forward(request, response);
    }

    private boolean isAdminUser(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }
}