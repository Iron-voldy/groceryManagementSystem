<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Checkout" />
    <jsp:param name="active" value="cart" />
    <jsp:param name="scripts" value="checkout" />
</jsp:include>

<div class="checkout-container">
    <h1 class="page-title">Checkout</h1>

    <div class="checkout-layout">
        <div class="checkout-main">
            <form id="checkout-form" action="${pageContext.request.contextPath}/order/create" method="post" data-validate="true">
                <!-- Personal Information -->
                <div class="checkout-section">
                    <h2 class="section-title">Personal Information</h2>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="first-name">First Name</label>
                            <input type="text" id="first-name" name="firstName" required>
                        </div>

                        <div class="form-group">
                            <label for="last-name">Last Name</label>
                            <input type="text" id="last-name" name="lastName" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" required>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone</label>
                            <input type="tel" id="phone" name="phone" required>
                        </div>
                    </div>
                </div>

                <!-- Billing Address -->
                <div class="checkout-section">
                    <h2 class="section-title">Billing Address</h2>

                    <div class="form-group">
                        <label for="billing-address">Street Address</label>
                        <input type="text" id="billing-address" name="billingAddress" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="billing-city">City</label>
                            <input type="text" id="billing-city" name="billingCity" required>
                        </div>

                        <div class="form-group">
                            <label for="billing-state">State/Province</label>
                            <input type="text" id="billing-state" name="billingState" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="billing-zip">Zip/Postal Code</label>
                            <input type="text" id="billing-zip" name="billingZip" required>
                        </div>

                        <div class="form-group">
                            <label for="billing-country">Country</label>
                            <select id="billing-country" name="billingCountry" required>
                                <option value="">Select Country</option>
                                <option value="US">United States</option>
                                <option value="CA">Canada</option>
                                <option value="UK">United Kingdom</option>
                                <!-- Add more countries as needed -->
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="checkbox-container">
                            <input type="checkbox" id="same-address" name="sameAsShipping" checked>
                            <label for="same-address">Shipping address same as billing</label>
                        </div>
                    </div>
                </div>

                <!-- Shipping Address (initially hidden) -->
                <div class="checkout-section shipping-address-section" style="display: none;">
                    <h2 class="section-title">Shipping Address</h2>

                    <div class="form-group">
                        <label for="shipping-address">Street Address</label>
                        <input type="text" id="shipping-address" name="shippingAddress">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="shipping-city">City</label>
                            <input type="text" id="shipping-city" name="shippingCity">
                        </div>

                        <div class="form-group">
                            <label for="shipping-state">State/Province</label>
                            <input type="text" id="shipping-state" name="shippingState">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="shipping-zip">Zip/Postal Code</label>
                            <input type="text" id="shipping-zip" name="shippingZip">
                        </div>

                        <div class="form-group">
                            <label for="shipping-country">Country</label>
                            <select id="shipping-country" name="shippingCountry">
                                <option value="">Select Country</option>
                                <option value="US">United States</option>
                                <option value="CA">Canada</option>
                                <option value="UK">United Kingdom</option>
                                <!-- Add more countries as needed -->
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Payment Method -->
                <div class="checkout-section">
                    <h2 class="section-title">Payment Method</h2>

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
                            <input type="text" id="cc-name" name="ccName">
                        </div>

                        <div class="form-group">
                            <label for="cc-number">Card Number</label>
                            <input type="text" id="cc-number" name="ccNumber" placeholder="1234 5678 9012 3456">
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

                    <div class="payment-method-form net-banking-form" style="display: none;">
                        <!-- Net Banking form fields -->
                        <div class="form-group">
                            <label for="bank-name">Select Bank</label>
                            <select id="bank-name" name="bankName">
                                <option value="">Select your bank</option>
                                <option value="bank1">Bank 1</option>
                                <option value="bank2">Bank 2</option>
                                <option value="bank3">Bank 3</option>
                                <!-- Add more banks as needed -->
                            </select>
                        </div>
                    </div>

                    <div class="payment-method-form digital-wallet-form" style="display: none;">
                        <!-- Digital Wallet form fields -->
                        <div class="form-group">
                            <label for="wallet-type">Select Wallet</label>
                            <select id="wallet-type" name="walletType">
                                <option value="">Select your wallet</option>
                                <option value="paypal">PayPal</option>
                                <option value="applepay">Apple Pay</option>
                                <option value="googlepay">Google Pay</option>
                                <!-- Add more wallets as needed -->
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="wallet-email">Email Address</label>
                            <input type="email" id="wallet-email" name="walletEmail" placeholder="you@example.com">
                        </div>
                    </div>
                </div>

                <!-- Order Review Section -->
                <div class="checkout-section">
                    <h2 class="section-title">Order Review</h2>

                    <div class="order-items">
                        <c:forEach var="item" items="${cart.items}" varStatus="status">
                            <c:set var="product" value="${cartProducts[status.index]}" />
                            <div class="order-item">
                                <div class="order-item-details">
                                    <div class="order-item-image">
                                        <!-- Product image placeholder -->
                                        <div class="product-img-placeholder">
                                            <c:choose>
                                                <c:when test="${product.category == 'Fresh Products'}">🥩</c:when>
                                                <c:when test="${product.category == 'Dairy'}">🥛</c:when>
                                                <c:when test="${product.category == 'Vegetables'}">🥦</c:when>
                                                <c:when test="${product.category == 'Fruits'}">🍎</c:when>
                                                <c:when test="${product.category == 'Pantry Items'}">🥫</c:when>
                                                <c:otherwise>🛒</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="order-item-info">
                                        <h3 class="order-item-name">${product.name}</h3>
                                        <p class="order-item-price">$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/> x ${item.quantity}</p>
                                    </div>
                                </div>
                                <div class="order-item-total">
                                    $<fmt:formatNumber value="${item.price.multiply(java.math.BigDecimal.valueOf(item.quantity))}" pattern="#,##0.00"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="checkout-actions">
                    <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-secondary">Back to Cart</a>
                    <button type="submit" class="btn btn-primary">Place Order</button>
                </div>
            </form>
        </div>

        <div class="checkout-sidebar">
            <div class="order-summary">
                <h2 class="summary-title">Order Summary</h2>

                <div class="summary-section">
                    <div class="summary-item">
                        <span>Subtotal (${cart.items.size()} items)</span>
                        <span class="cart-subtotal">$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></span>
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
                        <span class="order-total">$<fmt:formatNumber value="${orderTotal}" pattern="#,##0.00"/></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.checkout-container {
    padding: 20px 0;
}

.page-title {
    margin-bottom: 30px;
    color: var(--dark-text);
}

.checkout-layout {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.checkout-main {
    flex: 2;
    min-width: 300px;
}

.checkout-sidebar {
    flex: 1;
    min-width: 250px;
}

.checkout-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.section-title {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.form-row {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.form-row .form-group {
    flex: 1;
    min-width: 200px;
}

.form-group {
    margin-bottom: 20px;
}

.checkbox-container {
    display: flex;
    align-items: center;
}

.checkbox-container input[type="checkbox"] {
    width: auto;
    margin-right: 10px;
}

.payment-methods {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-bottom: 20px;
}

.payment-method {
    flex: 1;
    min-width: 100px;
    display: flex;
    align-items: center;
    padding: 15px;
    border-radius: var(--border-radius);
    background-color: var(--dark-surface-hover);
    cursor: pointer;
    transition: var(--transition);
}

.payment-method:hover {
    background-color: var(--dark-surface-hover);
}

.payment-method input[type="radio"] {
    margin-right: 10px;
}

.payment-method-form {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px dashed #333;
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

.summary-section {
    margin-bottom: 20px;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
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

.order-items {
    margin-top: 20px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #333;
}

.order-item:last-child {
    border-bottom: none;
}

.order-item-details {
    display: flex;
    align-items: center;
}

.order-item-image {
    width: 50px;
    height: 50px;
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 15px;
}

.product-img-placeholder {
    font-size: 1.5rem;
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

.checkout-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 30px;
}

@media (max-width: 768px) {
    .form-row {
        flex-direction: column;
        gap: 0;
    }

    .checkout-actions {
        flex-direction: column-reverse;
        gap: 15px;
    }

    .checkout-actions .btn {
        width: 100%;
    }

    .order-summary-toggle {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px;
        background-color: var(--dark-surface);
        border-radius: var(--border-radius);
        margin-bottom: 15px;
        cursor: pointer;
    }

    .order-summary {
        display: none;
    }

    .order-summary.show-summary {
        display: block;
    }
}
</style>

<jsp:include page="/views/common/footer.jsp">
    <jsp:param name="scripts" value="checkout" />
</jsp:include>
                            <div class="form-group">
                                <label for="cc-expiry">Expiry Date</label>
                                <input type="text" id="cc-expiry" name="ccExpiry" placeholder="MM/YY">
                            </div>

                            <div class="form-group">
                                <label for="cc-cvv">CVV</label>
                                <input type="text" id="cc-cvv" name="ccCvv" placeholder="123">
                            </div>
                        </div>
                    </div>

                    <!-- Other payment method forms (initially hidden) -->
                    <div class="payment-method-form debit-card-form" style="display: none;">
                        <!-- Debit Card form fields -->
                        <div class="form-group">
                            <label for="dc-name">Name on Card</label>
                            <input type="text" id="dc-name" name="dcName">
                        </div>

                        <div class="form-group">
                            <label for="dc-number">Card Number</label>
                            <input type="text" id="dc-number" name="dcNumber" placeholder="1234 5678 9012 3456">
                        </div>

                        <div class="form-row">