package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.PaymentDAO;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Payment;
import com.grocerymanagement.model.User;
import com.grocerymanagement.dto.PaymentDetails;
import com.grocerymanagement.model.Cart;
import java.util.Optional;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import com.grocerymanagement.dao.CartDAO;

@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {
    private PaymentDAO paymentDAO;
    private OrderDAO orderDAO;
    private CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        orderDAO = new OrderDAO(fileInitUtil);
        paymentDAO = new PaymentDAO(fileInitUtil, orderDAO);
        cartDAO = new CartDAO(fileInitUtil); // Add this line
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if(pathInfo == null) {
            pathInfo = "/checkout";
        }

        switch(pathInfo) {
            case "/checkout":
                showCheckoutPage(request, response);
                break;
            case "/success":
                showPaymentSuccess(request, response);
                break;
            case "/saved-cards":
                showSavedCards(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/cart/view");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if(pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch(pathInfo) {
            case "/process":
                processPayment(request, response);
                break;
            case "/save-card":
                savePaymentCard(request, response);
                break;
            case "/delete-card":
                deletePaymentCard(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    private void showCheckoutPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        Order pendingOrder = (Order) session.getAttribute("pendingOrder");
        if (pendingOrder == null) {
            response.sendRedirect(request.getContextPath() + "/cart/view");
            return;
        }

        // Calculate tax and shipping for display
        BigDecimal subtotal = pendingOrder.getTotalAmount();
        BigDecimal taxRate = new BigDecimal("0.10"); // 10% tax
        BigDecimal tax = subtotal.multiply(taxRate);
        BigDecimal shipping = new BigDecimal("5.00"); // Flat $5 shipping
        BigDecimal orderTotal = subtotal.add(tax).add(shipping);

        request.setAttribute("pendingOrder", pendingOrder);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("taxAmount", tax);
        request.setAttribute("shippingCost", shipping);
        request.setAttribute("orderTotal", orderTotal);

        // Get user's saved payment methods
        User currentUser = (User) session.getAttribute("user");
        List<PaymentDetails> savedCards = paymentDAO.getSavedCards(currentUser.getUserId());
        request.setAttribute("savedCards", savedCards);

        request.getRequestDispatcher("/views/payment/payment-checkout.jsp").forward(request, response);
    }

    private void showPaymentSuccess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order/user-orders");
            return;
        }

        Optional<Order> orderOpt = orderDAO.getOrderById(orderId);
        if (!orderOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/order/user-orders");
            return;
        }

        request.setAttribute("order", orderOpt.get());
        request.getRequestDispatcher("/views/order/order-confirmation.jsp").forward(request, response);
    }

    private void showSavedCards(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<PaymentDetails> savedCards = paymentDAO.getSavedCards(currentUser.getUserId());

        request.setAttribute("savedCards", savedCards);
        request.getRequestDispatcher("/views/payment/saved-cards.jsp").forward(request, response);
    }

    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        Order pendingOrder = (Order) session.getAttribute("pendingOrder");

        if (pendingOrder == null) {
            response.sendRedirect(request.getContextPath() + "/cart/view");
            return;
        }

        // Gather payment details
        String paymentMethod = request.getParameter("paymentMethod");
        String cardNumber = request.getParameter("cardNumber");
        String cardHolderName = request.getParameter("cardHolderName");
        String expiryDate = request.getParameter("expiryDate");
        String cvv = request.getParameter("cvv");
        String saveCard = request.getParameter("saveCard");

        // Create payment details object
        PaymentDetails paymentDetails = new PaymentDetails(
                cardNumber,
                cardHolderName,
                expiryDate,
                cvv,
                Payment.PaymentMethod.valueOf(paymentMethod)
        );

        // Save card if requested
        boolean shouldSaveCard = "on".equals(saveCard);
        if (shouldSaveCard) {
            paymentDAO.saveCard(currentUser.getUserId(), paymentDetails);
        }

        // Process order - create in database
        pendingOrder.setUserId(currentUser.getUserId());
        boolean orderCreated = orderDAO.createOrder(pendingOrder);

        if (!orderCreated) {
            request.setAttribute("error", "Failed to create order. Please try again.");
            showCheckoutPage(request, response);
            return;
        }

        // Create payment record
        Payment payment = new Payment(pendingOrder, pendingOrder.getTotalAmount(),
                Payment.PaymentMethod.valueOf(paymentMethod));
        payment.setStatus(Payment.PaymentStatus.SUCCESSFUL);

        boolean paymentProcessed = paymentDAO.createPayment(payment);

        if (!paymentProcessed) {
            pendingOrder.setStatus(Order.OrderStatus.CANCELLED);
            orderDAO.updateOrder(pendingOrder);
            request.setAttribute("error", "Payment processing failed. Please try again.");
            showCheckoutPage(request, response);
            return;
        }

        // Update order status to processing
        pendingOrder.setStatus(Order.OrderStatus.PROCESSING);
        orderDAO.updateOrder(pendingOrder);

        // Clear cart after successful order - this is an alternative approach
        // that doesn't require accessing the items directly
        boolean cartCleared = cartDAO.deleteCart(currentUser.getUserId());

        if (cartCleared) {
            // Update cart count in session
            session.setAttribute("cartItemCount", 0);
        }

        // Clear pending order from session
        session.removeAttribute("pendingOrder");

        // Redirect to success page
        response.sendRedirect(request.getContextPath() +
                "/payment/success?orderId=" + pendingOrder.getOrderId());
    }

    private void savePaymentCard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Gather card details
        String cardNumber = request.getParameter("cardNumber");
        String cardHolderName = request.getParameter("cardHolderName");
        String expiryDate = request.getParameter("expiryDate");
        String cvv = request.getParameter("cvv");
        String paymentMethod = request.getParameter("paymentMethod");

        // Create payment details
        PaymentDetails paymentDetails = new PaymentDetails(
                cardNumber,
                cardHolderName,
                expiryDate,
                cvv,
                Payment.PaymentMethod.valueOf(paymentMethod)
        );

        // Save card
        boolean saved = paymentDAO.saveCard(currentUser.getUserId(), paymentDetails);

        if (saved) {
            request.setAttribute("success", "Payment method saved successfully");
        } else {
            request.setAttribute("error", "Failed to save payment method");
        }

        // Redirect back to saved cards page
        showSavedCards(request, response);
    }

    private void deletePaymentCard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String cardId = request.getParameter("cardId");

        if (cardId == null || cardId.trim().isEmpty()) {
            request.setAttribute("error", "Invalid card ID");
            showSavedCards(request, response);
            return;
        }

        boolean deleted = paymentDAO.deleteCard(currentUser.getUserId(), cardId);

        if (deleted) {
            request.setAttribute("success", "Payment method deleted successfully");
        } else {
            request.setAttribute("error", "Failed to delete payment method");
        }

        // Redirect back to saved cards page
        showSavedCards(request, response);
    }
}