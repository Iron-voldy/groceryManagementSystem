package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dto.PaymentDetails;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.Payment;
import com.grocerymanagement.util.FileHandlerUtil;
import com.grocerymanagement.util.SecurityUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

public class PaymentDAO {
    private String paymentFilePath;
    private String savedCardsFilePath;
    private OrderDAO orderDAO;

    public PaymentDAO(FileInitializationUtil fileInitUtil, OrderDAO orderDAO) {
        this.paymentFilePath = fileInitUtil.getDataFilePath("payments.txt");
        this.savedCardsFilePath = fileInitUtil.getDataFilePath("saved_cards.txt");
        this.orderDAO = orderDAO;
    }

    public boolean createPayment(Payment payment) {
        if (payment == null || payment.getOrder() == null) {
            return false;
        }

        FileHandlerUtil.writeToFile(paymentFilePath, payment.toFileString(), true);
        return true;
    }

    public Optional<Payment> getPaymentByOrderId(String orderId) {
        return FileHandlerUtil.readFromFile(paymentFilePath).stream()
                .filter(line -> line.split("\\|")[1].equals(orderId))
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

    public List<Payment> getPaymentsByStatus(Payment.PaymentStatus status) {
        return FileHandlerUtil.readFromFile(paymentFilePath).stream()
                .filter(line -> line.split("\\|")[4].equals(status.name()))
                .map(line -> {
                    String orderId = line.split("\\|")[1];
                    Optional<Order> orderOptional = orderDAO.getOrderById(orderId);
                    return orderOptional.map(order -> Payment.fromFileString(line, order));
                })
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());
    }

    // Save a payment card for a user
    public boolean saveCard(String userId, PaymentDetails paymentDetails) {
        if (userId == null || paymentDetails == null || !paymentDetails.isValid()) {
            return false;
        }

        // Generate a card ID
        String cardId = UUID.randomUUID().toString();

        // Encrypt sensitive card data
        String encryptedCardNumber = maskCardNumber(paymentDetails.getCardNumber());
        String encryptedCVV = SecurityUtil.hashPassword(paymentDetails.getCvv());

        // Create the card record
        String cardRecord = String.join("|",
                cardId,
                userId,
                encryptedCardNumber,
                paymentDetails.getCardHolderName(),
                paymentDetails.getExpiryDate(),
                encryptedCVV,
                paymentDetails.getPaymentMethod().name()
        );

        FileHandlerUtil.writeToFile(savedCardsFilePath, cardRecord, true);
        return true;
    }

    // Get saved cards for a user
    public List<PaymentDetails> getSavedCards(String userId) {
        List<PaymentDetails> savedCards = new ArrayList<>();

        if (userId == null) {
            return savedCards;
        }

        return FileHandlerUtil.readFromFile(savedCardsFilePath).stream()
                .filter(line -> {
                    String[] parts = line.split("\\|");
                    return parts.length >= 7 && parts[1].equals(userId);
                })
                .map(line -> {
                    String[] parts = line.split("\\|");

                    PaymentDetails card = new PaymentDetails(
                            parts[2], // Masked card number
                            parts[3], // Card holder name
                            parts[4], // Expiry date
                            "***", // CVV is never returned in clear text
                            Payment.PaymentMethod.valueOf(parts[6]) // Payment method
                    );

                    // Set card ID
                    return card;
                })
                .collect(Collectors.toList());
    }

    // Delete a saved card
    public boolean deleteCard(String userId, String cardId) {
        if (userId == null || cardId == null) {
            return false;
        }

        List<String> lines = FileHandlerUtil.readFromFile(savedCardsFilePath);

        boolean removed = lines.removeIf(line -> {
            String[] parts = line.split("\\|");
            return parts.length >= 2 &&
                    parts[0].equals(cardId) &&
                    parts[1].equals(userId);
        });

        if (removed) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(savedCardsFilePath)) {
                lines.forEach(writer::println);
                return true;
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting saved card: " + e.getMessage());
                return false;
            }
        }

        return false;
    }

    // Helper method to mask card numbers for security
    private String maskCardNumber(String cardNumber) {
        if (cardNumber == null || cardNumber.length() < 13) {
            return cardNumber;
        }

        // Remove any spaces
        cardNumber = cardNumber.replaceAll("\\s", "");

        // Mask all but the last 4 digits
        int length = cardNumber.length();
        StringBuilder masked = new StringBuilder();

        for (int i = 0; i < length - 4; i++) {
            masked.append("*");
        }

        masked.append(cardNumber.substring(length - 4));

        // Format as XXXX-XXXX-XXXX-1234
        StringBuilder formatted = new StringBuilder();
        for (int i = 0; i < masked.length(); i++) {
            if (i > 0 && i % 4 == 0) {
                formatted.append("-");
            }
            formatted.append(masked.charAt(i));
        }

        return formatted.toString();
    }
}