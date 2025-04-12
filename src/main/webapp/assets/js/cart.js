// cart.js - Functionality for cart operations

document.addEventListener('DOMContentLoaded', function() {
    initCartFunctionality();
});

function initCartFunctionality() {
    // Update quantity in cart
    const quantityInputs = document.querySelectorAll('.cart-quantity-input');
    if (quantityInputs.length > 0) {
        quantityInputs.forEach(input => {
            input.addEventListener('change', function() {
                const productId = this.getAttribute('data-product-id');
                const quantity = parseInt(this.value);
                updateCartItemQuantity(productId, quantity);
            });
        });
    }

    // Remove items from cart
    const removeButtons = document.querySelectorAll('.remove-from-cart');
    if (removeButtons.length > 0) {
        removeButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const productId = this.getAttribute('data-product-id');
                removeFromCart(productId);
            });
        });
    }

    // Clear cart button
    const clearCartButton = document.querySelector('.clear-cart');
    if (clearCartButton) {
        clearCartButton.addEventListener('click', function(e) {
            e.preventDefault();
            if (confirm('Are you sure you want to clear your cart?')) {
                clearCart();
            }
        });
    }
}

function updateCartItemQuantity(productId, quantity) {
    if (quantity < 1) {
        if (confirm('Remove this item from your cart?')) {
            removeFromCart(productId);
        } else {
            // Reset to 1 if user cancels
            document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`).value = 1;
        }
        return;
    }

    fetch(`${contextPath}/cart/update`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}&quantity=${quantity}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateCartUI(data);
        } else {
            showNotification(data.message || 'Failed to update cart', 'error');
            // Revert to previous quantity
            if (data.availableQuantity) {
                document.querySelector(`.cart-quantity-input[data-product-id="${productId}"]`).value = data.availableQuantity;
                showNotification(`Only ${data.availableQuantity} items available`, 'warning');
            }
        }
    })
    .catch(error => {
        console.error('Error updating cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function removeFromCart(productId) {
    fetch(`${contextPath}/cart/remove`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `productId=${productId}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Remove the item row from UI
            const itemRow = document.querySelector(`.cart-item[data-product-id="${productId}"]`);
            if (itemRow) {
                itemRow.remove();
            }
            updateCartUI(data);

            // Show empty cart message if cart is empty
            if (data.cartItemCount === 0) {
                document.querySelector('.cart-items').innerHTML = '<tr><td colspan="5" class="text-center">Your cart is empty</td></tr>';
                document.querySelector('.cart-actions').style.display = 'none';
            }

            showNotification('Item removed from cart');
        } else {
            showNotification(data.message || 'Failed to remove item from cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error removing from cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function clearCart() {
    fetch(`${contextPath}/cart/clear`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Clear the cart UI
            document.querySelector('.cart-items').innerHTML = '<tr><td colspan="5" class="text-center">Your cart is empty</td></tr>';
            document.querySelector('.cart-actions').style.display = 'none';
            updateCartUI(data);
            showNotification('Cart cleared');
        } else {
            showNotification(data.message || 'Failed to clear cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error clearing cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function updateCartUI(data) {
    // Update subtotal, total, etc.
    if (data.cartTotal !== undefined) {
        document.querySelector('.cart-subtotal').textContent = formatCurrency(data.cartTotal);
        document.querySelector('.cart-total').textContent = formatCurrency(data.cartTotal);
    }

    // Update cart count in header
    updateCartCount(data.cartItemCount || 0);

    // If cart is empty, show empty message
    if (data.cartItemCount === 0) {
        const checkoutBtn = document.querySelector('.checkout-btn');
        if (checkoutBtn) {
            checkoutBtn.setAttribute('disabled', 'disabled');
        }
    }
}

function formatCurrency(amount) {
    return ' + parseFloat(amount).toFixed(2);
}