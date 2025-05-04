package com.grocerymanagement.service;

import com.grocerymanagement.model.Product;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Service to provide sorting functionality for products using Merge Sort algorithm.
 * This implements the required DSA component for sorting products by various criteria.
 */
public class ProductSortingService {

    /**
     * Sorts a list of products using Merge Sort algorithm.
     *
     * @param products The list of products to sort
     * @param comparator The comparator to determine the sort order
     * @return A new sorted list of products
     */
    public static List<Product> mergeSort(List<Product> products, Comparator<Product> comparator) {
        // Base case: If list has 0 or 1 elements, it's already sorted
        if (products == null || products.size() <= 1) {
            return products;
        }

        // Split the list into two halves
        int mid = products.size() / 2;
        List<Product> left = new ArrayList<>(products.subList(0, mid));
        List<Product> right = new ArrayList<>(products.subList(mid, products.size()));

        // Recursively sort both halves
        left = mergeSort(left, comparator);
        right = mergeSort(right, comparator);

        // Merge the sorted halves
        return merge(left, right, comparator);
    }

    /**
     * Merges two sorted lists into a single sorted list.
     *
     * @param left The left sorted list
     * @param right The right sorted list
     * @param comparator The comparator to determine the sort order
     * @return A merged sorted list
     */
    private static List<Product> merge(List<Product> left, List<Product> right, Comparator<Product> comparator) {
        List<Product> merged = new ArrayList<>();
        int leftIndex = 0, rightIndex = 0;

        // Compare elements from both lists and add the smaller one to the result
        while (leftIndex < left.size() && rightIndex < right.size()) {
            if (comparator.compare(left.get(leftIndex), right.get(rightIndex)) <= 0) {
                merged.add(left.get(leftIndex++));
            } else {
                merged.add(right.get(rightIndex++));
            }
        }

        // Add remaining elements from left list, if any
        merged.addAll(left.subList(leftIndex, left.size()));

        // Add remaining elements from right list, if any
        merged.addAll(right.subList(rightIndex, right.size()));

        return merged;
    }

    /**
     * Returns a comparator for sorting products by name.
     *
     * @return Comparator for product names
     */
    public static Comparator<Product> sortByName() {
        return Comparator.comparing(Product::getName);
    }

    /**
     * Returns a comparator for sorting products by category.
     *
     * @return Comparator for product categories
     */
    public static Comparator<Product> sortByCategory() {
        return Comparator.comparing(Product::getCategory);
    }

    /**
     * Returns a comparator for sorting products by price (ascending).
     *
     * @return Comparator for product prices
     */
    public static Comparator<Product> sortByPrice() {
        return Comparator.comparing(Product::getPrice);
    }

    /**
     * Returns a comparator for sorting products by price (descending).
     *
     * @return Comparator for product prices in descending order
     */
    public static Comparator<Product> sortByPriceDesc() {
        return Comparator.comparing(Product::getPrice).reversed();
    }

    /**
     * Returns a comparator for sorting products by stock quantity.
     *
     * @return Comparator for product stock quantities
     */
    public static Comparator<Product> sortByStock() {
        return Comparator.comparing(Product::getStockQuantity);
    }
}