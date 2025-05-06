<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Saved Payment Methods" />
</jsp:include>

<div class="container">
    <h1 class="page-title">Saved Payment Methods</h1>

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="saved-cards-content">
        <div class="saved-cards-main">
            <!-- Display Saved Cards -->
            <div class="card-section">
                <h2>Your Saved Cards</h2>

                <c:choose>
                    <c:when test="${not empty savedCards}">
                        <div class="cards-grid">
                            <c:forEach var="card" items="${savedCards}">
                                <div class="card-item">
                                    <div class="card-type">${card.paymentMethod}</div>
                                    <div class="card-number">${card.cardNumber}</div>
                                    <div class="card-name">${card.cardHolderName}</div>
                                    <div class="card-expiry">Expires: ${card.expiryDate}</div>

                                    <div class="card-actions">
                                        <form action="${pageContext.request.contextPath}/payment/delete-card" method="post">
                                            <input type="hidden" name="cardId" value="${card.cardId}">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-cards-message">
                            <p>You don't have any saved payment methods yet.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Add New Card Form -->
            <div class="card-section">
                <h2>Add New Payment Method</h2>

                <form action="${pageContext.request.contextPath}/payment/save-card" method="post" id="add-card-form">
                    <div class="form-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" required>
                    </div>

                    <div class="form-group">
                        <label for="cardHolderName">Cardholder Name</label>
                        <input type="text" id="cardHolderName" name="cardHolderName" placeholder="John Doe" required>
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

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Save Card</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<style>
.container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
}

.page-title {
    margin-bottom: 30px;
    color: var(--primary-color);
}

.alert {
    padding: 15px;
    border-radius: var(--border-radius);
    margin-bottom: 20px;
}

.alert-success {
    background-color: rgba(76, 175, 80, 0.1);
    color: #4CAF50;
    border: 1px solid #4CAF50;
}

.alert-danger {
    background-color: rgba(244, 67, 54, 0.1);
    color: #F44336;
    border: 1px solid #F44336;
}

.saved-cards-content {
    display: flex;
    flex-direction: column;
    gap: 30px;
}

.card-section {
    background-color: var(--dark-surface);
    border-radius: var(--border-radius);
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: var(--card-shadow);
}

.card-section h2 {
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #333;
    color: var(--dark-text);
    font-size: 20px;
}

.cards-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.card-item {
    padding: 20px;
    border: 1px solid #333;
    border-radius: var(--border-radius);
    position: relative;
}

.card-type {
    font-weight: bold;
    color: var(--primary-color);
    margin-bottom: 10px;
}

.card-number {
    font-size: 18px;
    margin-bottom: 10px;
}

.card-name {
    color: var(--light-text);
    margin-bottom: 5px;
}

.card-expiry {
    color: var(--light-text);
    margin-bottom: 15px;
}

.card-actions {
    display: flex;
    justify-content: flex-end;
}

.no-cards-message {
    padding: 20px;
    background-color: var(--dark-surface-hover);
    border-radius: var(--border-radius);
    text-align: center;
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

.form-actions {
    margin-top: 30px;
}

.btn {
    display: inline-block;
    padding: 10px 20px;
    border-radius: var(--border-radius);
    border: none;
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    text-align: center;
}

.btn-primary {
    background-color: var(--primary-color);
    color: white;
}

.btn-primary:hover {
    background-color: var(--primary-dark);
}

.btn-danger {
    background-color: var(--danger);
    color: white;
}

.btn-danger:hover {
    background-color: #d32f2f;
}

.btn-sm {
    padding: 5px 10px;
    font-size: 0.9em;
}

@media (max-width: 768px) {
    .form-row {
        flex-direction: column;
        gap: 0;
    }

    .cards-grid {
        grid-template-columns: 1fr;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
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
    const addCardForm = document.getElementById('add-card-form');
    if (addCardForm) {
        addCardForm.addEventListener('submit', function(e) {
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
        });
    }

    // Confirm card deletion
    const deleteButtons = document.querySelectorAll('.card-actions form');
    deleteButtons.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!confirm('Are you sure you want to delete this payment method?')) {
                e.preventDefault();
            }
        });
    });
});
</script>