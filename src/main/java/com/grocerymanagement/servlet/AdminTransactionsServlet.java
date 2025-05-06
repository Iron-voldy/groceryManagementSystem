package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.TransactionDAO;
import com.grocerymanagement.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/admin/transactions")
public class AdminTransactionsServlet extends HttpServlet {
    private TransactionDAO transactionDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        transactionDAO = new TransactionDAO(fileInitUtil);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Transaction> transactions = transactionDAO.getAllTransactions();

        // Create stats object
        Map<String, Object> stats = new HashMap<>();

        // Calculate totals
        BigDecimal totalRevenue = transactions.stream()
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long successfulCount = transactions.stream()
                .filter(t -> t.getStatus() == Transaction.TransactionStatus.SUCCESSFUL)
                .count();

        long failedCount = transactions.stream()
                .filter(t -> t.getStatus() == Transaction.TransactionStatus.FAILED)
                .count();

        BigDecimal refundedAmount = transactions.stream()
                .filter(t -> t.getStatus() == Transaction.TransactionStatus.REFUNDED)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        stats.put("totalRevenue", totalRevenue);
        stats.put("successfulCount", successfulCount);
        stats.put("failedCount", failedCount);
        stats.put("refundedAmount", refundedAmount);

        // Calculate percentages
        stats.put("successfulPercentage", transactions.isEmpty() ? 0 :
                (int) ((double) successfulCount / transactions.size() * 100));
        stats.put("failedPercentage", transactions.isEmpty() ? 0 :
                (int) ((double) failedCount / transactions.size() * 100));

        // Create chart data (placeholder values)
        String transactionChartData = "{\"labels\":[\"Jan\",\"Feb\",\"Mar\",\"Apr\",\"May\",\"Jun\",\"Jul\"],\"datasets\":[{\"label\":\"Transactions\",\"data\":[65,59,80,81,56,55,40],\"backgroundColor\":\"rgba(76, 175, 80, 0.2)\",\"borderColor\":\"rgba(76, 175, 80, 1)\",\"borderWidth\":1}]}";
        String paymentMethodChartData = "{\"labels\":[\"Credit Card\",\"Debit Card\",\"Net Banking\",\"Digital Wallet\"],\"datasets\":[{\"data\":[40,20,15,25],\"backgroundColor\":[\"#9c27b0\",\"#4CAF50\",\"#2196F3\",\"#FFC107\"]}]}";

        request.setAttribute("transactionChartData", transactionChartData);
        request.setAttribute("paymentMethodChartData", paymentMethodChartData);
        request.setAttribute("stats", stats);
        request.setAttribute("transactions", transactions);

        request.getRequestDispatcher("/views/admin/transactions.jsp").forward(request, response);
    }
}