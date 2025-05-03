package com.grocerymanagement.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

public class Inventory implements Serializable {
    private String inventoryId;
    private String productId;
    private String productName;
    private int currentStock;
    private int minimumStockLevel;
    private int maximumStockLevel;
    private String warehouseLocation;
    private LocalDateTime lastUpdated;
    private InventoryStatus status;

    public enum InventoryStatus {
        IN_STOCK, LOW_STOCK, OUT_OF_STOCK, OVERSTOCKED
    }

    public Inventory() {
        this.inventoryId = UUID.randomUUID().toString();
        this.lastUpdated = LocalDateTime.now();
        this.status = InventoryStatus.IN_STOCK;
    }

    // Getters
    public String getInventoryId() {
        return inventoryId;
    }

    public String getProductId() {
        return productId;
    }

    public String getProductName() {
        return productName;
    }

    public int getCurrentStock() {
        return currentStock;
    }

    public int getMinimumStockLevel() {
        return minimumStockLevel;
    }

    public int getMaximumStockLevel() {
        return maximumStockLevel;
    }

    public String getWarehouseLocation() {
        return warehouseLocation;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public InventoryStatus getStatus() {
        return status;
    }

    // Setters
    public void setInventoryId(String inventoryId) {
        this.inventoryId = inventoryId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public void setCurrentStock(int currentStock) {
        this.currentStock = currentStock;
    }

    public void setMinimumStockLevel(int minimumStockLevel) {
        this.minimumStockLevel = minimumStockLevel;
    }

    public void setMaximumStockLevel(int maximumStockLevel) {
        this.maximumStockLevel = maximumStockLevel;
    }

    public void setWarehouseLocation(String warehouseLocation) {
        this.warehouseLocation = warehouseLocation;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public void setStatus(InventoryStatus status) {
        this.status = status;
    }

    public String toFileString() {
        return String.join("|",
                inventoryId,
                productId,
                productName,
                String.valueOf(currentStock),
                String.valueOf(minimumStockLevel),
                String.valueOf(maximumStockLevel),
                warehouseLocation,
                lastUpdated.toString(),
                status.name()
        );
    }

    public static Inventory fromFileString(String line) {
        String[] parts = line.split("\\|");
        Inventory inventory = new Inventory();
        inventory.inventoryId = parts[0];
        inventory.productId = parts[1];
        inventory.productName = parts[2];
        inventory.currentStock = Integer.parseInt(parts[3]);
        inventory.minimumStockLevel = Integer.parseInt(parts[4]);
        inventory.maximumStockLevel = Integer.parseInt(parts[5]);
        inventory.warehouseLocation = parts[6];
        inventory.lastUpdated = LocalDateTime.parse(parts[7]);
        inventory.status = InventoryStatus.valueOf(parts[8]);
        return inventory;
    }

    public void updateInventoryStatus() {
        if (currentStock == 0) {
            status = InventoryStatus.OUT_OF_STOCK;
        } else if (currentStock <= minimumStockLevel) {
            status = InventoryStatus.LOW_STOCK;
        } else if (currentStock >= maximumStockLevel) {
            status = InventoryStatus.OVERSTOCKED;
        } else {
            status = InventoryStatus.IN_STOCK;
        }
    }
}