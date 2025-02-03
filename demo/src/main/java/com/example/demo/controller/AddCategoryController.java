package com.example.demo.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.io.*;
import java.util.*;

@RestController
@RequestMapping("/expenses")
public class AddCategoryController {

    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";

    @PostMapping("/add-category")
    public ResponseEntity<String> addExpense(@RequestBody ExpenseRequest request) {
        try {
            // Path to the user-specific CSV file
            String filePath = BASE_DIRECTORY + "\\" + request.getUserId() + "\\" + "expenses.csv";

            File csvFile = new File(filePath);
            if (!csvFile.exists()) {
                csvFile.getParentFile().mkdirs(); // Ensure directory exists
                csvFile.createNewFile(); // Create file if it doesn't exist
            }

            // Read all existing records
            List<String> lines = new ArrayList<>();
            boolean isDuplicate = false;

            try (BufferedReader reader = new BufferedReader(new FileReader(csvFile))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    lines.add(line);
                    String[] fields = line.split(",");
                    if (fields.length >= 4) {
                        String category = fields[0];
                        String transaction = fields[1];
                        String date = fields[3];

                        // Check for duplicate
                        if (category.equalsIgnoreCase(request.getCategory()) &&
                                transaction.equalsIgnoreCase(request.getTransaction()) &&
                                date.equalsIgnoreCase(request.getDate())) {
                            isDuplicate = true;
                        }
                    }
                }
            }

            // If duplicate found, return 409 Conflict
            if (isDuplicate) {
                return ResponseEntity.status(409).body("Expense already exists.");
            }

            // Append new entry to file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(csvFile, true))) {
                String newEntry = String.join(",", request.getCategory(), request.getTransaction(), request.getMoneySpent(), request.getDate());
                writer.write(newEntry);
                writer.newLine();
            }

            System.out.println("here? " + request.getMoneySpent());

            return ResponseEntity.status(201).body("Expense added successfully!");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error adding expense.");
        }
    }

    // Inner class to handle incoming request data
    public static class ExpenseRequest {
        private String category;
        private String transaction;
        private String moneySpent;
        private String date;
        private String userId;

        // Getters and Setters
        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getTransaction() {
            return transaction;
        }

        public void setTransaction(String transaction) {
            this.transaction = transaction;
        }

        public String getMoneySpent() {
            return moneySpent;
        }

        public void setMoneySpent(String moneySpent) {
            this.moneySpent = moneySpent;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }
}

