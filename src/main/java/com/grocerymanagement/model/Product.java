package com.grocerymanagement.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.UUID;

public class Product implements Serializable {
    private String productId;
    private String name;
    private String category;
    private BigDecimal price;
    private int stockQuantity;
    private String description;
    private String imagePath;
    private LocalDateTime lastUpdated;

    public Product() {
        this.productId = UUID.randomUUID().toString();
        this.lastUpdated = LocalDateTime.now();
    }

    public Product(String name, String category, BigDecimal price, int stockQuantity, String description) {
        this();
        this.name = name;
        this.category = category;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.description = description;
    }

    // Getters and setters
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    // New getter to convert LocalDateTime to Date for JSP compatibility
    public Date getLastUpdatedAsDate() {
        return Date.from(lastUpdated.atZone(ZoneId.systemDefault()).toInstant());
    }

    public String toFileString() {
        return String.join("|",
                productId,
                name,
                category,
                price.toString(),
                String.valueOf(stockQuantity),
                description,
                imagePath != null ? imagePath : "",
                lastUpdated.toString()
        );
    }

    public static Product fromFileString(String line) {
        String[] parts = line.split("\\|");
        Product product = new Product();
        product.productId = parts[0];
        product.name = parts[1];
        product.category = parts[2];
        product.price = new BigDecimal(parts[3]);
        product.stockQuantity = Integer.parseInt(parts[4]);
        product.description = parts[5];
        if (parts.length > 6 && !parts[6].isEmpty()) {
            product.imagePath = parts[6];
        }
        product.lastUpdated = LocalDateTime.parse(parts[parts.length - 1]);
        return product;
    }
}