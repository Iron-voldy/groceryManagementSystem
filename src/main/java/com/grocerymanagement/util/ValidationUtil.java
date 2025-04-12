package com.grocerymanagement.util;

import java.util.regex.Pattern;

public class ValidationUtil {
    private static final String EMAIL_REGEX =
            "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";

    public static boolean isValidEmail(String email) {
        return email != null && Pattern.matches(EMAIL_REGEX, email);
    }

    public static boolean isValidPassword(String password) {
        return password != null &&
                password.length() >= 8 &&
                password.matches(".*[A-Z].*") &&
                password.matches(".*[a-z].*") &&
                password.matches(".*\\d.*");
    }

    public static boolean isValidUsername(String username) {
        return username != null &&
                username.length() >= 4 &&
                username.length() <= 20 &&
                username.matches("^[a-zA-Z0-9_]+$");
    }
}
