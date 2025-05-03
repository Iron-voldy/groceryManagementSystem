package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.Inventory;
import com.grocerymanagement.util.FileHandlerUtil;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class InventoryDAO {
    private String inventoryFilePath;

    public InventoryDAO(FileInitializationUtil fileInitUtil) {
        this.inventoryFilePath = fileInitUtil.getDataFilePath("inventory.txt");
    }

    public boolean createInventory(Inventory inventory) {
        if (!validateInventory(inventory)) {
            return false;
        }

        FileHandlerUtil.writeToFile(inventoryFilePath, inventory.toFileString(), true);
        return true;
    }

    public Optional<Inventory> getInventoryByProductId(String productId) {
        return FileHandlerUtil.readFromFile(inventoryFilePath).stream()
                .map(Inventory::fromFileString)
                .filter(inv -> inv.getProductId().equals(productId))
                .findFirst();
    }

    public List<Inventory> getAllInventory() {
        return FileHandlerUtil.readFromFile(inventoryFilePath).stream()
                .map(Inventory::fromFileString)
                .collect(Collectors.toList());
    }

    public List<Inventory> getLowStockInventory() {
        return getAllInventory().stream()
                .filter(inv -> inv.getStatus() == Inventory.InventoryStatus.LOW_STOCK)
                .collect(Collectors.toList());
    }

    public boolean updateInventory(Inventory updatedInventory) {
        List<String> lines = FileHandlerUtil.readFromFile(inventoryFilePath);
        boolean inventoryFound = false;

        for (int i = 0; i < lines.size(); i++) {
            Inventory existingInventory = Inventory.fromFileString(lines.get(i));
            if (existingInventory.getProductId().equals(updatedInventory.getProductId())) {
                lines.set(i, updatedInventory.toFileString());
                inventoryFound = true;
                break;
            }
        }

        if (inventoryFound) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(inventoryFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating inventory: " + e.getMessage());
                return false;
            }
        }

        return inventoryFound;
    }

    public boolean deleteInventory(String productId) {
        List<String> lines = FileHandlerUtil.readFromFile(inventoryFilePath);
        boolean inventoryRemoved = lines.removeIf(line -> {
            Inventory inventory = Inventory.fromFileString(line);
            return inventory.getProductId().equals(productId);
        });

        if (inventoryRemoved) {
            try (java.io.PrintWriter writer = new java.io.PrintWriter(inventoryFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting inventory: " + e.getMessage());
                return false;
            }
        }

        return inventoryRemoved;
    }

    private boolean validateInventory(Inventory inventory) {
        return inventory.getProductId() != null && !inventory.getProductId().isEmpty() &&
                inventory.getProductName() != null && !inventory.getProductName().isEmpty() &&
                inventory.getCurrentStock() >= 0 &&
                inventory.getMinimumStockLevel() >= 0 &&
                inventory.getMaximumStockLevel() > inventory.getMinimumStockLevel();
    }
}