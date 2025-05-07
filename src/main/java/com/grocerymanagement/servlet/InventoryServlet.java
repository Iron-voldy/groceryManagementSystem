package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.InventoryDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Inventory;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@WebServlet("/inventory/*")
public class InventoryServlet extends HttpServlet {
    private InventoryDAO inventoryDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        inventoryDAO = new InventoryDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
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
                    listInventory(request, response);
                    break;
                case "/add":
                    showAddInventoryForm(request, response);
                    break;
                case "/update":
                    showUpdateInventoryForm(request, response);
                    break;
                case "/details":
                    showInventoryDetails(request, response);
                    break;
                case "/low-stock":
                    getLowStockInventory(request, response);
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

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        try {
            switch (pathInfo) {
                case "/add":
                    addInventory(request, response);
                    break;
                case "/update":
                    updateInventory(request, response);
                    break;
                case "/delete":
                    deleteInventory(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    private void listInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<Inventory> inventoryList = inventoryDAO.getAllInventory();
        request.setAttribute("inventoryList", inventoryList);
        request.getRequestDispatcher("/views/admin/inventory.jsp").forward(request, response);
    }

    private void showAddInventoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        prepareProductList(request);
        request.getRequestDispatcher("/views/inventory/add-inventory.jsp").forward(request, response);
    }

    private void addInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        try {
            String productId = request.getParameter("productId");
            int currentStock = Integer.parseInt(request.getParameter("currentStock"));
            int minimumStockLevel = Integer.parseInt(request.getParameter("minimumStockLevel"));
            int maximumStockLevel = Integer.parseInt(request.getParameter("maximumStockLevel"));
            String warehouseLocation = request.getParameter("warehouseLocation");

            Optional<Product> productOptional = productDAO.getProductById(productId);
            if (!productOptional.isPresent()) {
                request.setAttribute("error", "Product not found");
                prepareProductList(request);
                request.getRequestDispatcher("/views/inventory/add-inventory.jsp").forward(request, response);
                return;
            }

            Product product = productOptional.get();

            // Check if inventory already exists for this product
            Optional<Inventory> existingInventory = inventoryDAO.getInventoryByProductId(productId);
            if (existingInventory.isPresent()) {
                request.setAttribute("error", "Inventory record already exists for this product");
                prepareProductList(request);
                request.getRequestDispatcher("/views/inventory/add-inventory.jsp").forward(request, response);
                return;
            }

            Inventory inventory = new Inventory();
            inventory.setProductId(productId);
            inventory.setProductName(product.getName());
            inventory.setCurrentStock(currentStock);
            inventory.setMinimumStockLevel(minimumStockLevel);
            inventory.setMaximumStockLevel(maximumStockLevel);
            inventory.setWarehouseLocation(warehouseLocation);
            inventory.updateInventoryStatus();

            if (inventoryDAO.createInventory(inventory)) {
                request.setAttribute("success", "Inventory record created successfully");
                response.sendRedirect(request.getContextPath() + "/inventory/list");
            } else {
                request.setAttribute("error", "Failed to create inventory record");
                prepareProductList(request);
                request.getRequestDispatcher("/views/inventory/add-inventory.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input. Please check the numbers.");
            prepareProductList(request);
            request.getRequestDispatcher("/views/inventory/add-inventory.jsp").forward(request, response);
        }
    }

    private void showUpdateInventoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String productId = request.getParameter("productId");
        Optional<Inventory> inventoryOptional = inventoryDAO.getInventoryByProductId(productId);

        if (!inventoryOptional.isPresent()) {
            request.setAttribute("error", "Inventory record not found");
            response.sendRedirect(request.getContextPath() + "/inventory/list");
            return;
        }

        request.setAttribute("inventory", inventoryOptional.get());
        request.getRequestDispatcher("/views/inventory/edit-inventory.jsp").forward(request, response);
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        try {
            String productId = request.getParameter("productId");
            int currentStock = Integer.parseInt(request.getParameter("currentStock"));
            int minimumStockLevel = Integer.parseInt(request.getParameter("minimumStockLevel"));
            int maximumStockLevel = Integer.parseInt(request.getParameter("maximumStockLevel"));
            String warehouseLocation = request.getParameter("warehouseLocation");

            Optional<Inventory> existingInventoryOptional = inventoryDAO.getInventoryByProductId(productId);
            if (!existingInventoryOptional.isPresent()) {
                request.setAttribute("error", "Inventory record not found");
                response.sendRedirect(request.getContextPath() + "/inventory/list");
                return;
            }

            Inventory inventory = existingInventoryOptional.get();
            inventory.setCurrentStock(currentStock);
            inventory.setMinimumStockLevel(minimumStockLevel);
            inventory.setMaximumStockLevel(maximumStockLevel);
            inventory.setWarehouseLocation(warehouseLocation);
            inventory.setLastUpdated(LocalDateTime.now());
            inventory.updateInventoryStatus();

            if (inventoryDAO.updateInventory(inventory)) {
                request.setAttribute("success", "Inventory record updated successfully");
                response.sendRedirect(request.getContextPath() + "/inventory/list");
            } else {
                request.setAttribute("error", "Failed to update inventory record");
                request.setAttribute("inventory", inventory);
                request.getRequestDispatcher("/views/inventory/edit-inventory.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input. Please check the numbers.");
            request.getRequestDispatcher("/views/inventory/edit-inventory.jsp").forward(request, response);
        }
    }

    private void deleteInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String productId = request.getParameter("productId");

        if (inventoryDAO.deleteInventory(productId)) {
            request.setAttribute("success", "Inventory record deleted successfully");
            response.sendRedirect(request.getContextPath() + "/inventory/list");
        } else {
            request.setAttribute("error", "Failed to delete inventory record");
            response.sendRedirect(request.getContextPath() + "/inventory/list");
        }
    }

    private void showInventoryDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String productId = request.getParameter("productId");
        Optional<Inventory> inventoryOptional = inventoryDAO.getInventoryByProductId(productId);

        if (!inventoryOptional.isPresent()) {
            request.setAttribute("error", "Inventory record not found");
            response.sendRedirect(request.getContextPath() + "/inventory/list");
            return;
        }

        request.setAttribute("inventory", inventoryOptional.get());
        request.getRequestDispatcher("/views/inventory/inventory-details.jsp").forward(request, response);
    }

    private void getLowStockInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminUser(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<Inventory> lowStockInventory = inventoryDAO.getLowStockInventory();
        request.setAttribute("lowStockInventory", lowStockInventory);
        request.getRequestDispatcher("/views/admin/inventory-alerts.jsp").forward(request, response);
    }

    private void prepareProductList(HttpServletRequest request) {
        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
    }

    private boolean isAdminUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        e.printStackTrace();
        request.setAttribute("error", "An error occurred: " + e.getMessage());
        request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
    }
}