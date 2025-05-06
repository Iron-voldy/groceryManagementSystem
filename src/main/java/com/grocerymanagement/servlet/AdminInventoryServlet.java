package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.InventoryDAO;
import com.grocerymanagement.model.Inventory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/inventory")
public class AdminInventoryServlet extends HttpServlet {
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        inventoryDAO = new InventoryDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        action = (action == null) ? "list" : action;

        switch (action) {
            case "low-stock":
                showLowStockInventory(request, response);
                break;
            case "list":
            default:
                listInventory(request, response);
                break;
        }
    }

    private void listInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Inventory> inventoryList = inventoryDAO.getAllInventory();
        request.setAttribute("inventoryList", inventoryList);
        request.getRequestDispatcher("/views/admin/inventory-management.jsp").forward(request, response);
    }

    private void showLowStockInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Inventory> lowStockInventory = inventoryDAO.getLowStockInventory();
        request.setAttribute("lowStockInventory", lowStockInventory);
        request.getRequestDispatcher("/views/admin/inventory-alerts.jsp").forward(request, response);
    }
}