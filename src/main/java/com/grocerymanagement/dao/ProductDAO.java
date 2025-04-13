package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.util.FileHandlerUtil;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class ProductDAO {
    private String productFilePath;
    private FileInitializationUtil fileInitUtil;

    public ProductDAO(FileInitializationUtil fileInitUtil) {
        this.fileInitUtil = fileInitUtil;
        this.productFilePath = fileInitUtil.getDataFilePath("products.txt");
    }

    public boolean createProduct(Product product) {
        if (!validateProduct(product)) {
            return false;
        }

        FileHandlerUtil.writeToFile(productFilePath, product.toFileString(), true);
        return true;
    }

    public Optional<Product> getProductById(String productId) {
        return FileHandlerUtil.readFromFile(productFilePath).stream()
                .map(Product::fromFileString)
                .filter(product -> product.getProductId().equals(productId))
                .findFirst();
    }

    public List<Product> getProductsByCategory(String category) {
        return FileHandlerUtil.readFromFile(productFilePath).stream()
                .map(Product::fromFileString)
                .filter(product -> product.getCategory().equalsIgnoreCase(category))
                .collect(Collectors.toList());
    }

    public List<Product> searchProductsByName(String searchTerm) {
        return FileHandlerUtil.readFromFile(productFilePath).stream()
                .map(Product::fromFileString)
                .filter(product -> product.getName().toLowerCase().contains(searchTerm.toLowerCase()))
                .collect(Collectors.toList());
    }

    public List<Product> getAllProducts() {
        return FileHandlerUtil.readFromFile(productFilePath).stream()
                .map(Product::fromFileString)
                .collect(Collectors.toList());
    }

    public boolean updateProduct(Product updatedProduct) {
        List<String> lines = FileHandlerUtil.readFromFile(productFilePath);
        boolean productFound = false;

        for (int i = 0; i < lines.size(); i++) {
            Product existingProduct = Product.fromFileString(lines.get(i));
            if (existingProduct.getProductId().equals(updatedProduct.getProductId())) {
                lines.set(i, updatedProduct.toFileString());
                productFound = true;
                break;
            }
        }

        if (productFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(productFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating product: " + e.getMessage());
                return false;
            }
        }

        return productFound;
    }

    public boolean deleteProduct(String productId) {
        List<String> lines = FileHandlerUtil.readFromFile(productFilePath);
        boolean productRemoved = lines.removeIf(line -> {
            Product product = Product.fromFileString(line);
            return product.getProductId().equals(productId);
        });

        if (productRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(productFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting product: " + e.getMessage());
                return false;
            }
        }

        return productRemoved;
    }

    public boolean updateProductStock(String productId, int quantityChange) {
        Optional<Product> productOptional = getProductById(productId);
        if (!productOptional.isPresent()) {
            return false;
        }

        Product product = productOptional.get();
        int newStock = product.getStockQuantity() + quantityChange;

        if (newStock < 0) {
            return false; // Cannot have negative stock
        }

        product.setStockQuantity(newStock);
        return updateProduct(product);
    }

    private boolean validateProduct(Product product) {
        return product.getName() != null && !product.getName().isEmpty() &&
                product.getCategory() != null && !product.getCategory().isEmpty() &&
                product.getPrice() != null && product.getPrice().compareTo(BigDecimal.ZERO) > 0 &&
                product.getStockQuantity() >= 0;
    }

    public String getImageUploadPath(String filename) {
        return fileInitUtil.getImageUploadPath(filename);
    }
}