package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.UserDAO;
import com.grocerymanagement.model.User;
import com.grocerymanagement.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/setup")
public class FirstTimeSetupServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        userDAO = new UserDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if admin can be created
        User defaultAdmin = new User(
                "admin",
                "admin@groceryshop.com",
                SecurityUtil.hashPassword("AdminPassword123!"),
                User.UserRole.ADMIN
        );

        boolean adminCreated = userDAO.createUser(defaultAdmin);

        if (adminCreated) {
            request.setAttribute("message", "Initial admin account created. Please log in.");
            request.setAttribute("username", "admin");
        } else {
            request.setAttribute("message", "Admin account already exists or could not be created.");
        }

        request.getRequestDispatcher("/views/setup.jsp").forward(request, response);
    }
}