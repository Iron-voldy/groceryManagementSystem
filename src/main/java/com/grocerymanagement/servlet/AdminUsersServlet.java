package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        userDAO = new UserDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();

        // Apply filters if provided
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String searchTerm = request.getParameter("searchTerm");

        if (role != null && !role.isEmpty()) {
            try {
                User.UserRole userRole = User.UserRole.valueOf(role);
                users = users.stream()
                        .filter(user -> user.getRole() == userRole)
                        .collect(Collectors.toList());
            } catch (IllegalArgumentException e) {
                // Invalid role, just use all users
            }
        }

        if (status != null && !status.isEmpty()) {
            boolean isActive = "active".equalsIgnoreCase(status);
            users = users.stream()
                    .filter(user -> user.isActive() == isActive)
                    .collect(Collectors.toList());
        }

        if (searchTerm != null && !searchTerm.isEmpty()) {
            users = users.stream()
                    .filter(user ->
                            user.getUsername().toLowerCase().contains(searchTerm.toLowerCase()) ||
                                    user.getEmail().toLowerCase().contains(searchTerm.toLowerCase()))
                    .collect(Collectors.toList());
        }

        request.setAttribute("users", users);
        request.setAttribute("totalUsers", userDAO.getAllUsers().size());

        request.getRequestDispatcher("/views/admin/users.jsp").forward(request, response);
    }
}