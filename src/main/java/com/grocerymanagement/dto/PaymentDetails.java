package com.grocerymanagement.dto;

import com.grocerymanagement.model.Payment;
import java.io.Serializable;

public class PaymentDetails implements Serializable {
    private String cardId; // Added this field
    private String cardNumber;
    private String cardHolderName;
    private String expiryDate;
    private String cvv;
    private Payment.PaymentMethod paymentMethod;

    // Constructors
    public PaymentDetails() {}

    public PaymentDetails(
            String cardNumber,
            String cardHolderName,
            String expiryDate,
            String cvv,
            Payment.PaymentMethod paymentMethod
    ) {
        this.cardNumber = cardNumber;
        this.cardHolderName = cardHolderName;
        this.expiryDate = expiryDate;
        this.cvv = cvv;
        this.paymentMethod = paymentMethod;
    }

    // Constructor with cardId
    public PaymentDetails(
            String cardId,
            String cardNumber,
            String cardHolderName,
            String expiryDate,
            String cvv,
            Payment.PaymentMethod paymentMethod
    ) {
        this.cardId = cardId;
        this.cardNumber = cardNumber;
        this.cardHolderName = cardHolderName;
        this.expiryDate = expiryDate;
        this.cvv = cvv;
        this.paymentMethod = paymentMethod;
    }

    // Getters and Setters
    public String getCardId() { return cardId; }
    public void setCardId(String cardId) { this.cardId = cardId; }

    public String getCardNumber() { return cardNumber; }
    public void setCardNumber(String cardNumber) { this.cardNumber = cardNumber; }

    public String getCardHolderName() { return cardHolderName; }
    public void setCardHolderName(String cardHolderName) { this.cardHolderName = cardHolderName; }

    public String getExpiryDate() { return expiryDate; }
    public void setExpiryDate(String expiryDate) { this.expiryDate = expiryDate; }

    public String getCvv() { return cvv; }
    public void setCvv(String cvv) { this.cvv = cvv; }

    public Payment.PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(Payment.PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    // Validation methods
    public boolean isValid() {
        return validateCardNumber() &&
                validateCardHolderName() &&
                validateExpiryDate() &&
                validateCVV();
    }

    private boolean validateCardNumber() {
        // Basic card number validation
        return cardNumber != null &&
                cardNumber.replaceAll("\\s", "").matches("\\d{16}");
    }

    private boolean validateCardHolderName() {
        return cardHolderName != null &&
                cardHolderName.trim().length() >= 3 &&
                cardHolderName.matches("^[a-zA-Z\\s]+$");
    }

    private boolean validateExpiryDate() {
        // Basic expiry date validation (MM/YY format)
        return expiryDate != null &&
                expiryDate.matches("(0[1-9]|1[0-2])/\\d{2}");
    }

    private boolean validateCVV() {
        return cvv != null && cvv.matches("\\d{3}");
    }
}