<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Payment Checkout" />
    <jsp:param name="active" value="cart" />
</jsp:include>

<div class="payment-checkout-container">
    <h1 class="page-title">Complete Your Payment</h1>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="checkout-layout">
        <div class="checkout-main">
            <form id="payment-form" action="${pageContext.request.contextPath}/payment/process" method="post">
                <!-- Order Summary -->
                <div class="checkout-section">
                    <h2 class="section-title">Order Summary</h2>
                    <div class="order-items">
                        <c:forEach var="item" items="${pendingOrder.items}">
                            <div class="order-item">
                                <div class="item-details">
                                    <span class="item-name">${item.productName}</span>
                                    <span class="item-quantity">x ${item.quantity}</span>
                                </div>
                                <div class="item-price">
                                    $<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Saved Cards or New Card -->
                <div class="checkout-section">
                    <h2 class="section-title">Payment Method</h2>

                    <div class="payment-method-selection">
                        <div class="tabs">
                            <button type="button" class="tab-btn active" data-tab="new-card">New Card</button>
                            <c:if test="${not empty savedCards}">
                                <button type="button" class="tab-btn" data-tab="saved-cards">Saved Cards</button>
                            </c:if>
                        </div>

                        <div class="tab-content">
                            <!-- New Card Form -->
                            <div class="tab-pane active" id="new-card">
                                <div class="form-group">
                                    <label for="cardNumber">Card Number</label>
                                    <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" required>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="cardHolderName">Cardholder Name</label>
                                        <input type="text" id="cardHolderName" name="cardHolderName" placeholder="John Doe" required>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="expiryDate">Expiry Date</label>
                                        <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="cvv">CVV</label>
                                        <input type="password" id="cvv" name="cvv" placeholder="123" required>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="paymentMethod">Payment Type</label>
                                    <select id="paymentMethod" name="paymentMethod" required>
                                        <option value="CREDIT_CARD">Credit Card</option>
                                        <option value="DEBIT_CARD">Debit Card</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <div class="checkbox-container">
                                        <input type="checkbox" id="saveCard" name="saveCard">
                                        <label for="saveCard">Save this card for future purchases</label>
                                    </div>
                                </div>
                            </div>

                            <!-- Saved Cards -->
                            <c:if test="${not empty savedCards}">
                                <div class="tab-pane" id="saved-cards">
                                    <div class="saved-cards">
                                        <c:forEach var="card" items="${savedCards}">
                                            <div class="saved-card">
                                                <input type="radio" name="savedCardId" id="card-${card.cardId}" value="${card.cardId}">
                                                <label for="card-${card.cardId}" class="card-label">
                                                    <div class="card-info">
                                                        <div class="card-type">${card.paymentMethod}</div>
                                                        <div class="card-number">${card.cardNumber}</div>
                                                        <div class="card-name">${card.cardHolderName}</div>
                                                        <div class="card-expiry">Expires: ${card.expiryDate}</div>
                                                    </div>
                                                </label>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Billing Address -->
                <div class="checkout-section">
                    <h2 class="section-title">Billing Address</h2>

                    <div class="form-group">
                        <label for="billingAddress">Street Address</label>
                        <input type="text" id="billingAddress" name="billingAddress" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="billingCity">City</label>
                            <input type="text" id="billingCity" name="billingCity" required>
                        </div>

                        <div class="form-group">
                            <label for="billingState">State/Province</label>
                            <input type="text" id="billingState" name="billingState" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="billingZip">Zip/Postal Code</label>
                            <input type="text" id="billingZip" name="billingZip" required>
                        </div>

                        <div class="form-group">
                            <label for="billingCountry">Country</label>
                            <select id="billingCountry" name="billingCountry" required>
                                <option value="">Select Country</option>
                                <option value="US">United States</option>
                                <option value="CA">Canada</option>
                                <option value="UK">United Kingdom</option>
                                <option value="AU">Australia</option>
                                <!-- Add more countries as needed -->
                            </select>
                        </div>
                    </div>
                </div>

                <div class="checkout-actions">
                    <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-secondary">Back to Cart</a>
                    <button type="submit" class="btn btn-primary">Complete Payment</button>
                </div>
            </form>
        </div>

        <div class="checkout-sidebar">
            <div class="order-summary">
                <h2 class="summary-title">Payment Summary</h2>

                <div class="summary-section">
                    <div class="summary-item">
                        <span>Subtotal</span>
                        <span>$<fmt:formatNumber value="${subtotal}" pattern="#,##0.00"/></span>
                    </div>

                    <div class="summary-item">
                        <span>Tax</span>
                        <span>$<fmt:formatNumber value="${taxAmount}" pattern="#,##0.00"/></span>
                    </div>

                    <div class="summary-item">
                        <span>Shipping</span>
                        <span>$<fmt:formatNumber value="${shippingCost}" pattern="#,##0.00"/></span>
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
.payment-checkout-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.page-title {
    margin-bottom: 30px;
    color: var(--primary-color);
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

.order-items {
    margin-bottom: 20px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    padding-bottom: 15px;
    border-bottom: 1px dashed #333;
}

.order-item:last-child {
    border-bottom: none;
}

.item-details {
    display: flex;
    flex-direction: column;
}

.item-name {
    font-weight: 600;
    margin-bottom: 5px;
}

.item-quantity {
    color: var(--light-text);
    font-size: 0.9em;
}

.tabs {
    display: flex;
    margin-bottom: 20px;
    border-bottom: 1px solid #333;
}

.tab-btn {
    padding: 10px 20px;
    background: none;
    border: none;
    cursor: pointer;
    color: var(--light-text);
    border-bottom: 3px solid transparent;
    transition: var(--transition);
}

.tab-btn.active {
    color: var(--primary-color);
    border-bottom-color: var(--primary-color);
}

.tab-pane {
    display: none;
}

.tab-pane.active {
    display: block;
}

.form-row {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.form-group {
    margin-bottom: 20px;
    flex: 1;
    min-width: 200px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    color: var(--light-text);
}

.form-group input,
.form-group select {
    width: 100%;
    padding: 12px;
    border: 1px solid #333;
    border-radius: var(--border-radius);
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
}

.checkbox-container {
    display: flex;
    align-items: center;
}

.checkbox-container input[type="checkbox"] {
    width: auto;
    margin-right: 10px;
}

.saved-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
}

.saved-card {
    position: relative;
}

.saved-card input[type="radio"] {
    position: absolute;
    opacity: 0;
}

.card-label {
        display: block;
        padding: 15px;
        border: 1px solid #333;
        border-radius: var(--border-radius);
        cursor: pointer;
        transition: var(--transition);
    }

    .saved-card input[type="radio"]:checked + .card-label {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 1px var(--primary-color);
    }

    .card-info {
        display: flex;
        flex-direction: column;
        gap: 5px;
    }

    .card-type {
        font-weight: bold;
        color: var(--primary-color);
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

    .checkout-actions {
        display: flex;
        justify-content: space-between;
        margin-top: 20px;
    }

    .alert {
        padding: 15px;
        border-radius: var(--border-radius);
        margin-bottom: 20px;
    }

    .alert-danger {
        background-color: rgba(244, 67, 54, 0.1);
        color: #F44336;
        border: 1px solid #F44336;
    }

    @media (max-width: 768px) {
        .checkout-layout {
            flex-direction: column;
        }

        .form-row {
            flex-direction: column;
            gap: 0;
        }

        .checkout-actions {
            flex-direction: column;
            gap: 10px;
        }

        .checkout-actions .btn {
            width: 100%;
        }

        .tabs {
            overflow-x: auto;
            white-space: nowrap;
        }
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Tab switching
        const tabButtons = document.querySelectorAll('.tab-btn');
        const tabPanes = document.querySelectorAll('.tab-pane');

        tabButtons.forEach(button => {
            button.addEventListener('click', function() {
                // Remove active class from all buttons and panes
                tabButtons.forEach(btn => btn.classList.remove('active'));
                tabPanes.forEach(pane => pane.classList.remove('active'));

                // Add active class to current button and its corresponding pane
                this.classList.add('active');
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Card number formatting (add spaces every 4 digits)
        const cardNumberInput = document.getElementById('cardNumber');
        if (cardNumberInput) {
            cardNumberInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, ''); // Remove non-digits
                let formatted = '';

                for (let i = 0; i < value.length; i++) {
                    if (i > 0 && i % 4 === 0) {
                        formatted += ' ';
                    }
                    formatted += value[i];
                }

                e.target.value = formatted;
            });
        }

        // Expiry date formatting (MM/YY)
        const expiryDateInput = document.getElementById('expiryDate');
        if (expiryDateInput) {
            expiryDateInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, ''); // Remove non-digits

                if (value.length > 2) {
                    e.target.value = value.substring(0, 2) + '/' + value.substring(2, 4);
                } else {
                    e.target.value = value;
                }
            });
        }

        // Form validation
        const paymentForm = document.getElementById('payment-form');
        if (paymentForm) {
            paymentForm.addEventListener('submit', function(e) {
                const newCardTab = document.getElementById('new-card');
                const savedCardsTab = document.getElementById('saved-cards');

                // If new card tab is active, validate card details
                if (newCardTab && newCardTab.classList.contains('active')) {
                    const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
                    const expiryDate = document.getElementById('expiryDate').value;
                    const cvv = document.getElementById('cvv').value;

                    // Basic validation
                    if (cardNumber.length < 13 || cardNumber.length > 19) {
                        alert('Please enter a valid card number');
                        e.preventDefault();
                        return;
                    }

                    if (!expiryDate.match(/^\d{2}\/\d{2}$/)) {
                        alert('Please enter a valid expiry date (MM/YY)');
                        e.preventDefault();
                        return;
                    }

                    if (cvv.length < 3 || cvv.length > 4) {
                        alert('Please enter a valid CVV');
                        e.preventDefault();
                        return;
                    }
                } else if (savedCardsTab && savedCardsTab.classList.contains('active')) {
                    // Check if a saved card is selected
                    const selectedCard = document.querySelector('input[name="savedCardId"]:checked');
                    if (!selectedCard) {
                        alert('Please select a saved card');
                        e.preventDefault();
                        return;
                    }
                }
            });
        }
    });
</script>