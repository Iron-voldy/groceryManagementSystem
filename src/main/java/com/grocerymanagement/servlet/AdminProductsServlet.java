package com.grocerymanagement.servlet;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.dao.ProductDAO;
import com.grocerymanagement.model.Product;
import com.grocerymanagement.service.ProductSortingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin/products")
public class AdminProductsServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        FileInitializationUtil fileInitUtil = new FileInitializationUtil(getServletContext());
        productDAO = new ProductDAO(fileInitUtil);
        System.out.println("AdminProductsServlet: Initialized with product file path: " + fileInitUtil.getDataFilePath("products.txt"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("AdminProductsServlet: Handling GET request");

        // Fetch all products
        List<Product> products = productDAO.getAllProducts();
        System.out.println("AdminProductsServlet: Fetched " + products.size() + " products");

        // Apply filtering if requested
        String category = request.getParameter("category");
        String searchTerm = request.getParameter("search");
        String stockStatus = request.getParameter("stock");

        if (category != null && !category.isEmpty()) {
            products = filterByCategory(products, category);
            System.out.println("AdminProductsServlet: After category filter (" + category + "): " + products.size() + " products");
        }

        if (searchTerm != null && !searchTerm.isEmpty()) {
            products = searchProducts(products, searchTerm);
            System.out.println("AdminProductsServlet: After search filter (" + searchTerm + "): " + products.size() + " products");
        }

        if (stockStatus != null && !stockStatus.isEmpty()) {
            products = filterByStockStatus(products, stockStatus);
            System.out.println("AdminProductsServlet: After stock filter (" + stockStatus + "): " + products.size() + " products");
        }

        // Apply sorting if requested
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        if (sortBy != null && !sortBy.isEmpty()) {
            products = sortProducts(products, sortBy, sortOrder);
            System.out.println("AdminProductsServlet: Sorted by " + sortBy + " (" + sortOrder + ")");
        }

        // Set request attributes
        request.setAttribute("products", products);
        request.setAttribute("totalProducts", products.size());
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("currentSortOrder", sortOrder);

        System.out.println("AdminProductsServlet: Forwarding to products.jsp with " + products.size() + " products");
        request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
    }

    private List<Product> sortProducts(List<Product> products, String sortBy, String sortOrder) {
        Comparator<Product> comparator;

        switch (sortBy) {
            case "name":
                comparator = ProductSortingService.sortByName();
                break;
            case "category":
                comparator = ProductSortingService.sortByCategory();
                break;
            case "price":
                comparator = ProductSortingService.sortByPrice();
                break;
            case "stock":
                comparator = ProductSortingService.sortByStock();
                break;
            default:
                comparator = ProductSortingService.sortByName();
                break;
        }

        if ("desc".equals(sortOrder)) {
            comparator = comparator.reversed();
        }

        return ProductSortingService.mergeSort(products, comparator);
    }

    private List<Product> filterByCategory(List<Product> products, String category) {
        return products.stream()
                .filter(product -> product.getCategory().equalsIgnoreCase(category))
                .collect(Collectors.toList());
    }

    private List<Product> searchProducts(List<Product> products, String searchTerm) {
        return products.stream()
                .filter(product -> product.getName().toLowerCase().contains(searchTerm.toLowerCase()))
                .collect(Collectors.toList());
    }

    private List<Product> filterByStockStatus(List<Product> products, String stockStatus) {
        if ("instock".equals(stockStatus)) {
            return products.stream()
                    .filter(product -> product.getStockQuantity() > 10)
                    .collect(Collectors.toList());
        } else if ("lowstock".equals(stockStatus)) {
            return products.stream()
                    .filter(product -> product.getStockQuantity() > 0 && product.getStockQuantity() <= 10)
                    .collect(Collectors.toList());
        } else if ("outofstock".equals(stockStatus)) {
            return products.stream()
                    .filter(product -> product.getStockQuantity() == 0)
                    .collect(Collectors.toList());
        }
        return products;
    }
}