package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ReviewDAO;
import com.grocerymanagement.model.Review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/reviews")
public class AdminReviewsServlet extends HttpServlet {
    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        reviewDAO = new ReviewDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get all reviews
        List<Review> reviews = reviewDAO.getAllReviews();

        // Create custom stats object for the view
        Map<String, Object> stats = new HashMap<>();

        // Calculate review statistics
        int totalReviews = reviews.size();
        stats.put("totalReviews", totalReviews);

        double averageRating = reviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);
        stats.put("averageRating", averageRating);

        // Count approved and pending reviews
        long approvedCount = reviews.stream()
                .filter(r -> r.getStatus() == Review.ReviewStatus.APPROVED)
                .count();
        long pendingCount = reviews.stream()
                .filter(r -> r.getStatus() == Review.ReviewStatus.PENDING)
                .count();

        stats.put("approvedReviews", (int) approvedCount);
        stats.put("pendingReviews", (int) pendingCount);

        // Calculate percentages
        int approvedPercentage = totalReviews > 0 ? (int) ((double) approvedCount / totalReviews * 100) : 0;
        int pendingPercentage = totalReviews > 0 ? (int) ((double) pendingCount / totalReviews * 100) : 0;

        stats.put("approvedPercentage", approvedPercentage);
        stats.put("pendingPercentage", pendingPercentage);

        request.setAttribute("stats", stats);
        request.setAttribute("reviews", reviews);
        request.setAttribute("totalReviews", totalReviews);

        request.getRequestDispatcher("/views/admin/reviews.jsp").forward(request, response);
    }
}