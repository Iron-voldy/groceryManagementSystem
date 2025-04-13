package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.TransactionDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.Transaction;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.User;

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

@WebServlet("/transaction/*")
public class TransactionServlet extends HttpServlet {
    private TransactionDAO transactionDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        transactionDAO = new TransactionDAO(fileInitUtil);
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
            case "/process":
                processTransaction(request, response);
                break;
            case "/refund":
                processRefund(request, response);
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
            case "/list":
                listTransactions(request, response);
                break;
            case "/details":
                getTransactionDetails(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void processTransaction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String orderId = request.getParameter("orderId");
        String paymentMethodStr = request.getParameter("paymentMethod");

        // Validate order
        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (!orderOptional.isPresent()) {
            request.setAttribute("error", "Order not found");
            request.getRequestDispatcher("/views/transaction/payment.jsp").forward(request, response);
            return;
        }

        Order order = orderOptional.get();

        // Ensure only the order owner can process payment
        if (!order.getUserId().equals(currentUser.getUserId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Create transaction
        Transaction transaction = new Transaction(
                orderId,
                order.getTotalAmount(),
                Transaction.PaymentMethod.valueOf(paymentMethodStr)
        );

        // Simulate payment processing (in a real system, this would interact with a payment gateway)
        transaction.setStatus(Transaction.TransactionStatus.SUCCESSFUL);

        if (transactionDAO.createTransaction(transaction)) {
            // Update order status
            order.setStatus(Order.OrderStatus.PROCESSING);
            orderDAO.updateOrder(order);

            request.setAttribute("transaction", transaction);
            request.setAttribute("success", "Payment processed successfully");
            request.getRequestDispatcher("/views/transaction/confirmation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Transaction failed");
            request.getRequestDispatcher("/views/transaction/payment.jsp").forward(request, response);
        }
    }

    private void processRefund(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String transactionId = request.getParameter("transactionId");
        String reasonForRefund = request.getParameter("reason");

        // Get transaction
        Optional<Transaction> transactionOptional = transactionDAO.getTransactionById(transactionId);

        if (!transactionOptional.isPresent()) {
            request.setAttribute("error", "Transaction not found");
            request.getRequestDispatcher("/views/transaction/refund.jsp").forward(request, response);
            return;
        }

        Transaction transaction = transactionOptional.get();

        // Only successful transactions can be refunded
        if (transaction.getStatus() != Transaction.TransactionStatus.SUCCESSFUL) {
            request.setAttribute("error", "Transaction cannot be refunded");
            request.getRequestDispatcher("/views/transaction/refund.jsp").forward(request, response);
            return;
        }

        // Update transaction status
        transaction.setStatus(Transaction.TransactionStatus.REFUNDED);

        // Get associated order
        Optional<Order> orderOptional = orderDAO.getOrderById(transaction.getOrderId());
        if (orderOptional.isPresent()) {
            Order order = orderOptional.get();
            order.setStatus(Order.OrderStatus.CANCELLED);
            orderDAO.updateOrder(order);
        }

        if (transactionDAO.updateTransaction(transaction)) {
            request.setAttribute("success", "Refund processed successfully");
            request.setAttribute("reason", reasonForRefund);
            request.getRequestDispatcher("/views/transaction/refund-confirmation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Refund processing failed");
            request.getRequestDispatcher("/views/transaction/refund.jsp").forward(request, response);
        }
    }

    private void listTransactions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<Transaction> transactions = transactionDAO.getAllTransactions();
        request.setAttribute("transactions", transactions);
        request.getRequestDispatcher("/views/transaction/transaction-list.jsp").forward(request, response);
    }

    private void getTransactionDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String transactionId = request.getParameter("transactionId");

        Optional<Transaction> transactionOptional = transactionDAO.getTransactionById(transactionId);
        if (!transactionOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Transaction not found");
            return;
        }

        Transaction transaction = transactionOptional.get();
        Optional<Order> orderOptional = orderDAO.getOrderById(transaction.getOrderId());

        // Ensure only the order owner or an admin can view transaction details
        if (orderOptional.isPresent()) {
            Order order = orderOptional.get();
            if (!order.getUserId().equals(currentUser.getUserId()) &&
                    currentUser.getRole() != User.UserRole.ADMIN) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
        }

        request.setAttribute("transaction", transaction);
        request.setAttribute("order", orderOptional.orElse(null));
        request.getRequestDispatcher("/views/transaction/transaction-details.jsp").forward(request, response);
    }

    private boolean isAdminUser(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }
}