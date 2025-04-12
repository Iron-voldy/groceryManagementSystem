// main.js - Core JavaScript functionality for the grocery management system

document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const menuToggle = document.querySelector('.menu-toggle');
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            document.body.classList.toggle('show-menu');
        });
    }

    // Admin sidebar toggle
    const sidebarToggle = document.querySelector('.toggle-sidebar');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('show');
        });
    }

    // Close alerts
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        const closeBtn = document.createElement('span');
        closeBtn.innerHTML = '&times;';
        closeBtn.className = 'alert-close';
        closeBtn.addEventListener('click', function() {
            alert.style.display = 'none';
        });
        alert.appendChild(closeBtn);
    });

    // Product quantity counter
    const quantityInputs = document.querySelectorAll('.quantity-input');
    quantityInputs.forEach(input => {
        const decrementBtn = input.parentElement.querySelector('.decrement');
        const incrementBtn = input.parentElement.querySelector('.increment');

        if (decrementBtn) {
            decrementBtn.addEventListener('click', function() {
                let value = parseInt(input.value);
                if (value > 1) {
                    input.value = value - 1;
                    triggerInputChange(input);
                }
            });
        }

        if (incrementBtn) {
            incrementBtn.addEventListener('click', function() {
                let value = parseInt(input.value);
                const max = input.getAttribute('max') || 99;
                if (value < parseInt(max)) {
                    input.value = value + 1;
                    triggerInputChange(input);
                }
            });
        }

        input.addEventListener('change', function() {
            let value = parseInt(input.value);
            const min = parseInt(input.getAttribute('min') || 1);
            const max = parseInt(input.getAttribute('max') || 99);

            if (value < min) {
                input.value = min;
            } else if (value > max) {
                input.value = max;
            }
        });
    });

    // Password toggle
    const passwordToggles = document.querySelectorAll('.password-toggle');
    passwordToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            const input = this.previousElementSibling;
            const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
            input.setAttribute('type', type);
            this.textContent = type === 'password' ? 'Show' : 'Hide';
        });
    });

    // Form validation
    const forms = document.querySelectorAll('form[data-validate="true"]');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!validateForm(form)) {
                e.preventDefault();
            }
        });

        // Real-time validation
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            input.addEventListener('blur', function() {
                validateInput(input);
            });
        });
    });
});

// Utility functions
function validateForm(form) {
    const inputs = form.querySelectorAll('input, select, textarea');
    let valid = true;

    inputs.forEach(input => {
        if (!validateInput(input)) {
            valid = false;
        }
    });

    return valid;
}

function validateInput(input) {
    if (input.hasAttribute('required') && !input.value.trim()) {
        showError(input, 'This field is required');
        return false;
    }

    if (input.type === 'email' && input.value.trim()) {
        const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!emailRegex.test(input.value.trim())) {
            showError(input, 'Please enter a valid email address');
            return false;
        }
    }

    if (input.hasAttribute('data-min-length') && input.value.trim()) {
        const minLength = parseInt(input.getAttribute('data-min-length'));
        if (input.value.length < minLength) {
            showError(input, `Must be at least ${minLength} characters`);
            return false;
        }
    }

    if (input.hasAttribute('data-match')) {
        const matchSelector = input.getAttribute('data-match');
        const matchInput = document.querySelector(matchSelector);
        if (input.value !== matchInput.value) {
            showError(input, 'Values do not match');
            return false;
        }
    }

    // Password validation
    if (input.type === 'password' && input.hasAttribute('data-validate-password') && input.value.trim()) {
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;
        if (!passwordRegex.test(input.value)) {
            showError(input, 'Password must contain at least 8 characters, one uppercase letter, one lowercase letter, and one number');
            return false;
        }
    }

    // Clear error if validation passes
    clearError(input);
    return true;
}

function showError(input, message) {
    clearError(input);
    input.classList.add('is-invalid');

    const errorElement = document.createElement('div');
    errorElement.className = 'form-error';
    errorElement.textContent = message;

    input.parentNode.appendChild(errorElement);
}

function clearError(input) {
    input.classList.remove('is-invalid');
    const errorElement = input.parentNode.querySelector('.form-error');
    if (errorElement) {
        errorElement.remove();
    }
}

function triggerInputChange(input) {
    const event = new Event('change', { bubbles: true });
    input.dispatchEvent(event);
}

// Add to cart functionality
function addToCart(productId, quantity = 1) {
    fetch(`${contextPath}/cart/add?productId=${productId}&quantity=${quantity}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Product added to cart');
            updateCartCount(data.cartItemCount);
        } else {
            showNotification(data.message || 'Failed to add product to cart', 'error');
        }
    })
    .catch(error => {
        console.error('Error adding to cart:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function updateCartCount(count) {
    const cartCountElements = document.querySelectorAll('.cart-count');
    cartCountElements.forEach(element => {
        element.textContent = count;
        if (count > 0) {
            element.classList.add('has-items');
        } else {
            element.classList.remove('has-items');
        }
    });
}

function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 10);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Rating system
function setRating(rating) {
    document.getElementById('rating').value = rating;
    const stars = document.querySelectorAll('.star-rating .star');

    stars.forEach((star, index) => {
        if (index < rating) {
            star.classList.add('active');
        } else {
            star.classList.remove('active');
        }
    });
}

// Initialize star rating if present
const starContainer = document.querySelector('.star-rating');
if (starContainer) {
    const stars = starContainer.querySelectorAll('.star');
    stars.forEach((star, index) => {
        star.addEventListener('click', function() {
            setRating(index + 1);
        });

        star.addEventListener('mouseover', function() {
            const currentRating = document.getElementById('rating').value;

            stars.forEach((s, i) => {
                if (i <= index) {
                    s.classList.add('hover');
                } else {
                    s.classList.remove('hover');
                }
            });
        });

        star.addEventListener('mouseout', function() {
            stars.forEach(s => {
                s.classList.remove('hover');
            });
        });
    });
}