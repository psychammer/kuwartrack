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
public class BudgetController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";

    @GetMapping("/get_budget")
    public ResponseEntity<Map<String, Double>> getBudget(@RequestParam String userId) {
        String filePath = BASE_DIRECTORY + userId + "\\daily_budget.csv";

        try {
            File file = new File(filePath);
            if (!file.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }

            List<String> lines = Files.readAllLines(file.toPath());
            if (lines.size() < 2) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }

            // Extract budget values from the second row
            String[] values = lines.get(1).split(",");
            double todayBudget = Double.parseDouble(values[0]);  // First column
            double totalSavings = Double.parseDouble(values[1]); // Second column

            // Create a JSON response
            Map<String, Double> response = new HashMap<>();
            response.put("today_budget", todayBudget);
            response.put("total_savings", totalSavings);

            return ResponseEntity.ok(response);
        } catch (IOException | NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }




    @PostMapping("/transfer_savings")
    public ResponseEntity<String> transferFromSavings(@RequestBody TransferRequest request) {
        String filePath = BASE_DIRECTORY + request.getUserId() + "\\daily_budget.csv";

        try {
            File file = new File(filePath);
            if (!file.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Budget file not found.");
            }

            List<String> lines = Files.readAllLines(file.toPath());
            if (lines.size() < 2) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid budget file format.");
            }

            // Keep the header row intact
            String header = lines.get(0);
            String[] values = lines.get(1).split(",");

            // Parse values
            double todayBudget = Double.parseDouble(values[0]);  // Assuming first column is today_budget
            double totalSavings = Double.parseDouble(values[1]); // Assuming second column is total_savings

            // Check if there's enough savings
            if (request.getAmount() > totalSavings) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Not enough savings.");
            }

            // Perform transfer
            todayBudget += request.getAmount();
            totalSavings -= request.getAmount();
            String updatedValues = todayBudget + "," + totalSavings;

            // Write back to file (preserving header)
            Files.write(file.toPath(), Arrays.asList(header, updatedValues));

            return ResponseEntity.ok("Transfer successful. New budget: " + todayBudget + ", New savings: " + totalSavings);
        } catch (IOException | NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating budget file.");
        }
    }


    @PutMapping("/update_budget")
    public ResponseEntity<String> updateTodayBudget(@RequestBody BudgetUpdateRequest request) {
        String filePath = BASE_DIRECTORY + request.getUserId() + "\\daily_budget.csv";

        try {
            File file = new File(filePath);
            if (!file.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Budget file not found.");
            }

            List<String> lines = Files.readAllLines(file.toPath());
            if (lines.size() < 2) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid file format.");
            }

            // Extract values from the second row
            String[] values = lines.get(1).split(",");
            if (values.length < 2) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Corrupted data.");
            }

            // Update today's budget while keeping total savings the same
            values[0] = String.valueOf(request.getTodayBudget());
            String updatedRow = String.join(",", values);

            // Write back to CSV
            lines.set(1, updatedRow);
            Files.write(file.toPath(), lines);

            return ResponseEntity.ok("Today's budget updated successfully.");
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating budget.");
        }
    }


    public static class BudgetUpdateRequest {
        private String userId;
        private double todayBudget;

        // Constructor
        public BudgetUpdateRequest() {}

        public BudgetUpdateRequest(String userId, double todayBudget) {
            this.userId = userId;
            this.todayBudget = todayBudget;
        }

        // Getters and Setters
        public String getUserId() {
            return userId;
        }

        public double getTodayBudget() {
            return todayBudget;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }

        public void setTodayBudget(double todayBudget) {
            this.todayBudget = todayBudget;
        }
    }



    // Request body class
    public static class TransferRequest {
        private String userId;
        private double amount;

        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }

        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }
    }

}
