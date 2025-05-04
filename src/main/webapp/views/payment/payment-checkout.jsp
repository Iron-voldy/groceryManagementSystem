<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Checkout" />
</jsp:include>

<div class="container checkout">
    <div class="checkout-container">
        <div class="order-summary">
            <h2>Order Summary</h2>
            <div class="summary-items">
                <c:forEach var="item" items="${sessionScope.pendingOrder.items}">
                    <div class="summary-item">
                        <span class="item-name">${item.productName}</span>
                        <span class="item-quantity">Qty: ${item.quantity}</span>
                        <span class="item-price">
                            $<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                        </span>
                    </div>
                </c:forEach>
            </div>
            <div class="summary-total">
                <span>Total</span>
                <span>
                    $<fmt:formatNumber value="${sessionScope.pendingOrder.totalAmount}" pattern="#,##0.00"/>
                </span>
            </div>
        </div>

        <div class="payment-form">
            <h2>Payment Details</h2>
            <form action="${pageContext.request.contextPath}/order/payment" method="post">
                <div class="form-group">
                    <label for="paymentMethod">Payment Method</label>
                    <select id="paymentMethod" name="paymentMethod" required>
                        <option value="CREDIT_CARD">Credit Card</option>
                        <option value="DEBIT_CARD">Debit Card</option>
                        <option value="NET_BANKING">Net Banking</option>
                        <option value="DIGITAL_WALLET">Digital Wallet</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="cardNumber">Card Number</label>
                    <input type="text" id="cardNumber" name="cardNumber"
                           placeholder="1234 5678 9012 3456" required>
                </div>

                <div class="form-group">
                    <label for="cardHolderName">Card Holder Name</label>
                    <input type="text" id="cardHolderName" name="cardHolderName"
                           placeholder="John Doe" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="expiryDate">Expiry Date</label>
                        <input type="text" id="expiryDate" name="expiryDate"
                               placeholder="MM/YY" required
                               pattern="(0[1-9]|1[0-2])/\d{2}">
                    </div>

                    <div class="form-group">
                        <label for="cvv">CVV</label>
                        <input type="text" id="cvv" name="cvv"
                               placeholder="123" required
                               pattern="\d{3}">
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Pay Now</button>
                    <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
.checkout {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 70vh;
    padding: 20px;
}

.checkout-container {
    display: flex;
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    box-shadow: var(--card-shadow);
    max-width: 900px;
    width: 100%;
}

.order-summary, .payment-form {
    flex: 1;
    padding: 30px;
}

.order-summary {
    background-color: var(--dark-surface-hover);
    border-top-left-radius: var(--border-radius);
    border-bottom-left-radius: var(--border-radius);
}

.summary-items {
    margin-bottom: 20px;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid var(--dark-surface);
}

.summary-total {
    display: flex;
    justify-content: space-between;
    font-weight: bold;
}

.payment-form {
    background-color: var(--dark-surface);
}

.form-group {
    margin-bottom: 15px;
}

.form-row {
    display: flex;
    gap: 15px;
}

.form-row .form-group {
    flex: 1;
}

label {
    display: block;
    margin-bottom: 5px;
    color: var(--light-text);
}

input, select {
    width: 100%;
    padding: 10px;
    border: 1px solid var(--dark-surface-hover);
    background-color: var(--dark-surface-hover);
    color: var(--dark-text);
    border-radius: var(--border-radius);
}

.form-actions {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
}

@media (max-width: 768px) {
    .checkout-container {
        flex-direction: column;
    }

    .order-summary, .payment-form {
        border-radius: 0;
    }

    .form-row {
        flex-direction: column;
        gap: 15px;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('form');
    const cardNumberInput = document.getElementById('cardNumber');
    const expiryDateInput = document.getElementById('expiryDate');
    const cvvInput = document.getElementById('cvv');

    // Card number formatting
    cardNumberInput.addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, '');
        value = value.replace(/(.{4})/g, '$1 ').trim();
        e.target.value = value;
    });

    // Expiry date formatting
    expiryDateInput.addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, '');
        if (value.length > 2) {
            value = value.slice(0, 2) + '/' + value.slice(2);
        }
        e.target.value = value;
    });

    // Form validation
    form.addEventListener('submit', function(e) {
        // Validate card number
        const cardNumber = cardNumberInput.value.replace(/\s/g, '');
        if (!/^\d{16}$/.test(cardNumber)) {
            e.preventDefault();
            alert('Please enter a valid 16-digit card number');
            return;
        }

        // Validate expiry date
        const expiryDate = expiryDateInput.value;
        if (!/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiryDate)) {
            e.preventDefault();
            alert('Please enter a valid expiry date (MM/YY)');
            return;
        }

        // Validate CVV
        const cvv = cvvInput.value;
        if (!/^\d{3}$/.test(cvv)) {
            e.preventDefault();
            alert('Please enter a valid 3-digit CVV');
            return;
        }
    });
});
</script>

<jsp:include page="/views/common/footer.jsp" />