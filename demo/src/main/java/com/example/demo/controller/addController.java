package com.example.demo.controller;
import org.apache.catalina.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;


import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/expenses")
public class addController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";

    @PostMapping("/add")
    public ResponseEntity<String> addExpense(@RequestBody ExpenseRequest request) {
        try {
            // Path to the user-specific CSV file
            String filePath = BASE_DIRECTORY + "\\" + request.getUserId() + "\\" + "expenses.csv";

            // Read the current CSV file
            File csvFile = new File(filePath);
            if (!csvFile.exists()) {
                return ResponseEntity.status(404).body("File not found");
            }

            // Read all the lines in the CSV file
            List<String> lines = new ArrayList<>();
            try (BufferedReader reader = new BufferedReader(new FileReader(csvFile))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    lines.add(line);
                }
            }

            // Check if the combination of category, transaction, and date already exists
            for (String line : lines) {
                String[] fields = line.split(",");
                String category = fields[0];
                String transaction = fields[1];
                String spent = fields[2];
                String date = fields[3];

                // Check if the combination of category, transaction, and date already exists
                if (category.equalsIgnoreCase(request.getCategory()) &&
                        transaction.equalsIgnoreCase(request.getTransaction()) &&
                        date.equalsIgnoreCase(request.getDate())) {
                    return ResponseEntity.status(409).body("Expense already exists for this category, transaction, and date");
                }
            }

            // If not found, add the new expense to the list
            String newLine = request.getCategory() + "," + request.getTransaction() + "," + request.getSpent() + "," + request.getDate();
            lines.add(newLine);

            // Write the updated lines back to the CSV file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(csvFile))) {
                for (String updatedLine : lines) {
                    writer.write(updatedLine);
                    writer.newLine();
                }
            }

            return ResponseEntity.ok("Expense added successfully");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error adding expense");
        }
    }

    // Inner class to handle incoming request data
    public static class ExpenseRequest {
        private String category;
        private String transaction;
        private String date;
        private String spent;
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

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getSpent() {
            return spent;
        }

        public void setSpent(String spent) {
            this.spent = spent;
        }

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }
}
