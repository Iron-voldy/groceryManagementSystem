package com.grocerymanagement.dao;

import com.grocerymanagement.config.FileInitializationUtil;
import com.grocerymanagement.model.User;
import com.grocerymanagement.util.FileHandlerUtil;
import com.grocerymanagement.util.ValidationUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class UserDAO {
    private String userFilePath;

    public UserDAO(FileInitializationUtil fileInitUtil) {
        this.userFilePath = fileInitUtil.getDataFilePath("users.txt");
    }

    public boolean createUser(User user) {
        // Validate user input
        if (!validateUser(user)) {
            return false;
        }

        // Check if username or email already exists
        if (getUserByUsername(user.getUsername()).isPresent() ||
                getUserByEmail(user.getEmail()).isPresent()) {
            return false;
        }

        // Write user to file
        FileHandlerUtil.writeToFile(userFilePath, user.toFileString(), true);
        return true;
    }

    public Optional<User> getUserById(String userId) {
        return FileHandlerUtil.readFromFile(userFilePath).stream()
                .map(User::fromFileString)
                .filter(user -> user.getUserId().equals(userId))
                .findFirst();
    }

    public Optional<User> getUserByUsername(String username) {
        return FileHandlerUtil.readFromFile(userFilePath).stream()
                .map(User::fromFileString)
                .filter(user -> user.getUsername().equals(username))
                .findFirst();
    }

    public Optional<User> getUserByEmail(String email) {
        return FileHandlerUtil.readFromFile(userFilePath).stream()
                .map(User::fromFileString)
                .filter(user -> user.getEmail().equals(email))
                .findFirst();
    }

    public List<User> getAllUsers() {
        return FileHandlerUtil.readFromFile(userFilePath).stream()
                .map(User::fromFileString)
                .collect(Collectors.toList());
    }

    public boolean updateUser(User updatedUser) {
        List<String> lines = FileHandlerUtil.readFromFile(userFilePath);
        boolean userFound = false;

        for (int i = 0; i < lines.size(); i++) {
            User existingUser = User.fromFileString(lines.get(i));
            if (existingUser.getUserId().equals(updatedUser.getUserId())) {
                lines.set(i, updatedUser.toFileString());
                userFound = true;
                break;
            }
        }

        if (userFound) {
            // Overwrite file with updated lines
            try (java.io.PrintWriter writer = new java.io.PrintWriter(userFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error updating user: " + e.getMessage());
                return false;
            }
        }

        return userFound;
    }

    public boolean deleteUser(String userId) {
        List<String> lines = FileHandlerUtil.readFromFile(userFilePath);
        boolean userRemoved = lines.removeIf(line -> {
            User user = User.fromFileString(line);
            return user.getUserId().equals(userId);
        });

        if (userRemoved) {
            // Overwrite file without the deleted user
            try (java.io.PrintWriter writer = new java.io.PrintWriter(userFilePath)) {
                lines.forEach(writer::println);
            } catch (java.io.FileNotFoundException e) {
                System.err.println("Error deleting user: " + e.getMessage());
                return false;
            }
        }

        return userRemoved;
    }

    private boolean validateUser(User user) {
        return ValidationUtil.isValidUsername(user.getUsername()) &&
                ValidationUtil.isValidEmail(user.getEmail());
    }
}
