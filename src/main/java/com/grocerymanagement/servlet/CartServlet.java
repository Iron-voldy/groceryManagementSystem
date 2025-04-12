package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.CartDAO;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Cart;
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

@WebServlet("/cart/*")
public class CartServlet extends HttpServlet {
    // Previous methods from the last artifact remain the same

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
        if (cartOptional.isEmpty()) {
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
        if (cartOptional.isEmpty()) {
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

        // Get user's cart
        Optional<Cart> cartOptional = cartDAO.getCartByUserId(currentUser.getUserId());
        if (cartOptional.isEmpty() || cartOptional.get().getItems().isEmpty()) {
            request.setAttribute("error", "Cart is empty");
            request.getRequestDispatcher("/views/cart/cart-view.jsp").forward(request, response);
            return;
        }

        Cart cart = cartOptional.get();

        // Validate stock for all cart items
        for (Cart.CartItem item : cart.getItems()) {
            Optional<Product> productOptional = productDAO.getProductById(item.getProductId());
            if (productOptional.isEmpty()) {
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

        // Here you would typically:
        // 1. Create an Order from the Cart
        // 2. Reduce product stocks
        // 3. Clear the cart
        // 4. Redirect to payment or order confirmation

        request.setAttribute("success", "Checkout process initiated");
        request.getRequestDispatcher("/views/order/checkout.jsp").forward(request, response);
    }
}