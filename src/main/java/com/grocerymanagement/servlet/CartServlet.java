package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.CartDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Cart;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * Servlet to handle all cart-related operations
 */

@WebServlet(urlPatterns = {"/cart", "/cart/*"})
public class CartServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CartServlet.class.getName());

    private CartDAO cartDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        cartDAO = new CartDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/view")) {
                viewCart(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cart view", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "An error occurred while viewing the cart");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid cart operation");
                return;
            }

            switch (pathInfo) {
                case "/add":
                    addToCart(request, response);
                    break;
                case "/update":
                    updateCart(request, response);
                    break;
                case "/remove":
                    removeFromCart(request, response);
                    break;
                case "/clear":
                    clearCart(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cart operation", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "An error occurred while processing cart operation");
        }
    }

    /**
     * View cart for the current user
     */
    private void viewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Fetch user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());

        Cart cart = cartOptional.orElse(new Cart(currentUser.getUserId()));

        // Enrich cart items with product details
        List<Cart.CartItem> enrichedItems = cart.getItems().stream()
                .map(item -> {
                    Optional<Product> productOpt = productDAO.getProductById(item.getProductId());
                    if (productOpt.isPresent()) {
                        Product product = productOpt.get();
                        // Update item with product name if not already set
                        if (item.getProductName() == null) {
                            item.setProductName(product.getName());
                        }
                        // Ensure price is current
                        item.setPrice(product.getPrice());
                    }
                    return item;
                })
                .collect(Collectors.toList());

        cart.setItems(enrichedItems);

        // Calculate cart total
        BigDecimal cartTotal = cart.getItems().stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Update cart count in session
        session.setAttribute("cartItemCount", cart.getItems().size());

        request.setAttribute("cart", cart);
        request.setAttribute("cartTotal", cartTotal);

        // Forward to cart view
        request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
    }

    /**
     * Add a product to the cart
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, false, "Please log in to add items to cart");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        // Validate inputs
        if (productId == null || quantityStr == null) {
            sendJsonResponse(response, false, "Invalid parameters");
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity <= 0) {
                sendJsonResponse(response, false, "Quantity must be positive");
                return;
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "Invalid quantity");
            return;
        }

        // Check if product exists
        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            sendJsonResponse(response, false, "Product not found");
            return;
        }

        Product product = productOptional.get();

        // Check stock availability
        if (product.getStockQuantity() < quantity) {
            sendJsonResponse(response, false,
                    "Insufficient stock (Available: " + product.getStockQuantity() + ")",
                    0, 0);
            return;
        }

        // Get or create cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        Cart cart;
        if (!cartOptional.isPresent()) {
            cart = new Cart(currentUser.getUserId());
        } else {
            cart = cartOptional.get();
        }

        // Create cart item
        Cart.CartItem cartItem = new Cart.CartItem(
                productId,
                quantity,
                product.getPrice(),
                product.getName()
        );

        // Check if item already exists in cart
        boolean itemUpdated = false;
        for (Cart.CartItem existingItem : cart.getItems()) {
            if (existingItem.getProductId().equals(productId)) {
                // Update existing item quantity
                int newQuantity = existingItem.getQuantity() + quantity;
                if (newQuantity > product.getStockQuantity()) {
                    sendJsonResponse(response, false,
                            "Total quantity exceeds available stock",
                            0, 0);
                    return;
                }
                existingItem.setQuantity(newQuantity);
                itemUpdated = true;
                break;
            }
        }

        // If item not already in cart, add new item
        if (!itemUpdated) {
            cart.addItem(cartItem);
        }

        // Save cart
        boolean success = cartOptional.isPresent() ?
                cartDAO.updateCart(cart) :
                cartDAO.createCart(cart);

        if (success) {
            // Recalculate cart total
            BigDecimal cartTotal = cart.getItems().stream()
                    .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Update cart count in session
            int cartItemCount = cart.getItems().size();
            session.setAttribute("cartItemCount", cartItemCount);

            sendJsonResponse(response, true, "Item added to cart",
                    cartItemCount, cartTotal.doubleValue());
        } else {
            sendJsonResponse(response, false, "Failed to add item to cart");
        }
    }

    /**
     * Update cart item quantity
     */
    private void updateCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, false, "Please log in to update cart");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        // Log received parameters
        LOGGER.info("Updating cart - ProductID: " + productId + ", Quantity: " + quantityStr);

        // Validate inputs
        if (productId == null || quantityStr == null) {
            sendJsonResponse(response, false, "Invalid parameters");
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity < 0) {
                sendJsonResponse(response, false, "Quantity cannot be negative");
                return;
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "Invalid quantity");
            return;
        }

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            sendJsonResponse(response, false, "Cart not found");
            return;
        }

        Cart cart = cartOptional.get();

        // Check if product exists
        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            sendJsonResponse(response, false, "Product not found");
            return;
        }

        Product product = productOptional.get();

        // Check stock availability if quantity is greater than 0
        if (quantity > 0 && quantity > product.getStockQuantity()) {
            sendJsonResponse(response, false,
                    "Insufficient stock (Available: " + product.getStockQuantity() + ")",
                    product.getStockQuantity());
            return;
        }

        // Remove item if quantity is 0, otherwise update
        if (quantity == 0) {
            cart.removeItem(productId);
        } else {
            boolean itemFound = false;
            for (Cart.CartItem item : cart.getItems()) {
                if (item.getProductId().equals(productId)) {
                    item.setQuantity(quantity);
                    itemFound = true;
                    break;
                }
            }

            if (!itemFound) {
                // If item not in cart, add it
                Cart.CartItem newItem = new Cart.CartItem(
                        productId,
                        quantity,
                        product.getPrice(),
                        product.getName()
                );
                cart.addItem(newItem);
            }
        }

        // Update cart
        if (cartDAO.updateCart(cart)) {
            // Recalculate cart total
            BigDecimal cartTotal = cart.getItems().stream()
                    .map(item -> {
                        Optional<Product> prod = productDAO.getProductById(item.getProductId());
                        return prod.map(p ->
                                p.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))
                        ).orElse(BigDecimal.ZERO);
                    })
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            int cartItemCount = cart.getItems().size();
            session.setAttribute("cartItemCount", cartItemCount);

            LOGGER.info("Cart updated successfully - Items: " + cartItemCount + ", Total: " + cartTotal);
            sendJsonResponse(response, true, "Cart updated",
                    cartItemCount, cartTotal.doubleValue());
        } else {
            LOGGER.warning("Failed to update cart in database");
            sendJsonResponse(response, false, "Failed to update cart");
        }
    }

    /**
     * Remove a single item from the cart
     */
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Log the start of the method
        LOGGER.info("Entering removeFromCart method");

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            LOGGER.warning("Unauthorized cart removal attempt - user not logged in");
            sendJsonResponse(response, false, "Please log in to remove items from cart");
            return;
        }

        // Get current user
        User currentUser = (User) session.getAttribute("user");

        // Get product ID to remove
        String productId = request.getParameter("productId");

        // Validate product ID
        if (productId == null || productId.trim().isEmpty()) {
            LOGGER.warning("Invalid product ID for removal - empty or null");
            sendJsonResponse(response, false, "Invalid product ID");
            return;
        }

        // Log the removal attempt
        LOGGER.info("Attempting to remove product: " + productId +
                " from cart of user: " + currentUser.getUsername());

        // Retrieve user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            LOGGER.warning("Cart not found for user: " + currentUser.getUsername());
            sendJsonResponse(response, false, "Cart not found");
            return;
        }

        // Get the cart
        Cart cart = cartOptional.get();

        // Check if the product exists in the cart before removal
        boolean productExistsInCart = cart.getItems().stream()
                .anyMatch(item -> item.getProductId().equals(productId));

        if (!productExistsInCart) {
            LOGGER.warning("Product " + productId + " not found in cart for user " +
                    currentUser.getUsername());
            sendJsonResponse(response, false, "Product not found in cart");
            return;
        }

        // Remove the item from the cart
        cart.removeItem(productId);

        // Update the cart in the database
        try {
            if (cartDAO.updateCart(cart)) {
                // Recalculate cart total
                BigDecimal cartTotal = calculateCartTotal(cart);

                // Get new cart item count
                int cartItemCount = cart.getItems().size();

                // Update cart item count in session
                session.setAttribute("cartItemCount", cartItemCount);

                // Log successful removal
                LOGGER.info("Successfully removed product " + productId +
                        " from cart. New cart size: " + cartItemCount);

                // Send successful response
                sendJsonResponse(response, true, "Item removed from cart",
                        cartItemCount, cartTotal.doubleValue());
            } else {
                // Failed to update cart
                LOGGER.severe("Failed to update cart after removing product " + productId);
                sendJsonResponse(response, false, "Failed to remove item from cart");
            }
        } catch (Exception e) {
            // Log any unexpected errors
            LOGGER.log(Level.SEVERE, "Unexpected error removing item from cart", e);
            sendJsonResponse(response, false, "An unexpected error occurred");
        }
    }

    private BigDecimal calculateCartTotal(Cart cart) {
        return cart.getItems().stream()
                .map(item -> {
                    Optional<Product> prod = productDAO.getProductById(item.getProductId());
                    return prod.map(p ->
                            p.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()))
                    ).orElse(BigDecimal.ZERO);
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }


    /**
     * Clear entire cart
     */
    private void clearCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, false, "Please log in to clear cart");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            sendJsonResponse(response, true, "Cart is already empty", 0, 0);
            return;
        }

        Cart cart = cartOptional.get();
        cart.getItems().clear(); // Clear all items

        if (cartDAO.updateCart(cart)) {
            // Update cart count in session
            session.setAttribute("cartItemCount", 0);

            sendJsonResponse(response, true, "Cart cleared", 0, 0);
        } else {
            sendJsonResponse(response, false, "Failed to clear cart");
        }
    }
    /**
     * Send JSON response with cart details
     * Basic response with success and message
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success +
                ",\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    /**
     * Send JSON response with cart item count
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success,
                                  String message, int cartItemCount)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success +
                ",\"message\":\"" + escapeJson(message) +
                "\",\"cartItemCount\":" + cartItemCount + "}");
        out.flush();
    }

    /**
     * Send JSON response with cart item count and total
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success,
                                  String message, int cartItemCount, double cartTotal)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success +
                ",\"message\":\"" + escapeJson(message) +
                "\",\"cartItemCount\":" + cartItemCount +
                ",\"cartTotal\":" + cartTotal + "}");
        out.flush();
    }

    /**
     * Escape special characters in JSON string
     */
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}