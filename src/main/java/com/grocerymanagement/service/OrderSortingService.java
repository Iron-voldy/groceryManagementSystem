package com.grocerymanagement.service;

import com.grocerymanagement.model.Order;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class OrderSortingService {
    // Merge Sort for Orders
    public static List<Order> mergeSort(List<Order> orders, Comparator<Order> comparator) {
        if (orders.size() <= 1) {
            return orders;
        }

        int mid = orders.size() / 2;
        List<Order> left = new ArrayList<>(orders.subList(0, mid));
        List<Order> right = new ArrayList<>(orders.subList(mid, orders.size()));

        left = mergeSort(left, comparator);
        right = mergeSort(right, comparator);

        return merge(left, right, comparator);
    }

    private static List<Order> merge(List<Order> left, List<Order> right, Comparator<Order> comparator) {
        List<Order> merged = new ArrayList<>();
        int leftIndex = 0, rightIndex = 0;

        while (leftIndex < left.size() && rightIndex < right.size()) {
            if (comparator.compare(left.get(leftIndex), right.get(rightIndex)) <= 0) {
                merged.add(left.get(leftIndex++));
            } else {
                merged.add(right.get(rightIndex++));
            }
        }

        merged.addAll(left.subList(leftIndex, left.size()));
        merged.addAll(right.subList(rightIndex, right.size()));

        return merged;
    }

    // Predefined Comparators
    public static Comparator<Order> sortByDate() {
        return Comparator.comparing(Order::getOrderDate);
    }

    public static Comparator<Order> sortByTotal() {
        return Comparator.comparing(Order::getTotalAmount);
    }

    public static Comparator<Order> sortByStatus() {
        return Comparator.comparing(Order::getStatus);
    }
}