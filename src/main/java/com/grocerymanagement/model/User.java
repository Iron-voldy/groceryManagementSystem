package com.grocerymanagement.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

public class User implements Serializable {
    private String userId;
    private String username;
    private String email;
    private String passwordHash;
    private UserRole role;
    private LocalDateTime registrationDate;
    private boolean isActive;

    public enum UserRole {
        CUSTOMER, ADMIN, STAFF
    }

    public User() {
        this.userId = UUID.randomUUID().toString();
        this.registrationDate = LocalDateTime.now();
        this.isActive = true;
    }

    public User(String username, String email, String passwordHash, UserRole role) {
        this();
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
    }

    // Getters and setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }
    public LocalDateTime getRegistrationDate() { return registrationDate; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String toFileString() {
        return String.join("|",
                userId,
                username,
                email,
                passwordHash,
                role.name(),
                registrationDate.toString(),
                String.valueOf(isActive)
        );
    }

    public static User fromFileString(String line) {
        String[] parts = line.split("\\|");
        User user = new User();
        user.userId = parts[0];
        user.username = parts[1];
        user.email = parts[2];
        user.passwordHash = parts[3];
        user.role = UserRole.valueOf(parts[4]);
        user.registrationDate = LocalDateTime.parse(parts[5]);
        user.isActive = Boolean.parseBoolean(parts[6]);
        return user;
    }
}
