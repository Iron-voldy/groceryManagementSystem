package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Payment;
import com.grocerymanagement.model.Order;
import com.grocerymanagement.util.FileHandlerUtil;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class PaymentDAO {
    private String paymentFilePath;
    private OrderDAO orderDAO;

    public PaymentDAO(FileInitializationUtil fileInitUtil, OrderDAO orderDAO) {
        this.paymentFilePath = fileInitUtil.getDataFilePath("payments.txt");
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
}