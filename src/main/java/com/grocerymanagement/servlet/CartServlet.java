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
import java.util.stream.Collectors;

@WebServlet("/cart/*")
public class CartServlet extends HttpServlet {
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

        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/view")) {
            viewCart(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
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
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

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
                    }
                    return item;
                })
                .collect(Collectors.toList());

        cart.setItems(enrichedItems);

        // Calculate cart total
        BigDecimal cartTotal = cart.getItems().stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        request.setAttribute("cart", cart);
        request.setAttribute("cartTotal", cartTotal);

        // Forward to cart view
        request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
    }

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
            sendJsonResponse(response, false, "Insufficient stock");
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
        cart.addItem(cartItem);

        // Save cart
        boolean success = cartOptional.isPresent() ?
                cartDAO.updateCart(cart) :
                cartDAO.createCart(cart);

        if (success) {
            // Update cart count in session
            int cartItemCount = cart.getItems().size();
            session.setAttribute("cartItemCount", cartItemCount);

            sendJsonResponse(response, true, "Item added to cart", cartItemCount);
        } else {
            sendJsonResponse(response, false, "Failed to add item to cart");
        }
    }

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

        // Check stock availability if quantity > 0
        if (quantity > 0 && product.getStockQuantity() < quantity) {
            sendJsonResponse(response, false, "Insufficient stock");
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
                sendJsonResponse(response, false, "Item not found in cart");
                return;
            }
        }

        // Update cart
        if (cartDAO.updateCart(cart)) {
            // Recalculate cart total and item count
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

            sendJsonResponse(response, true, "Cart updated", cartItemCount, cartTotal.doubleValue());
        } else {
            sendJsonResponse(response, false, "Failed to update cart");
        }
    }

    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, false, "Please log in to remove items from cart");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");

        // Validate input
        if (productId == null) {
            sendJsonResponse(response, false, "Invalid parameters");
            return;
        }

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            sendJsonResponse(response, false, "Cart not found");
            return;
        }

        Cart cart = cartOptional.get();
        cart.removeItem(productId);

        // Update cart
        if (cartDAO.updateCart(cart)) {
            // Update cart count in session
            int cartItemCount = cart.getItems().size();
            session.setAttribute("cartItemCount", cartItemCount);

            sendJsonResponse(response, true, "Item removed from cart", cartItemCount);
        } else {
            sendJsonResponse(response, false, "Failed to remove item from cart");
        }
    }

    // Utility method to send JSON responses
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + ",\"message\":\"" +
                message.replace("\"", "\\\"") + "\"}");
        out.flush();
    }

    // Overloaded method to send JSON response with cart item count
    private void sendJsonResponse(HttpServletResponse response, boolean success,
                                  String message, int cartItemCount)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success +
                ",\"message\":\"" + message.replace("\"", "\\\"") +
                "\",\"cartItemCount\":" + cartItemCount + "}");
        out.flush();
    }

    // Overloaded method to send JSON response with cart item count and total
    private void sendJsonResponse(HttpServletResponse response, boolean success,
                                  String message, int cartItemCount, double cartTotal)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success +
                ",\"message\":\"" + message.replace("\"", "\\\"") +
                "\",\"cartItemCount\":" + cartItemCount +
                ",\"cartTotal\":" + cartTotal + "}");
        out.flush();
    }
}