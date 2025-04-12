package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Transaction;
import com.grocerymanagement.util.FileHandlerUtil;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class TransactionDAO {
    private String transactionFilePath;

    public TransactionDAO(FileInitializationUtil fileInitUtil) {
        this.transactionFilePath = fileInitUtil.getDataFilePath("transactions.txt");
    }

    public boolean createTransaction(Transaction transaction) {
        if (!validateTransaction(transaction)) {
            return false;
        }

        FileHandlerUtil.writeToFile(transactionFilePath, transaction.toFileString(), true);
        return true;
    }

    public Optional<Transaction> getTransactionById(String transactionId) {
        return FileHandlerUtil.readFromFile(transactionFilePath).stream()
                .map(Transaction::fromFileString)
                .filter(transaction -> transaction.getTransactionId().equals(transactionId))
                .findFirst();
    }

    public Optional<Transaction> getTransactionByOrderId(String orderId) {
        return FileHandlerUtil.readFromFile(transactionFilePath).stream()
                .map(Transaction::fromFileString)
                .filter(transaction -> transaction.getOrderId().equals(orderId))
                .findFirst();
    }

    public List<Transaction> getTransactionsByStatus(Transaction.TransactionStatus status) {
        return FileHandlerUtil.readFromFile(transactionFilePath).stream()
                .map(Transaction::fromFileString)
                .filter(transaction -> transaction.getStatus() == status)
                .collect(Collectors.toList());
    }

    public List<Transaction> getAllTransactions() {
        return FileHandlerUtil.readFromFile(transactionFilePath).stream()
                .map(Transaction::fromFileString)
                .collect(Collectors.toList());
    }

    public boolean updateTransaction(Transaction updatedTransaction) {
        List<String> lines = FileHandlerUtil.readFromFile(transactionFilePath);
        boolean transactionFound = false;

        for (int i = 0; i < lines.size(); i++) {
            Transaction existingTransaction = Transaction.fromFileString(lines.get(i));
            if (existingTransaction.getTransactionId().equals(updatedTransaction.getTransactionId())) {
                lines.set(i, updatedTransaction.toFileString());
                transactionFound = true;
                break;
            }
        }

        if (transactionFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(transactionFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating transaction: " + e.getMessage());
                return false;
            }
        }

        return transactionFound;
    }

    public boolean deleteTransaction(String transactionId) {
        List<String> lines = FileHandlerUtil.readFromFile(transactionFilePath);
        boolean transactionRemoved = lines.removeIf(line -> {
            Transaction transaction = Transaction.fromFileString(line);
            return transaction.getTransactionId().equals(transactionId);
        });

        if (transactionRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(transactionFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting transaction: " + e.getMessage());
                return false;
            }
        }

        return transactionRemoved;
    }

    private boolean validateTransaction(Transaction transaction) {
        return transaction.getOrderId() != null && !transaction.getOrderId().isEmpty() &&
                transaction.getAmount() != null && transaction.getAmount().compareTo(BigDecimal.ZERO) > 0 &&
                transaction.getPaymentMethod() != null;
    }
}

