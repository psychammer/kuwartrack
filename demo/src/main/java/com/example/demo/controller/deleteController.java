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
public class deleteController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";


    @DeleteMapping("/delete")
    public ResponseEntity<String> deleteExpense(@RequestBody ExpenseRequest request) {
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

            // Iterate through lines to find and remove the matching expense
            boolean deleted = false;
            Iterator<String> iterator = lines.iterator();
            while (iterator.hasNext()) {
                String line = iterator.next();
                String[] fields = line.split(",");

                // Assuming the CSV structure: [category, expense, spent, date]
                String category = fields[0];
                String transaction = fields[1];
                String spent = fields[2];
                String date = fields[3];

                if (category.equalsIgnoreCase(request.getCategory()) &&
                        transaction.equalsIgnoreCase(request.getTransaction()) &&
                        date.equalsIgnoreCase(request.getDate())) {
                    iterator.remove();
                    deleted = true;
                    break;
                }
            }

            if (!deleted) {
                return ResponseEntity.status(404).body("Expense not found");
            }

            // Write the updated lines back to the CSV file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(csvFile))) {
                for (String updatedLine : lines) {
                    writer.write(updatedLine);
                    writer.newLine();
                }
            }

            return ResponseEntity.ok("Expense deleted successfully");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error deleting expense");
        }
    }

    // Inner class to handle incoming request data
    public static class ExpenseRequest {
        private String category;
        private String transaction;
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
