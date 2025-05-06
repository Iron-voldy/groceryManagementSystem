package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/orders")
public class AdminOrdersServlet extends HttpServlet {
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        orderDAO = new OrderDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get all orders
        List<Order> orders = orderDAO.getAllOrders();

        // Apply filters if provided
        String status = request.getParameter("status");
        if (status != null && !status.isEmpty()) {
            try {
                Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status);
                orders = orderDAO.getOrdersByStatus(orderStatus);
            } catch (IllegalArgumentException e) {
                // Invalid status, just use all orders
            }
        }

        // Set attributes for JSP
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", orderDAO.getAllOrders().size());

        request.getRequestDispatcher("/views/admin/orders.jsp").forward(request, response);
    }
}