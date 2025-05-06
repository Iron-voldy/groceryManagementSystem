package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.CartDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.model.Cart;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OrderServlet.class.getName());

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;
    private CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        orderDAO = new OrderDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
        userDAO = new UserDAO(fileInitUtil);
        cartDAO = new CartDAO(fileInitUtil);
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
                case "/edit":
                    showEditOrder(request, response);
                    break;
                case "/track":
                    trackOrder(request, response);
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
                case "/create":
                    createOrder(request, response);
                    break;
                case "/update":
                    updateOrder(request, response);
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
        // Ensure only admin can list orders
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        // Pagination and filtering parameters
        int page = 1;
        int pageSize = 10;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        // Status filter
        Order.OrderStatus statusFilter = null;
        String statusParam = request.getParameter("status");
        if (statusParam != null && !statusParam.isEmpty()) {
            try {
                statusFilter = Order.OrderStatus.valueOf(statusParam.toUpperCase());
            } catch (IllegalArgumentException e) {
                // Log and ignore invalid status
                System.err.println("Invalid status filter: " + statusParam);
            }
        }

        // Search term
        String searchTerm = request.getParameter("searchTerm");

        // Get filtered and paginated orders
        List<Order> orders = new ArrayList<>();
        int totalOrders = 0;
        int totalPages = 0;

        try {
            // Get filtered and paginated orders
            orders = orderDAO.getOrdersWithFilter(
                    page, pageSize, statusFilter, searchTerm
            );

            // Get total order count for pagination
            totalOrders = orderDAO.getTotalOrderCount(statusFilter, searchTerm);
            totalPages = (int) Math.ceil((double) totalOrders / pageSize);

            // Ensure page is within valid range
            page = Math.max(1, Math.min(page, totalPages));
        } catch (Exception e) {
            // Log the error
            System.err.println("Error retrieving orders: " + e.getMessage());
            e.printStackTrace();
        }

        // Set attributes for view
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);

        // Set filter parameters for view
        request.setAttribute("currentStatus", statusParam);
        request.setAttribute("currentSearch", searchTerm);

        // Forward to orders list view
        request.getRequestDispatcher("/views/admin/orders.jsp").forward(request, response);
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
        request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
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

    private void showEditOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String orderId = request.getParameter("orderId");
        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        // Get all products for reference
        List<Product> products = productDAO.getAllProducts();

        request.setAttribute("order", order);
        request.setAttribute("products", products);
        request.getRequestDispatcher("/views/admin/edit-order.jsp").forward(request, response);
    }

    private void trackOrder(HttpServletRequest request, HttpServletResponse response)
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

        // Ensure only order owner or admin can track
        if (!order.getUserId().equals(user.getUserId()) &&
                user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/views/order/track-order.jsp").forward(request, response);
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get the user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(user.getUserId());
        if (!cartOptional.isPresent() || cartOptional.get().getItems().isEmpty()) {
            request.setAttribute("error", "Your cart is empty");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        Cart cart = cartOptional.get();

        // Create new order from cart
        Order order = new Order(user.getUserId());

        // Convert cart items to order items
        for (Cart.CartItem cartItem : cart.getItems()) {
            Optional<Product> productOptional = productDAO.getProductById(cartItem.getProductId());
            if (!productOptional.isPresent()) {
                continue;
            }

            Product product = productOptional.get();
            Order.OrderItem orderItem = order.createOrderItem(
                    product.getProductId(),
                    product.getName(),
                    cartItem.getQuantity(),
                    product.getPrice()
            );

            order.addItem(orderItem);
        }

        // Store the order in session for the payment process
        HttpSession session = request.getSession();
        session.setAttribute("pendingOrder", order);

        // Redirect to payment checkout
        response.sendRedirect(request.getContextPath() + "/payment/checkout");
    }

    private void updateOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String orderId = request.getParameter("orderId");
        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);

        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        // Clear existing items
        order.setItems(new ArrayList<>());

        // Get updated items from request
        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");

        if (productIds != null && quantities != null &&
                productIds.length > 0 && productIds.length == quantities.length) {

            for (int i = 0; i < productIds.length; i++) {
                try {
                    Optional<Product> productOptional = productDAO.getProductById(productIds[i]);
                    if (!productOptional.isPresent()) continue;

                    Product product = productOptional.get();
                    int quantity = Integer.parseInt(quantities[i]);

                    if (quantity <= 0) continue; // Skip items with 0 or negative quantity

                    Order.OrderItem orderItem = order.createOrderItem(
                            product.getProductId(),
                            product.getName(),
                            quantity,
                            product.getPrice()
                    );

                    order.addItem(orderItem);
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid quantity for product: " + productIds[i], e);
                }
            }
        }
// Update order status if specified
        String status = request.getParameter("status");
        if (status != null && !status.isEmpty()) {
            try {
                Order.OrderStatus newStatus = Order.OrderStatus.valueOf(status);
                order.setStatus(newStatus);
            } catch (IllegalArgumentException e) {
                LOGGER.warning("Invalid order status: " + status);
            }
        }

        // Update order in database
        if (orderDAO.updateOrder(order)) {
            request.setAttribute("success", "Order updated successfully");
            response.sendRedirect(request.getContextPath() + "/order/details?orderId=" + orderId);
        } else {
            request.setAttribute("error", "Failed to update order");
            showEditOrder(request, response);
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

        if (!orderOptional.isPresent()) {
            request.setAttribute("error", "Order not found");
            request.getRequestDispatcher("/views/order/user-orders.jsp").forward(request, response);
            return;
        }

        Order order = orderOptional.get();

        // Ensure only order owner or admin can cancel
        if (!order.getUserId().equals(user.getUserId()) &&
                user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Only allow cancellation of pending orders
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            request.setAttribute("error", "Cannot cancel order. Current status: " + order.getStatus());
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
            return;
        }

        // Update order status to cancelled
        order.setStatus(Order.OrderStatus.CANCELLED);

        if (orderDAO.updateOrder(order)) {
            request.setAttribute("success", "Order cancelled successfully");

            // Redirect based on user role
            if (user.getRole() == User.UserRole.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/order/list");
            } else {
                response.sendRedirect(request.getContextPath() + "/order/user-orders");
            }
        } else {
            request.setAttribute("error", "Failed to cancel order");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String orderId = request.getParameter("orderId");
        String statusParam = request.getParameter("status");

        if (orderId == null || statusParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters");
            return;
        }

        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        try {
            Order.OrderStatus newStatus = Order.OrderStatus.valueOf(statusParam);
            order.setStatus(newStatus);
            order.setLastUpdated(LocalDateTime.now());

            if (orderDAO.updateOrder(order)) {
                request.setAttribute("success", "Order status updated to " + newStatus);
            } else {
                request.setAttribute("error", "Failed to update order status");
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid order status: " + statusParam);
        }

        response.sendRedirect(request.getContextPath() + "/order/details?orderId=" + orderId);
    }

    // Helper method to get current user from session
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    // Error handling method
    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        LOGGER.log(Level.SEVERE, "Error processing order request", e);

        request.setAttribute("error", "An error occurred: " + e.getMessage());

        // Log full stack trace
        e.printStackTrace();

        // Determine appropriate error page based on user role
        User user = getCurrentUser(request);
        String errorPage = user != null && user.getRole() == User.UserRole.ADMIN
                ? "/views/admin/error.jsp"
                : "/views/error/500.jsp";

        request.getRequestDispatcher(errorPage).forward(request, response);
    }
}