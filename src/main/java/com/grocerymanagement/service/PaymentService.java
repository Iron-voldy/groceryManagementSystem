package com.grocerymanagement.service;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dto.PaymentDetails;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Payment;
import com.grocerymanagement.util.FileHandlerUtil;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class PaymentService {
    private String paymentFilePath;
    private OrderDAO orderDAO;

    public PaymentService(FileInitializationUtil fileInitUtil, OrderDAO orderDAO) {
        this.paymentFilePath = fileInitUtil.getDataFilePath("payments.txt");
        this.orderDAO = orderDAO;
    }

    public Payment processPayment(Order order, PaymentDetails paymentDetails) {
        // Validate payment details
        if (paymentDetails == null || !paymentDetails.isValid()) {
            throw new PaymentException("Invalid payment details");
        }

        // Create payment
        Payment payment = new Payment(
                order,
                order.getTotalAmount(),
                paymentDetails.getPaymentMethod()
        );

        try {
            // Simulate payment processing
            // In a real-world scenario, this would interact with a payment gateway
            if (validatePayment(payment)) {
                payment.setStatus(Payment.PaymentStatus.SUCCESSFUL);
                order.setStatus(Order.OrderStatus.PROCESSING);
            } else {
                payment.setStatus(Payment.PaymentStatus.FAILED);
                order.setStatus(Order.OrderStatus.CANCELLED);
            }

            // Update order status
            orderDAO.updateOrder(order);

            // Save payment
            savePayment(payment);

            return payment;
        } catch (Exception e) {
            payment.setStatus(Payment.PaymentStatus.FAILED);
            throw new PaymentException("Payment processing failed: " + e.getMessage());
        }
    }

    private boolean validatePayment(Payment payment) {
        // Simulate payment validation
        // In a real system, this would involve complex validation and gateway integration
        return payment.getAmount().compareTo(BigDecimal.ZERO) > 0;
    }

    private void savePayment(Payment payment) {
        FileHandlerUtil.writeToFile(
                paymentFilePath,
                payment.toFileString(),
                true
        );
    }

    public Optional<Payment> getPaymentByOrderId(String orderId) {
        return FileHandlerUtil.readFromFile(paymentFilePath).stream()
                .map(line -> {
                    Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
                    return orderOptional.map(order -> Payment.fromFileString(line, order));
                })
                .filter(Optional::isPresent)
                .map(Optional::get)
                .findFirst();
    }

    public List<Payment> getAllPayments() {
        return FileHandlerUtil.readFromFile(paymentFilePath).stream()
                .map(line -> {
                    String orderId = line.split("\\|")[1];
                    Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
                    return orderOptional.map(order -> Payment.fromFileString(line, order));
                })
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());
    }
}

// Custom Exception for Payment-related errors
class PaymentException extends RuntimeException {
    public PaymentException(String message) {
        super(message);
    }
}