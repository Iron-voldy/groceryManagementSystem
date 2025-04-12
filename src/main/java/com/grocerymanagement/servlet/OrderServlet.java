package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private OrderDAO orderDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        orderDAO = new OrderDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
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
            case "/create":
                createOrder(request, response);
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
                listOrders(request, response);
                break;
            case "/my-orders":
                getUserOrders(request, response);
                break;
            case "/details":
                getOrderDetails(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation would depend on your requirements
        // This is typically handled by the CartServlet's checkout process
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED, "Use cart checkout instead");
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String orderId = request.getParameter("orderId");
        String statusStr = request.getParameter("status");

        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();
        order.setStatus(Order.OrderStatus.valueOf(statusStr));

        if (orderDAO.updateOrder(order)) {
            request.setAttribute("success", "Order status updated successfully");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update order status");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        }
    }

    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String orderId = request.getParameter("orderId");

        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        // Ensure only the order owner or an admin can cancel
        if (!order.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Check if order can be cancelled
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            request.setAttribute("error", "Cannot cancel order that is not in pending status");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
            return;
        }

        // Restore product stock
        for (Order.OrderItem item : order.getItems()) {
            Optional<Product> productOptional = productDAO.getProductById(item.getProductId());
            if (productOptional.isPresent()) {
                Product product = productOptional.get();
                product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
                productDAO.updateProduct(product);
            }
        }

        // Update order status
        order.setStatus(Order.OrderStatus.CANCELLED);

        if (orderDAO.updateOrder(order)) {
            request.setAttribute("success", "Order cancelled successfully");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to cancel order");
            request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdminUser(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<Order> orders = orderDAO.getAllOrders();
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/views/order/order-list.jsp").forward(request, response);
    }

    private void getOrderDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String orderId = request.getParameter("orderId");

        Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
        if (!orderOptional.isPresent()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        Order order = orderOptional.get();

        // Ensure only the order owner or an admin can view details
        if (!order.getUserId().equals(currentUser.getUserId()) &&
                currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Fetch full product details for order items
        List<Order.OrderItem> orderItems = order.getItems();
        List<Product> orderProducts = orderItems.stream()
                .map(item -> productDAO.getProductById(item.getProductId()).orElse(null))
                .collect(Collectors.toList());

        request.setAttribute("order", order);
        request.setAttribute("orderProducts", orderProducts);
        request.getRequestDispatcher("/views/order/order-details.jsp").forward(request, response);
    }

    private void getUserOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        List<Order> userOrders = orderDAO.getOrdersByUserId(currentUser.getUserId());

        request.setAttribute("orders", userOrders);
        request.getRequestDispatcher("/views/order/user-orders.jsp").forward(request, response);
    }

    private boolean isAdminUser(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }
}