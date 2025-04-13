package com.grocerymanagement.config;

import javax.servlet.ServletContext;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class FileInitializationUtil {
    private ServletContext servletContext;
    private String baseDataPath;
    private String imageUploadPath;

    public FileInitializationUtil(ServletContext servletContext) {
        this.servletContext = servletContext;
        initializeDataDirectory();
    }

    public FileInitializationUtil() {
        initializeDataDirectory();
    }

    private void initializeDataDirectory() {
        if (servletContext != null) {
            // Web application context
            baseDataPath = servletContext.getRealPath("/WEB-INF/data");
            imageUploadPath = servletContext.getRealPath("/uploads/images");
        } else {
            // Standalone application
            baseDataPath = "data";
            imageUploadPath = "uploads/images";
        }

        try {
            // Ensure data directory exists
            Files.createDirectories(Paths.get(baseDataPath));

            // Ensure image upload directory exists
            Files.createDirectories(Paths.get(imageUploadPath));

            // Initialize essential files
            initializeFile("users.txt");
            initializeFile("products.txt");
            initializeFile("orders.txt");
            initializeFile("cart.txt");
            initializeFile("transactions.txt");
            initializeFile("reviews.txt");

        } catch (IOException e) {
            System.err.println("Error initializing data directory: " + e.getMessage());
        }
    }

    private void initializeFile(String filename) throws IOException {
        File file = new File(baseDataPath, filename);
        if (!file.exists()) {
            boolean created = file.createNewFile();
            if (created) {
                System.out.println("Created file: " + filename);
            }
        }
    }

    public String getDataFilePath(String filename) {
        return Paths.get(baseDataPath, filename).toString();
    }

    public String getImageUploadPath() {
        return imageUploadPath;
    }

    public String getImageUploadPath(String filename) {
        return Paths.get(imageUploadPath, filename).toString();
    }
}