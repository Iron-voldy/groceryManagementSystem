package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class Transaction implements Serializable {
    private String transactionId;
    private String orderId;
    private BigDecimal amount;
    private PaymentMethod paymentMethod;
    private TransactionStatus status;
    private LocalDateTime transactionDate;

    public enum PaymentMethod {
        CREDIT_CARD, DEBIT_CARD, NET_BANKING, DIGITAL_WALLET
    }

    public enum TransactionStatus {
        PENDING, SUCCESSFUL, FAILED, REFUNDED
    }

    public Transaction() {
        this.transactionId = UUID.randomUUID().toString();
        this.transactionDate = LocalDateTime.now();
    }

    public Transaction(String orderId, BigDecimal amount, PaymentMethod paymentMethod) {
        this();
        this.orderId = orderId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = TransactionStatus.PENDING;
    }

    // Getters and setters
    public String getTransactionId() { return transactionId; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }
    public TransactionStatus getStatus() { return status; }
    public void setStatus(TransactionStatus status) { this.status = status; }
    public LocalDateTime getTransactionDate() { return transactionDate; }

    public String toFileString() {
        return String.join("|",
                transactionId,
                orderId,
                amount.toString(),
                paymentMethod.name(),
                status.name(),
                transactionDate.toString()
        );
    }

    public static Transaction fromFileString(String line) {
        String[] parts = line.split("\\|");
        Transaction transaction = new Transaction();
        transaction.transactionId = parts[0];
        transaction.orderId = parts[1];
        transaction.amount = new BigDecimal(parts[2]);
        transaction.paymentMethod = PaymentMethod.valueOf(parts[3]);
        transaction.status = TransactionStatus.valueOf(parts[4]);
        transaction.transactionDate = LocalDateTime.parse(parts[5]);
        return transaction;
    }
}
