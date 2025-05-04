package com.grocerymanagement.model;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class OrderQueue {
    private Queue<Order> orderQueue;
    private Lock lock;

    public OrderQueue() {
        this.orderQueue = new LinkedList<>();
        this.lock = new ReentrantLock();
    }

    public void enqueue(Order order) {
        lock.lock();
        try {
            orderQueue.offer(order);
        } finally {
            lock.unlock();
        }
    }

    public Order dequeue() {
        lock.lock();
        try {
            return orderQueue.poll();
        } finally {
            lock.unlock();
        }
    }

    public int size() {
        lock.lock();
        try {
            return orderQueue.size();
        } finally {
            lock.unlock();
        }
    }

    public boolean isEmpty() {
        lock.lock();
        try {
            return orderQueue.isEmpty();
        } finally {
            lock.unlock();
        }
    }
}