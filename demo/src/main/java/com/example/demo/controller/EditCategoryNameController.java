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
public class EditCategoryNameController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";

    @PutMapping("/edit-category-name")
    public ResponseEntity<String> updateCategory(@RequestBody CategoryUpdateRequest request) {
        try {
            // Path to the user-specific CSV file
            String filePath = BASE_DIRECTORY + "\\" + request.getUserId() + "\\" + "expenses.csv";

            File csvFile = new File(filePath);
            if (!csvFile.exists()) {
                return ResponseEntity.status(404).body("File not found");
            }

            // Read all lines from the CSV file
            List<String> lines = new ArrayList<>();
            boolean updated = false;

            try (BufferedReader reader = new BufferedReader(new FileReader(csvFile))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String[] fields = line.split(",");
                    if (fields.length < 4) continue; // Skip malformed lines

                    String category = fields[0];
                    String transaction = fields[1];
                    String spent = fields[2];
                    String date = fields[3];

                    // Check if the row matches the category and date
                    if (category.equalsIgnoreCase(request.getOldCategory()) && date.equalsIgnoreCase(request.getDate())) {
                        fields[0] = request.getNewCategory(); // Update category name
                        updated = true;
                    }

                    lines.add(String.join(",", fields));
                }
            }

            // If no updates were made, return a 404 response
            if (!updated) {
                return ResponseEntity.status(404).body("No matching records found to update");
            }

            // Write the updated content back to the CSV file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(csvFile))) {
                for (String updatedLine : lines) {
                    writer.write(updatedLine);
                    writer.newLine();
                }
            }

            return ResponseEntity.ok("Category updated successfully");

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error updating category");
        }
    }

    // Inner class to handle incoming request data
    public static class CategoryUpdateRequest {
        private String oldCategory;
        private String newCategory;
        private String date;
        private String userId;

        // Getters and Setters
        public String getOldCategory() {
            return oldCategory;
        }

        public void setOldCategory(String oldCategory) {
            this.oldCategory = oldCategory;
        }

        public String getNewCategory() {
            return newCategory;
        }

        public void setNewCategory(String newCategory) {
            this.newCategory = newCategory;
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
