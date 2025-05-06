package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;
import com.grocerymanagement.model.Order.OrderItem;

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
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
        "/order/list",
        "/order",
        "/orders",
        "/order/details",
        "/order/create",
        "/order/update",
        "/order/cancel"
})
public class OrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OrderServlet.class.getName());

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        try {
            FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
            orderDAO = new OrderDAO(fileInitUtil);
            productDAO = new ProductDAO(fileInitUtil);
            userDAO = new UserDAO(fileInitUtil);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing OrderServlet", e);
            throw new ServletException("Could not initialize OrderServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        try {
            // Determine the action based on path
            if (servletPath.equals("/order/list") ||
                    servletPath.equals("/order") ||
                    servletPath.equals("/orders")) {
                // List orders (default admin view)
                listOrders(request, response);
            } else if (servletPath.equals("/order/details")) {
                // Show specific order details
                showOrderDetails(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        try {
            if (servletPath.equals("/order/create")) {
                createOrder(request, response);
            } else if (servletPath.equals("/order/update")) {
                updateOrder(request, response);
            } else if (servletPath.equals("/order/cancel")) {
                cancelOrder(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    /**
     * List orders with pagination and filtering
     */
    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Ensure only admin can list orders
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        // Pagination parameters
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
                LOGGER.warning("Invalid status filter: " + statusParam);
            }
        }

        // Search term
        String searchTerm = request.getParameter("search");

        // Get all orders (with filtering)
        List<Order> allOrders = orderDAO.getAllOrders();

        // Apply filters
        List<Order> filteredOrders = allOrders.stream()
                .filter(order -> {
                    // Status filter
                    if (statusFilter != null && order.getStatus() != statusFilter) {
                        return false;
                    }

                    // Search term filter
                    if (searchTerm != null && !searchTerm.isEmpty()) {
                        String searchLower = searchTerm.toLowerCase();
                        return order.getOrderId().toLowerCase().contains(searchLower) ||
                                order.getUserId().toLowerCase().contains(searchLower);
                    }

                    return true;
                })
                .collect(Collectors.toList());

        // Pagination
        int totalOrders = filteredOrders.size();
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        // Adjust page number if out of bounds
        page = Math.max(1, Math.min(page, totalPages));

        // Get paginated orders
        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalOrders);
        List<Order> paginatedOrders = filteredOrders.subList(startIndex, endIndex);

        // Set attributes for view
        request.setAttribute("orders", paginatedOrders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("currentStatus", statusParam);
        request.setAttribute("currentSearch", searchTerm);

        // Forward to orders list view
        request.getRequestDispatcher("/views/admin/orders.jsp").forward(request, response);
    }

    /**
     * Show details of a specific order
     */
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

    /**
     * Create a new order
     */
    private void createOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Create new order
        Order order = new Order(user.getUserId());

        // Get product details from request
        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");

        if (productIds == null || quantities == null ||
                productIds.length == 0 || productIds.length != quantities.length) {
            request.setAttribute("error", "Invalid order details");
            request.getRequestDispatcher("/views/order/create-order.jsp").forward(request, response);
            return;
        }

        // Add items to order
        for (int i = 0; i < productIds.length; i++) {
            try {
                Optional<Product> productOptional = productDAO.getProductById(productIds[i]);

                if (!productOptional.isPresent()) {
                    LOGGER.warning("Product not found: " + productIds[i]);
                    continue;
                }

                Product product = productOptional.get();
                int quantity = Integer.parseInt(quantities[i]);

                // Create order item
                OrderItem orderItem = new OrderItem(
                        product.getProductId(),
                        product.getName(),
                        quantity,
                        product.getPrice()
                );

                // Add item to order
                order.addItem(orderItem);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid quantity for product: " + productIds[i], e);
            }
        }

        // Save order
        if (orderDAO.createOrder(order)) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/order/order-confirmation.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to create order");
            request.getRequestDispatcher("/views/order/create-order.jsp").forward(request, response);
        }
    }

    /**
     * Update an existing order
     */
    private void updateOrder(HttpServletRequest request, HttpServletResponse response)
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
            request.getRequestDispatcher("/views/order/update-order.jsp").forward(request, response);
            return;
        }

        Order order = orderOptional.get();

        // Ensure only order owner or admin can update
        if (!order.getUserId().equals(user.getUserId()) &&
                user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Clear existing items
        order.setItems(new ArrayList<>());

        // Get new order items
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

                    OrderItem orderItem = new OrderItem(
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

        // Update order
        if (orderDAO.updateOrder(order)) {
            request.setAttribute("order", order);
            request.setAttribute("success", "Order updated successfully");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update order");
            request.getRequestDispatcher("/views/order/update-order.jsp").forward(request, response);
        }
    }

    /**
     * Cancel an existing order
     */
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

    /**
     * Handle errors consistently
     */
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

    /**
     * Get current user from session
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    // Additional utility methods can be added here if needed

    /**
     * Bulk update order statuses (for admin use)
     */
    private void bulkUpdateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        try {
            // Parse order IDs and new status from request body
            java.io.BufferedReader reader = request.getReader();
            StringBuilder jsonBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }

            // Parse JSON (you'd typically use a JSON library in a real application)
            org.json.JSONObject jsonObject = new org.json.JSONObject(jsonBuilder.toString());

            // Get order IDs and status
            org.json.JSONArray orderIdsJson = jsonObject.getJSONArray("orderIds");
            String statusStr = jsonObject.getString("status");

            // Convert JSON array to list of order IDs
            List<String> orderIds = new ArrayList<>();
            for (int i = 0; i < orderIdsJson.length(); i++) {
                orderIds.add(orderIdsJson.getString(i));
            }

            // Convert status
            Order.OrderStatus newStatus = Order.OrderStatus.valueOf(statusStr);

            // Perform bulk update
            int updatedCount = orderDAO.bulkUpdateOrderStatus(orderIds, newStatus);

            // Prepare JSON response
            org.json.JSONObject responseJson = new org.json.JSONObject();
            responseJson.put("success", true);
            responseJson.put("updatedCount", updatedCount);

            // Send JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(responseJson.toString());
        } catch (Exception e) {
            // Handle JSON parsing or other errors
            LOGGER.log(Level.SEVERE, "Error in bulk order update", e);

            // Prepare error response
            org.json.JSONObject errorJson = new org.json.JSONObject();
            errorJson.put("success", false);
            errorJson.put("message", "Failed to update orders: " + e.getMessage());

            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(errorJson.toString());
        }
    }

    /**
     * Generate order invoice (PDF or printable view)
     */
    private void generateOrderInvoice(HttpServletRequest request, HttpServletResponse response)
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

        // Ensure only order owner or admin can view invoice
        if (!order.getUserId().equals(user.getUserId()) &&
                user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Determine output type (PDF or HTML)
        String outputType = request.getParameter("type");
        if ("pdf".equalsIgnoreCase(outputType)) {
            generatePdfInvoice(request, response, order);
        } else {
            // Default to HTML invoice view
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/order/order-invoice.jsp").forward(request, response);
        }
    }

    /**
     * Generate PDF invoice (requires additional library like iText)
     */
    private void generatePdfInvoice(HttpServletRequest request, HttpServletResponse response,
                                    Order order) throws ServletException, IOException {
        try {
            // Example using iText (you'd need to add iText dependency)
            // com.itextpdf.kernel.pdf.PdfWriter writer = new com.itextpdf.kernel.pdf.PdfWriter(response.getOutputStream());
            // com.itextpdf.kernel.pdf.PdfDocument pdf = new com.itextpdf.kernel.pdf.PdfDocument(writer);
            // com.itextpdf.layout.Document document = new com.itextpdf.layout.Document(pdf);

            // Set response headers for PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline; filename=order_" + order.getOrderId() + ".pdf");

            // Generate PDF content
            // TODO: Implement PDF generation logic

            // Close document
            // document.close();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error generating PDF invoice", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Could not generate invoice");
        }
    }

    /**
     * Override destroy method for cleanup
     */
    @Override
    public void destroy() {
        LOGGER.info("OrderServlet is being destroyed");
        // Perform any necessary cleanup
    }
}