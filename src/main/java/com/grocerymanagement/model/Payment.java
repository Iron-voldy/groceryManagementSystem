package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class Payment implements Serializable {
    private String paymentId;
    private Order order;
    private BigDecimal amount;
    private PaymentMethod paymentMethod;
    private PaymentStatus status;
    private LocalDateTime paymentDate;

    public enum PaymentMethod {
        CREDIT_CARD,
        DEBIT_CARD,
        NET_BANKING,
        DIGITAL_WALLET
    }

    public enum PaymentStatus {
        PENDING,
        SUCCESSFUL,
        FAILED,
        REFUNDED
    }

    public Payment() {
        this.paymentId = UUID.randomUUID().toString();
        this.paymentDate = LocalDateTime.now();
        this.status = PaymentStatus.PENDING;
    }

    // Constructors
    public Payment(Order order, BigDecimal amount, PaymentMethod paymentMethod) {
        this();
        this.order = order;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
    }

    // Getters and Setters
    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public PaymentStatus getStatus() { return status; }
    public void setStatus(PaymentStatus status) { this.status = status; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    // Serialization methods
    public String toFileString() {
        return String.join("|",
                paymentId,
                order.getOrderId(),
                amount.toString(),
                paymentMethod.name(),
                status.name(),
                paymentDate.toString()
        );
    }

    public static Payment fromFileString(String line, Order order) {
        String[] parts = line.split("\\|");
        Payment payment = new Payment();
        payment.paymentId = parts[0];
        payment.order = order;
        payment.amount = new BigDecimal(parts[2]);
        payment.paymentMethod = PaymentMethod.valueOf(parts[3]);
        payment.status = PaymentStatus.valueOf(parts[4]);
        payment.paymentDate = LocalDateTime.parse(parts[5]);
        return payment;
    }
}