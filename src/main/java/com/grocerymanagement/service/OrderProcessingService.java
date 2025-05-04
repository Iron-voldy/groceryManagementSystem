package com.grocerymanagement.service;

import com.grocerymanagement.model.Order;
import com.grocerymanagement.model.OrderQueue;
import com.grocerymanagement.dao.OrderDAO;
import com.grocerymanagement.dao.ProductDAO;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class OrderProcessingService {
    private OrderQueue orderQueue;
    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private ExecutorService executorService;

    public OrderProcessingService(OrderDAO orderDAO, ProductDAO productDAO) {
        this.orderQueue = new OrderQueue();
        this.orderDAO = orderDAO;
        this.productDAO = productDAO;
        this.executorService = Executors.newFixedThreadPool(3);
    }

    public void processOrders() {
        executorService.submit(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                if (!orderQueue.isEmpty()) {
                    Order order = orderQueue.dequeue();
                    try {
                        processOrder(order);
                    } catch (Exception e) {
                        // Handle processing failure
                        order.setStatus(Order.OrderStatus.CANCELLED);
                        orderDAO.updateOrder(order);
                    }
                }

                try {
                    Thread.sleep(1000); // Prevent tight loop
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });
    }

    private void processOrder(Order order) throws InterruptedException {
        // Update product stocks
        order.getItems().forEach(item -> {
            productDAO.updateProductStock(item.getProductId(), -item.getQuantity());
        });

        // Update order status
        order.setStatus(Order.OrderStatus.PROCESSING);
        orderDAO.updateOrder(order);

        // Simulate processing time
        Thread.sleep(2000);

        // Complete order
        order.setStatus(Order.OrderStatus.SHIPPED);
        orderDAO.updateOrder(order);
    }

    public void submitOrder(Order order) {
        orderQueue.enqueue(order);
    }

    public void shutdown() {
        executorService.shutdownNow();
    }
}