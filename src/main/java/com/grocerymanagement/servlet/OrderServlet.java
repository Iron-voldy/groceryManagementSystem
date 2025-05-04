package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dto.PaymentDetails;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Payment;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;
import com.grocerymanagement.service.OrderProcessingService;
import com.grocerymanagement.service.PaymentService;
import com.grocerymanagement.util.OrderValidationUtil;

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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OrderServlet.class.getName());

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private OrderProcessingService orderProcessingService;
    private PaymentService paymentService;

    @Override
    public void init() throws ServletException {
        try {
            FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
            orderDAO = new OrderDAO(fileInitUtil);
            productDAO = new ProductDAO(fileInitUtil);
            orderProcessingService = new OrderProcessingService(orderDAO, productDAO);
            paymentService = new PaymentService(fileInitUtil, orderDAO);
            orderProcessingService.processOrders();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing OrderServlet", e);
            throw new ServletException("Could not initialize OrderServlet", e);
        }
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
                case "/list":
                    listOrders(request, response);
                    break;
                case "/details":
                    showOrderDetails(request, response);
                    break;
                case "/user-orders":
                    listUserOrders(request, response);
                    break;
                case "/checkout":
                    showCheckoutPage(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
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
                case "/place":
                    placeOrder(request, response);
                    break;
                case "/payment":
                    processPayment(request, response);
                    break;
                case "/cancel":
                    cancelOrder(request, response);
                    break;
                case "/update-status":
                    updateOrderStatus(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Ensure only admin can list all orders
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<Order> orders = orderDAO.getAllOrders();

        // Optional filtering and sorting
        String status = request.getParameter("status");
        String sortBy = request.getParameter("sort");

        if (status != null && !status.isEmpty()) {
            orders = orders.stream()
                    .filter(order -> order.getStatus().name().equalsIgnoreCase(status))
                    .collect(Collectors.toList());
        }

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/views/admin/order-management.jsp").forward(request, response);
    }

    private void showOrderDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderId = request.getParameter("orderId");
        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        // Ensure only order owner or admin can view details
        if (!order.getUserId().equals(user.getUserId()) &&
                user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        request.setAttribute("order", order);

        // Determine view based on user role
        String viewPath = user.getRole() == User.UserRole.ADMIN
                ? "/views/admin/order-details.jsp"
                : "/views/order/order-details.jsp";

        request.getRequestDispatcher(viewPath).forward(request, response);
    }

    private void listUserOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Order> userOrders = orderDAO.getOrdersByUserId(user.getUserId());
        request.setAttribute("orders", userOrders);
        request.getRequestDispatcher("/views/order/user-orders.jsp").forward(request, response);
    }

    private void showCheckoutPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Retrieve cart or create order
        Order order = createOrderFromCart(user);

        if (order == null || order.getItems().isEmpty()) {
            request.setAttribute("error", "Your cart is empty");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        // Store order in session for payment processing
        request.getSession().setAttribute("pendingOrder", order);
        request.getRequestDispatcher("/views/payment/payment-checkout.jsp").forward(request, response);
    }

    private void placeOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Create order from request parameters
        Order order = createOrderFromRequest(request, user);

        if (!OrderValidationUtil.validateOrder(order)) {
            request.setAttribute("error", "Invalid order details");
            request.getRequestDispatcher("/views/order/create-order.jsp").forward(request, response);
            return;
        }

        // Save order
        if (orderDAO.createOrder(order)) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/payment/payment-checkout.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to create order");
            request.getRequestDispatcher("/views/order/create-order.jsp").forward(request, response);
        }
    }

    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Retrieve order from session
        Order order = (Order) request.getSession().getAttribute("pendingOrder");
        if (order == null) {
            request.setAttribute("error", "No order found to process");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        // Create payment details from request
        PaymentDetails paymentDetails = createPaymentDetails(request);

        try {
            // Process payment
            Payment payment = paymentService.processPayment(order, paymentDetails);

            // Save order
            orderDAO.createOrder(order);

            // Store payment and order in request
            request.setAttribute("order", order);
            request.setAttribute("payment", payment);

            // Forward to payment confirmation
            request.getRequestDispatcher("/views/payment/payment-confirmation.jsp").forward(request, response);

        } catch (Exception e) {
            // Handle payment errors
            request.setAttribute("error", "Payment processing failed: " + e.getMessage());
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/payment/payment-error.jsp").forward(request, response);
        }
    }

    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderId = request.getParameter("orderId");
        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (orderOptional.isPresent()) {
            Order order = orderOptional.get();

            // Ensure only order owner or admin can cancel
            if (order.getUserId().equals(user.getUserId()) ||
                    user.getRole() == User.UserRole.ADMIN) {

                order.setStatus(Order.OrderStatus.CANCELLED);

                if (orderDAO.updateOrder(order)) {
                    request.setAttribute("success", "Order cancelled successfully");
                } else {
                    request.setAttribute("error", "Failed to cancel order");
                }
            } else {
                request.setAttribute("error", "You are not authorized to cancel this order");
            }
        } else {
            request.setAttribute("error", "Order not found");
        }

        // Redirect based on user role
        if (user.getRole() == User.UserRole.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/order/list");
        } else {
            response.sendRedirect(request.getContextPath() + "/order/user-orders");
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String orderId = request.getParameter("orderId");
        String statusStr = request.getParameter("status");

        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (orderOptional.isPresent()) {
            Order order = orderOptional.get();

            try {
                Order.OrderStatus newStatus = Order.OrderStatus.valueOf(statusStr);
                order.setStatus(newStatus);

                if (orderDAO.updateOrder(order)) {
                    request.setAttribute("success", "Order status updated successfully");
                } else {
                    request.setAttribute("error", "Failed to update order status");
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "Invalid order status");
            }
        } else {
            request.setAttribute("error", "Order not found");
        }

        response.sendRedirect(request.getContextPath() + "/order/list");
    }

    // Helper Methods
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    private Order createOrderFromCart(User user) {
        // Retrieve cart items and convert to order
        // This method would interact with your CartDAO to fetch cart items
        // Implement based on your cart management logic
        return null; // Placeholder
    }

    private Order createOrderFromRequest(HttpServletRequest request, User user) {
        Order order = new Order(user.getUserId());

        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");

        if (productIds != null && quantities != null) {
            for (int i = 0; i < productIds.length; i++) {
                Optional<Product> productOptional = productDAO.getProductById(productIds[i]);

                if (productOptional.isPresent()) {
                    Product product = productOptional.get();
                    int quantity = Integer.parseInt(quantities[i]);

                    Order.OrderItem orderItem = new Order.OrderItem(
                            product.getProductId(),
                            product.getName(),
                            quantity,
                            product.getPrice()
                    );
                    order.addItem(orderItem);
                }
            }
        }

        return order;
    }

    private PaymentDetails createPaymentDetails(HttpServletRequest request) {
        return new PaymentDetails(
                request.getParameter("cardNumber"),
                request.getParameter("cardHolderName"),
                request.getParameter("expiryDate"),
                request.getParameter("cvv"),
                Payment.PaymentMethod.valueOf(request.getParameter("paymentMethod"))
        );
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        LOGGER.log(Level.SEVERE, "Error processing order request", e);
        request.setAttribute("error", "An error occurred: " + e.getMessage());
        request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
    }

    @Override
    public void destroy() {
        if (orderProcessingService != null) {
            orderProcessingService.shutdown();
        }
    }
}