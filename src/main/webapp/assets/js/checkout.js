// checkout.js - Handles checkout process

document.addEventListener('DOMContentLoaded', function() {
    initCheckoutFunctionality();
});

function initCheckoutFunctionality() {
    // Address form toggle
    const sameAddressCheckbox = document.getElementById('same-address');
    if (sameAddressCheckbox) {
        const shippingAddressSection = document.querySelector('.shipping-address-section');

        sameAddressCheckbox.addEventListener('change', function() {
            if (this.checked) {
                shippingAddressSection.style.display = 'none';
            } else {
                shippingAddressSection.style.display = 'block';
            }
        });

        // Trigger on initial load
        if (sameAddressCheckbox.checked) {
            shippingAddressSection.style.display = 'none';
        }
    }

    // Payment method selection
    const paymentMethods = document.querySelectorAll('input[name="paymentMethod"]');
    if (paymentMethods.length > 0) {
        const paymentForms = document.querySelectorAll('.payment-method-form');

        paymentMethods.forEach(method => {
            method.addEventListener('change', function() {
                // Hide all payment forms
                paymentForms.forEach(form => {
                    form.style.display = 'none';
                });

                // Show selected payment form
                const selectedForm = document.querySelector(`.${this.value}-form`);
                if (selectedForm) {
                    selectedForm.style.display = 'block';
                }
            });
        });

        // Trigger the change event for the checked radio button
        const checkedMethod = document.querySelector('input[name="paymentMethod"]:checked');
        if (checkedMethod) {
            checkedMethod.dispatchEvent(new Event('change'));
        }
    }

    // Order summary toggle on mobile
    const summaryToggle = document.querySelector('.order-summary-toggle');
    if (summaryToggle) {
        const orderSummary = document.querySelector('.order-summary');

        summaryToggle.addEventListener('click', function() {
            orderSummary.classList.toggle('show-summary');
            this.querySelector('.toggle-text').textContent =
                orderSummary.classList.contains('show-summary') ? 'Hide order summary' : 'Show order summary';

            this.querySelector('.toggle-icon').textContent =
                orderSummary.classList.contains('show-summary') ? '−' : '+';
        });
    }

    // Form validation
    const checkoutForm = document.getElementById('checkout-form');
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', function(e) {
            if (!validateCheckoutForm()) {
                e.preventDefault();
            }
        });
    }

    // Credit card input formatting
    const ccNumberInput = document.getElementById('cc-number');
    if (ccNumberInput) {
        ccNumberInput.addEventListener('input', function(e) {
            let value = this.value.replace(/\D/g, '');

            // Add space after every 4 digits
            if (value.length > 0) {
                value = value.match(/.{1,4}/g).join(' ');
            }

            this.value = value;
        });
    }

    // Expiry date formatting
    const expiryInput = document.getElementById('cc-expiry');
    if (expiryInput) {
        expiryInput.addEventListener('input', function(e) {
            let value = this.value.replace(/\D/g, '');

            if (value.length > 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }

            this.value = value;
        });
    }
}

function validateCheckoutForm() {
    let valid = true;

    // Personal information validation
    valid = validateRequired('first-name') && valid;
    valid = validateRequired('last-name') && valid;
    valid = validateEmail('email') && valid;
    valid = validateRequired('phone') && valid;

    // Billing address validation
    valid = validateRequired('billing-address') && valid;
    valid = validateRequired('billing-city') && valid;
    valid = validateRequired('billing-state') && valid;
    valid = validateRequired('billing-zip') && valid;

    // Shipping address validation if different from billing
    const sameAddressCheckbox = document.getElementById('same-address');
    if (sameAddressCheckbox && !sameAddressCheckbox.checked) {
        valid = validateRequired('shipping-address') && valid;
        valid = validateRequired('shipping-city') && valid;
        valid = validateRequired('shipping-state') && valid;
        valid = validateRequired('shipping-zip') && valid;
    }

    // Payment method validation
    const selectedPaymentMethod = document.querySelector('input[name="paymentMethod"]:checked');
    if (!selectedPaymentMethod) {
        showError(document.querySelector('.payment-methods'), 'Please select a payment method');
        valid = false;
    } else {
        // Validate the selected payment method form
        if (selectedPaymentMethod.value === 'credit-card') {
            valid = validateCreditCardFields() && valid;
        } else if (selectedPaymentMethod.value === 'paypal') {
            valid = validateRequired('paypal-email') && valid;
        }
    }

    return valid;
}

function validateCreditCardFields() {
    let valid = true;

    valid = validateRequired('cc-name') && valid;
    valid = validateRequired('cc-number') && valid;
    valid = validateRequired('cc-expiry') && valid;
    valid = validateRequired('cc-cvv') && valid;

    // Additional validation for credit card format
    const ccNumber = document.getElementById('cc-number').value.replace(/\s/g, '');
    if (ccNumber && !validateCreditCardNumber(ccNumber)) {
        showError(document.getElementById('cc-number'), 'Please enter a valid credit card number');
        valid = false;
    }

    // Expiry date validation
    const expiry = document.getElementById('cc-expiry').value;
    if (expiry && !validateExpiryDate(expiry)) {
        showError(document.getElementById('cc-expiry'), 'Please enter a valid expiry date (MM/YY)');
        valid = false;
    }

    // CVV validation
    const cvv = document.getElementById('cc-cvv').value;
    if (cvv && !validateCVV(cvv)) {
        showError(document.getElementById('cc-cvv'), 'Please enter a valid CVV (3-4 digits)');
        valid = false;
    }

    return valid;
}

// Helper validation functions
function validateRequired(id) {
    const input = document.getElementById(id);
    if (!input) return true;

    if (!input.value.trim()) {
        showError(input, 'This field is required');
        return false;
    }

    clearError(input);
    return true;
}

function validateEmail(id) {
    const input = document.getElementById(id);
    if (!input) return true;

    if (!input.value.trim()) {
        showError(input, 'Email is required');
        return false;
    }

    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
    if (!emailRegex.test(input.value.trim())) {
        showError(input, 'Please enter a valid email address');
        return false;
    }

    clearError(input);
    return true;
}

function validateCreditCardNumber(number) {
    // Remove all spaces and dashes
    number = number.replace(/[\s-]/g, '');

    // Check if the number contains only digits
    if (!/^\d+$/.test(number)) return false;

    // Check length (most card types are between 13-19 digits)
    if (number.length < 13 || number.length > 19) return false;

    // Luhn algorithm validation
    let sum = 0;
    let double = false;

    for (let i = number.length - 1; i >= 0; i--) {
        let digit = parseInt(number.charAt(i));

        if (double) {
            digit *= 2;
            if (digit > 9) digit -= 9;
        }

        sum += digit;
        double = !double;
    }

    return sum % 10 === 0;
}

function validateExpiryDate(expiry) {
    // Check format MM/YY
    if (!/^\d{2}\/\d{2}$/.test(expiry)) return false;

    const [month, year] = expiry.split('/');
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear() % 100; // Get last 2 digits of year
    const currentMonth = currentDate.getMonth() + 1; // January is 0

    // Convert to numbers
    const expiryMonth = parseInt(month);
    const expiryYear = parseInt(year);

    // Check if month is valid
    if (expiryMonth < 1 || expiryMonth > 12) return false;

    // Check if date is in the past
    if (expiryYear < currentYear || (expiryYear === currentYear && expiryMonth < currentMonth)) {
        return false;
    }

    return true;
}

function validateCVV(cvv) {
    return /^\d{3,4}$/.test(cvv);
}

// Error handling
function showError(input, message) {
    clearError(input);

    const errorElement = document.createElement('div');
    errorElement.className = 'form-error';
    errorElement.textContent = message;

    input.classList.add('is-invalid');
    input.parentNode.appendChild(errorElement);
}

function clearError(input) {
    input.classList.remove('is-invalid');

    const errorElement = input.parentNode.querySelector('.form-error');
    if (errorElement) {
        errorElement.remove();
    }
}