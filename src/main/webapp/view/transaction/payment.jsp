<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Payment" />
    <jsp:param name="active" value="cart" />
    <jsp:param name="scripts" value="checkout" />
</jsp:include>

<div class="payment-container">
    <div class="payment-header">
        <h1 class="page-title">Payment</h1>
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/index.jsp">Home</a> &gt;
            <a href="${pageContext.request.contextPath}/cart/view">Cart</a> &gt;
            <a href="${pageContext.request.contextPath}/cart/checkout">Checkout</a> &gt;
            <span>Payment</span>
        </div>
    </div>

    <div class="payment-content">
        <div class="payment-main">
            <div class="payment-section">
                <h2 class="section-title">Payment Method</h2>

                <form id="payment-form" action="${pageContext.request.contextPath}/transaction/process" method="post" data-validate="true">
                    <input type="hidden" name="orderId" value="${order.orderId}">

                    <div class="payment-methods">
                        <div class="payment-method">
                            <input type="radio" id="credit-card" name="paymentMethod" value="CREDIT_CARD" checked>
                            <label for="credit-card">Credit Card</label>
                        </div>

                        <div class="payment-method">
                            <input type="radio" id="debit-card" name="paymentMethod" value="DEBIT_CARD">
                            <label for="debit-card">Debit Card</label>
                        </div>

                        <div class="payment-method">
                            <input type="radio" id="net-banking" name="paymentMethod" value="NET_BANKING">
                            <label for="net-banking">Net Banking</label>
                        </div>

                        <div class="payment-method">
                            <input type="radio" id="digital-wallet" name="paymentMethod" value="DIGITAL_WALLET">
                            <label for="digital-wallet">Digital Wallet</label>
                        </div>
                    </div>

                    <!-- Credit Card Form (default) -->
                    <div class="payment-method-form credit-card-form">
                        <div class="form-group">
                            <label for="cc-name">Name on Card</label>
                            <input type="text" id="cc-name" name="ccName" required>
                        </div>

                        <div class="form-group">
                            <label for="cc-number">Card Number</label>
                            <input type="text" id="cc-number" name="ccNumber" placeholder="1234 5678 9012 3456" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="cc-expiry">Expiry Date</label>
                                <input type="text" id="cc-expiry" name="ccExpiry" placeholder="MM/YY" required>
                            </div>

                            <div class="form-group">
                                <label for="cc-cvv">CVV</label>
                                <input type="text" id="cc-cvv" name="ccCvv" placeholder="123" required>
                            </div>
                        </div>
                    </div>

                    <!-- Debit Card Form -->
                    <div class="payment-method-form debit-card-form" style="display: none;">
                        <div class="form-group">
                            <label for="dc-name">Name on Card</label>
                            <input type="text" id="dc-name" name="dcName">
                        </div>

                        <div class="form-group">
                            <label for="dc-number">Card Number</label>
                            <input type="text" id="dc-number" name="dcNumber" placeholder="1234 5678 9012 3456">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="dc-expiry">Expiry Date</label>
                                <input type="text" id="dc-expiry" name="dcExpiry" placeholder="MM/YY">
                            </div>

                            <div class="form-group">
                                <label for="dc-cvv">CVV</label>
                                <input type="text" id="dc-cvv" name="dcCvv" placeholder="123">
                            </div>
                        </div>
                    </div>

                    <!-- Net Banking Form -->
                    <div class="payment-method-form net-banking-form" style="display: none;">
                        <div class="form-group">
                            <label for="bank-name">Select Bank</label>
                            <select id="bank-name" name="bankName">
                                <option value="">Select your bank</option>
                                <option value="bank1">Bank of America</option>
                                <option value="bank2">Chase Bank</option>
                                <option value="bank3">Wells Fargo</option>
                                <option value="bank4">Citibank</option>
                                <option value="bank5">Capital One</option>
                            </select>
                        </div>
                    </div>

                    <!-- Digital Wallet Form -->
                    <div class="payment-method-form digital-wallet-form" style="display: none;">
                        <div class="form-group">
                            <label for="wallet-type">Select Wallet</label>
                            <select id="wallet-type" name="walletType">
                                <option value="">Select your wallet</option>
                                <option value="paypal">PayPal</option>
                                <option value="applepay">Apple Pay</option>
                                <option value="googlepay">Google Pay</option>
                                <option value="amazonpay">Amazon Pay</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="wallet-email">Email Address</label>
                            <input type="email" id="wallet-email" name="walletEmail" placeholder="you@example.com">
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/cart/checkout" class="btn btn-secondary">Back to Checkout</a>
                        <button type="submit" class="btn btn-primary">Complete Payment</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="payment-sidebar">
            <div class="order-summary">
                <h2 class="summary-title">Order Summary</h2>

                <div class="order-items">
                    <c:forEach var="item" items="${order.items}" varStatus="status">
                        <div class="order-item">
                            <div class="order-item-details">
                                <div class="order-item-info">
                                    <h3 class="order-item-name">${item.productName}</h3>
                                    <p class="order-item-price">$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/> x ${item.quantity}</p>
                                </div>
                            </div>
                            <div class="order-item-total">
                                $<fmt:formatNumber value="${item.price.multiply(java.math.BigDecimal.valueOf(item.quantity))}" pattern="#,##0.00"/>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="summary-section">
                    <div class="summary-item">
                        <span>Subtotal</span>
                        <span>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></span>
                    </div>

                    <div class="summary-item">
                        <span>Shipping</span>
                        <span>$<fmt:formatNumber value="${shippingCost}" pattern="#,##0.00"/></span>
                    </div>

                    <div class="summary-item">
                        <span>Tax</span>
                        <span>$<fmt:formatNumber value="${taxAmount}" pattern="#,##0.00"/></span>
                    </div>
                </div>

                <div class="summary-divider"></div>

                <div class="summary-section">
                    <div class="summary-item summary-total">
                        <span>Total</span>
                        <span>$<fmt:formatNumber value="${orderTotal}" pattern="#,##0.00"/></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.payment-container {
    padding: 20px 0;
}

.payment-header {
    margin-bottom: 30px;
}

.page-title {
    margin-bottom: 10px;
    color: var(--dark-text);
}

.breadcrumbs {
    font-size: 14px;
    color: var(--light-text);
    margin-bottom: 20px;
}

.breadcrumbs a {
    color: var(--light-text);
}

.breadcrumbs a:hover {
    color: var(--primary);
}

.payment-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.payment-main {
    flex: 2;
    min-width: 300px;
}

.payment-sidebar {
    flex: 1;
    min-width: 250px;
}

.payment-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.section-title {
    margin-bottom: 25px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.payment-methods {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-bottom: 25px;
}

.payment-method {
    flex: 1;
    min-width: 120px;
    display: flex;
    align-items: center;
    padding: 15px;
    border-radius: var(--border-radius);
    background-color: var(--dark-surface-hover);
    cursor: pointer;
    transition: var(--transition);
}

.payment-method:hover {
    background-color: rgba(76, 175, 80, 0.1);
}

.payment-method input[type="radio"] {
    margin-right: 10px;
}

.payment-method-form {
    margin-top: 25px;
    padding-top: 25px;
    border-top: 1px dashed #333;
}

.form-row {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.form-row .form-group {
    flex: 1;
    min-width: 120px;
}

.form-group {
    margin-bottom: 20px;
}

.form-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 30px;
}

.order-summary {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    box-shadow: var(--card-shadow);
    position: sticky;
    top: 100px;
}

.summary-title {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.order-items {
    margin-bottom: 20px;
    max-height: 300px;
    overflow-y: auto;
}

.order-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid #333;
}

.order-item:last-child {
    border-bottom: none;
}

.order-item-name {
    margin-bottom: 5px;
    font-size: 16px;
    color: var(--dark-text);
}

.order-item-price {
    font-size: 14px;
    color: var(--light-text);
}

.order-item-total {
    font-weight: 600;
    color: var(--secondary);
}

.summary-section {
    margin-bottom: 20px;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: var(--light-text);
}

.summary-divider {
    height: 1px;
    background-color: #333;
    margin: 20px 0;
}

.summary-total {
    font-weight: 600;
    font-size: 18px;
    color: var(--dark-text);
}

@media (max-width: 768px) {
    .payment-content {
        flex-direction: column-reverse;
    }

    .form-row {
        flex-direction: column;
        gap: 0;
    }

    .form-actions {
        flex-direction: column-reverse;
        gap: 15px;
    }

    .form-actions .btn {
        width: 100%;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Payment method selection
    const paymentMethods = document.querySelectorAll('input[name="paymentMethod"]');
    const paymentForms = document.querySelectorAll('.payment-method-form');

    paymentMethods.forEach(method => {
        method.addEventListener('change', function() {
            // Hide all payment forms
            paymentForms.forEach(form => {
                form.style.display = 'none';
            });

            // Show selected payment form
            const selectedForm = document.querySelector(`.${this.value.toLowerCase()}-form`);
            if (selectedForm) {
                selectedForm.style.display = 'block';
            }
        });
    });

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

    // Debit card input formatting
    const dcNumberInput = document.getElementById('dc-number');
    if (dcNumberInput) {
        dcNumberInput.addEventListener('input', function(e) {
            let value = this.value.replace(/\D/g, '');

            // Add space after every 4 digits
            if (value.length > 0) {
                value = value.match(/.{1,4}/g).join(' ');
            }

            this.value = value;
        });
    }

    // Expiry date formatting for credit card
    const ccExpiryInput = document.getElementById('cc-expiry');
    if (ccExpiryInput) {
        ccExpiryInput.addEventListener('input', function(e) {
            let value = this.value.replace(/\D/g, '');

            if (value.length > 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }

            this.value = value;
        });
    }

    // Expiry date formatting for debit card
    const dcExpiryInput = document.getElementById('dc-expiry');
    if (dcExpiryInput) {
        dcExpiryInput.addEventListener('input', function(e) {
            let value = this.value.replace(/\D/g, '');

            if (value.length > 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }

            this.value = value;
        });
    }

    // Form validation
    const paymentForm = document.getElementById('payment-form');
    if (paymentForm) {
        paymentForm.addEventListener('submit', function(e) {
            if (!validatePaymentForm()) {
                e.preventDefault();
            }
        });
    }

    function validatePaymentForm() {
        let valid = true;

        // Get selected payment method
        const selectedPaymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;

        // Validate based on payment method
        if (selectedPaymentMethod === 'CREDIT_CARD') {
            valid = validateCreditCardFields() && valid;
        } else if (selectedPaymentMethod === 'DEBIT_CARD') {
            valid = validateDebitCardFields() && valid;
        } else if (selectedPaymentMethod === 'NET_BANKING') {
            valid = validateNetBankingFields() && valid;
        } else if (selectedPaymentMethod === 'DIGITAL_WALLET') {
            valid = validateDigitalWalletFields() && valid;
        }

        return valid;
    }

    function validateCreditCardFields() {
        let valid = true;

        // Validate name on card
        const ccName = document.getElementById('cc-name');
        if (!ccName.value.trim()) {
            showError(ccName, 'Name on card is required');
            valid = false;
        } else {
            clearError(ccName);
        }

        // Validate card number
        const ccNumber = document.getElementById('cc-number');
        const cardNumber = ccNumber.value.replace(/\s/g, '');
        if (!cardNumber) {
            showError(ccNumber, 'Card number is required');
            valid = false;
        } else if (!validateCreditCardNumber(cardNumber)) {
            showError(ccNumber, 'Please enter a valid card number');
            valid = false;
        } else {
            clearError(ccNumber);
        }

        // Validate expiry date
        const ccExpiry = document.getElementById('cc-expiry');
        if (!ccExpiry.value.trim()) {
            showError(ccExpiry, 'Expiry date is required');
            valid = false;
        } else if (!validateExpiryDate(ccExpiry.value)) {
            showError(ccExpiry, 'Please enter a valid expiry date (MM/YY)');
            valid = false;
        } else {
            clearError(ccExpiry);
        }

        // Validate CVV
        const ccCVV = document.getElementById('cc-cvv');
        if (!ccCVV.value.trim()) {
            showError(ccCVV, 'CVV is required');
            valid = false;
        } else if (!validateCVV(ccCVV.value)) {
            showError(ccCVV, 'Please enter a valid CVV (3-4 digits)');
            valid = false;
        } else {
            clearError(ccCVV);
        }

        return valid;
    }

    function validateDebitCardFields() {
        let valid = true;

        // Validate name on card
        const dcName = document.getElementById('dc-name');
        if (!dcName.value.trim()) {
            showError(dcName, 'Name on card is required');
            valid = false;
        } else {
            clearError(dcName);
        }

        // Validate card number
        const dcNumber = document.getElementById('dc-number');
        const cardNumber = dcNumber.value.replace(/\s/g, '');
        if (!cardNumber) {
            showError(dcNumber, 'Card number is required');
            valid = false;
        } else if (!validateCreditCardNumber(cardNumber)) {
            showError(dcNumber, 'Please enter a valid card number');
            valid = false;
        } else {
            clearError(dcNumber);
        }

        // Validate expiry date
        const dcExpiry = document.getElementById('dc-expiry');
        if (!dcExpiry.value.trim()) {
            showError(dcExpiry, 'Expiry date is required');
            valid = false;
        } else if (!validateExpiryDate(dcExpiry.value)) {
            showError(dcExpiry, 'Please enter a valid expiry date (MM/YY)');
            valid = false;
        } else {
            clearError(dcExpiry);
        }

        // Validate CVV
        const dcCVV = document.getElementById('dc-cvv');
        if (!dcCVV.value.trim()) {
            showError(dcCVV, 'CVV is required');
            valid = false;
        } else if (!validateCVV(dcCVV.value)) {
            showError(dcCVV, 'Please enter a valid CVV (3-4 digits)');
            valid = false;
        } else {
            clearError(dcCVV);
        }

        return valid;
    }

    function validateNetBankingFields() {
        let valid = true;

        // Validate bank selection
        const bankName = document.getElementById('bank-name');
        if (!bankName.value) {
            showError(bankName, 'Please select a bank');
            valid = false;
        } else {
            clearError(bankName);
        }

        return valid;
    }

    function validateDigitalWalletFields() {
        let valid = true;

        // Validate wallet selection
        const walletType = document.getElementById('wallet-type');
        if (!walletType.value) {
            showError(walletType, 'Please select a wallet');
            valid = false;
        } else {
            clearError(walletType);
        }

        // Validate email address
        const walletEmail = document.getElementById('wallet-email');
        if (!walletEmail.value.trim()) {
            showError(walletEmail, 'Email address is required');
            valid = false;
        } else if (!validateEmail(walletEmail.value)) {
            showError(walletEmail, 'Please enter a valid email address');
            valid = false;
        } else {
            clearError(walletEmail);
        }

        return valid;
    }

    // Helper validation functions
    function validateCreditCardNumber(number) {
        // Basic validation - must be 13-19 digits
        return /^\d{13,19}$/.test(number);
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

    function validateEmail(email) {
        return /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/.test(email);
    }

    // Error handling functions
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
});
</script>

<jsp:include page="/views/common/footer.jsp" />