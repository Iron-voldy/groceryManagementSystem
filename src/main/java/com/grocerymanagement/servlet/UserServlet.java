package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.model.User;
import com.grocerymanagement.util.SecurityUtil;
import com.grocerymanagement.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Optional;

@WebServlet("/user/*")
public class UserServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        userDAO = new UserDAO(fileInitUtil);
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
            case "/register":
                registerUser(request, response);
                break;
            case "/login":
                loginUser(request, response);
                break;
            case "/update":
                updateUser(request, response);
                break;
            case "/delete":
                deleteUser(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void registerUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Validate input
        if (!ValidationUtil.isValidUsername(username) ||
                !ValidationUtil.isValidEmail(email) ||
                !ValidationUtil.isValidPassword(password)) {
            request.setAttribute("error", "Invalid input");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        // Check if username or email already exists
        if (userDAO.getUserByUsername(username).isPresent() ||
                userDAO.getUserByEmail(email).isPresent()) {
            request.setAttribute("error", "Username or email already exists");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        // Create user
        User newUser = new User(
                username,
                email,
                SecurityUtil.hashPassword(password),
                User.UserRole.valueOf(role.toUpperCase())
        );

        if (userDAO.createUser(newUser)) {
            // Redirect to login page
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
        }
    }

    private void loginUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Optional<User> userOptional = userDAO.getUserByUsername(username);

        if (userOptional.isPresent()) {
            User user = userOptional.get();

            if (SecurityUtil.verifyPassword(password, user.getPasswordHash())) {
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // Redirect based on user role
                switch (user.getRole()) {
                    case ADMIN:
                        response.sendRedirect(request.getContextPath() + "/views/admin/dashboard.jsp");
                        break;
                    case CUSTOMER:
                        response.sendRedirect(request.getContextPath() + "/views/user/profile.jsp");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/views/home.jsp");
                }
                return;
            }
        }

        // Login failed
        request.setAttribute("error", "Invalid username or password");
        request.getRequestDispatcher("/views/user/login.jsp").forward(request, response);
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");

        // Validate input
        if (email != null && !ValidationUtil.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email");
            request.getRequestDispatcher("/views/user/profile.jsp").forward(request, response);
            return;
        }

        // Update user details
        if (email != null && !email.isEmpty()) {
            currentUser.setEmail(email);
        }

        if (newPassword != null && !newPassword.isEmpty()) {
            if (!ValidationUtil.isValidPassword(newPassword)) {
                request.setAttribute("error", "Invalid password");
                request.getRequestDispatcher("/views/user/profile.jsp").forward(request, response);
                return;
            }
            currentUser.setPasswordHash(SecurityUtil.hashPassword(newPassword));
        }

        if (userDAO.updateUser(currentUser)) {
            session.setAttribute("user", currentUser);
            request.setAttribute("success", "Profile updated successfully");
            request.getRequestDispatcher("/views/user/profile.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Update failed");
            request.getRequestDispatcher("/views/user/profile.jsp").forward(request, response);
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        if (userDAO.deleteUser(currentUser.getUserId())) {
            // Invalidate session
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/views/home.jsp");
        } else {
            request.setAttribute("error", "Account deletion failed");
            request.getRequestDispatcher("/views/user/profile.jsp").forward(request, response);
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
                listUsers(request, response);
                break;
            case "/logout":
                logoutUser(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        request.setAttribute("users", userDAO.getAllUsers());
        request.getRequestDispatcher("/views/user/user-list.jsp").forward(request, response);
    }

    private void logoutUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/views/home.jsp");
    }
}