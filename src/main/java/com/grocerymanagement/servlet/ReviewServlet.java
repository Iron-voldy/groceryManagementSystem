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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            pathInfo = "/list";
        }

        try {
            switch (pathInfo) {
                case "/create":
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
                case "/list":
                default:
                    listUserReviews(request, response);
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
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    // Other methods remain the same as in the previous implementation

    // Add this method to check admin status
    private boolean isAdminUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return false;
        }
        User user = (User) session.getAttribute("user");
        return user.getRole() == User.UserRole.ADMIN;
    }

    // Modify methods to use isAdminUser
    private void moderateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String reviewId = request.getParameter("reviewId");
        String statusStr = request.getParameter("status");

        Optional<Review> reviewOptional = reviewDAO.getReviewById(reviewId);
        if (!reviewOptional.isPresent()) {
            request.setAttribute("error", "Review not found");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            return;
        }

        Review review = reviewOptional.get();
        review.setStatus(Review.ReviewStatus.valueOf(statusStr));

        if (reviewDAO.updateReview(review)) {
            request.setAttribute("success", "Review moderated successfully");
            request.getRequestDispatcher("/views/review/moderation-success.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to moderate review");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // Rest of the methods remain the same
}