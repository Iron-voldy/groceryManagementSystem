package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.CartDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.model.Cart;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@WebServlet("/cart/*")
public class CartServlet extends HttpServlet {
    private CartDAO cartDAO;
    private ProductDAO productDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        cartDAO = new CartDAO(fileInitUtil);
        productDAO = new ProductDAO(fileInitUtil);
        orderDAO = new OrderDAO(fileInitUtil);
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
            case "/checkout":
                processCheckout(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            viewCart(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        // Validate inputs
        if (productId == null || quantityStr == null) {
            request.setAttribute("error", "Invalid parameters");
            request.getRequestDispatcher("/views/product/product-details.jsp").forward(request, response);
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity <= 0) {
                throw new NumberFormatException("Quantity must be positive");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid quantity");
            request.getRequestDispatcher("/views/product/product-details.jsp").forward(request, response);
            return;
        }

        // Check product exists and has enough stock
        Optional<Product> productOptional = productDAO.getProductById(productId);
        if (!productOptional.isPresent()) {
            request.setAttribute("error", "Product not found");
            request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
            return;
        }

        Product product = productOptional.get();
        if (product.getStockQuantity() < quantity) {
            request.setAttribute("error", "Not enough stock available");
            request.setAttribute("product", product);
            request.getRequestDispatcher("/views/product/product-details.jsp").forward(request, response);
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

        // Add item to cart
        Cart.CartItem newItem = new Cart.CartItem(productId, quantity, product.getPrice());
        cart.addItem(newItem);

        // Save cart
        if (!cartOptional.isPresent()) {
            cartDAO.createCart(cart);
        } else {
            cartDAO.updateCart(cart);
        }

        // Redirect to cart view
        response.sendRedirect(request.getContextPath() + "/cart/");
    }

    private void updateCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        // Validate inputs
        if (productId == null || quantityStr == null) {
            request.setAttribute("error", "Invalid parameters");
            viewCart(request, response);
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity < 0) {
                throw new NumberFormatException("Quantity cannot be negative");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid quantity");
            viewCart(request, response);
            return;
        }

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            request.setAttribute("error", "Cart not found");
            viewCart(request, response);
            return;
        }

        Cart cart = cartOptional.get();

        // If quantity is 0, remove item
        if (quantity == 0) {
            cart.removeItem(productId);
        } else {
            // Check product exists and has enough stock
            Optional<Product> productOptional = productDAO.getProductById(productId);
            if (!productOptional.isPresent()) {
                request.setAttribute("error", "Product not found");
                viewCart(request, response);
                return;
            }

            Product product = productOptional.get();
            if (product.getStockQuantity() < quantity) {
                request.setAttribute("error", "Not enough stock available");
                viewCart(request, response);
                return;
            }

            // Update quantity
            boolean itemFound = false;
            for (Cart.CartItem item : cart.getItems()) {
                if (item.getProductId().equals(productId)) {
                    item.setQuantity(quantity);
                    itemFound = true;
                    break;
                }
            }

            if (!itemFound) {
                request.setAttribute("error", "Item not found in cart");
                viewCart(request, response);
                return;
            }
        }

        // Update cart
        cartDAO.updateCart(cart);

        // Redirect to cart view
        response.sendRedirect(request.getContextPath() + "/cart/");
    }

    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String productId = request.getParameter("productId");

        // Validate input
        if (productId == null) {
            request.setAttribute("error", "Invalid parameters");
            viewCart(request, response);
            return;
        }

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            request.setAttribute("error", "Cart not found");
            viewCart(request, response);
            return;
        }

        Cart cart = cartOptional.get();
        cart.removeItem(productId);

        // Update cart
        cartDAO.updateCart(cart);

        // Redirect to cart view
        response.sendRedirect(request.getContextPath() + "/cart/");
    }

    private void clearCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            request.setAttribute("error", "Cart not found");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        Cart cart = cartOptional.get();
        // Remove all items from cart
        cart.getItems().clear();

        // Update cart
        cartDAO.updateCart(cart);

        request.setAttribute("success", "Cart cleared successfully");
        request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
    }

    private void viewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent()) {
            // Create a new empty cart if not exists
            Cart newCart = new Cart(currentUser.getUserId());
            cartDAO.createCart(newCart);
            request.setAttribute("cart", newCart);
        } else {
            Cart cart = cartOptional.get();

            // Fetch full product details for cart items
            List<Product> cartProducts = cart.getItems().stream()
                    .map(item -> productDAO.getProductById(item.getProductId()).orElse(null))
                    .collect(Collectors.toList());

            // Calculate total cart value
            BigDecimal cartTotal = cart.calculateTotal();

            request.setAttribute("cart", cart);
            request.setAttribute("cartProducts", cartProducts);
            request.setAttribute("cartTotal", cartTotal);
        }

        request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
    }

    /**
     * Checkout process - convert cart to order
     */
    private void processCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Get shipping details from request
        String recipientName = request.getParameter("recipientName");
        String addressLine1 = request.getParameter("addressLine1");
        String addressLine2 = request.getParameter("addressLine2");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String postalCode = request.getParameter("postalCode");
        String country = request.getParameter("country");
        String phoneNumber = request.getParameter("phoneNumber");

        // Validate essential shipping details
        if (recipientName == null || recipientName.trim().isEmpty() ||
                addressLine1 == null || addressLine1.trim().isEmpty() ||
                city == null || city.trim().isEmpty() ||
                state == null || state.trim().isEmpty() ||
                postalCode == null || postalCode.trim().isEmpty() ||
                country == null || country.trim().isEmpty() ||
                phoneNumber == null || phoneNumber.trim().isEmpty()) {
            request.setAttribute("error", "Complete shipping information is required");
            viewCart(request, response);
            return;
        }

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (!cartOptional.isPresent() || cartOptional.get().getItems().isEmpty()) {
            request.setAttribute("error", "Cart is empty");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        Cart cart = cartOptional.get();

        // Validate stock for all cart items
        for (Cart.CartItem item : cart.getItems()) {
            Optional<Product> productOptional = productDAO.getProductById(item.getProductId());
            if (!productOptional.isPresent()) {
                request.setAttribute("error", "Product not found: " + item.getProductId());
                request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
                return;
            }

            Product product = productOptional.get();
            if (product.getStockQuantity() < item.getQuantity()) {
                request.setAttribute("error", "Insufficient stock for " + product.getName());
                request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
                return;
            }
        }

        // Create order from cart
        Order newOrder = new Order(currentUser.getUserId());

        // Set up shipping details
        Order.ShippingDetails shippingDetails = new Order.ShippingDetails(
                recipientName, addressLine1, city, state, postalCode, country, phoneNumber
        );

        // Add optional addressLine2 if provided
        if (addressLine2 != null && !addressLine2.trim().isEmpty()) {
            shippingDetails.setAddressLine2(addressLine2);
        }

        newOrder.setShippingDetails(shippingDetails);

        // Add items from cart to order
        for (Cart.CartItem cartItem : cart.getItems()) {
            // Try to get product name for better order display
            String productName = "";
            Optional<Product> productOpt = productDAO.getProductById(cartItem.getProductId());
            if (productOpt.isPresent()) {
                productName = productOpt.get().getName();
            }

            Order.OrderItem orderItem = new Order.OrderItem(
                    cartItem.getProductId(),
                    productName,
                    cartItem.getQuantity(),
                    cartItem.getPrice()
            );
            newOrder.addItem(orderItem);

            // Reduce product stock
            productDAO.updateProductStock(cartItem.getProductId(), -cartItem.getQuantity());
        }

        // Save order
        if (!orderDAO.createOrder(newOrder)) {
            request.setAttribute("error", "Failed to create order");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        // Clear the cart
        cart.getItems().clear();
        cartDAO.updateCart(cart);

        // Redirect to order confirmation
        request.setAttribute("order", newOrder);
        request.setAttribute("success", "Order placed successfully");
        request.getRequestDispatcher("/views/order/order-confirmation.jsp").forward(request, response);
    }
}