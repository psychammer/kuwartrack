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
import java.util.ArrayList;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/expenses")
public class updateController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\";

    @PutMapping("/update")
    public ResponseEntity<String> updateExpense(@RequestBody Expense updatedExpense) {
        // File path: "src/main/data/{userId}/expenses.csv"
        String userDirectory = BASE_DIRECTORY + updatedExpense.getUserId();
        String filePath = userDirectory + "\\expenses.csv";

        System.out.println(filePath);

        File file = new File(filePath);
        if (!file.exists()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User-specific CSV file not found");
        }

        List<String> lines;
        boolean found = false;

        try {
            // Read existing CSV content
            lines = Files.readAllLines(Paths.get(filePath), StandardCharsets.UTF_8);
            List<String> updatedLines = new ArrayList<>();

            for (String line : lines) {
                String[] values = line.split(",");
                if (values.length >= 4 &&
                        values[0] != null && values[0].equalsIgnoreCase(updatedExpense.getCategory()) && // Check for null before calling equalsIgnoreCase
                        values[1] != null && values[1].equalsIgnoreCase(updatedExpense.getTransaction()) &&
                        values[3] != null && values[3].equalsIgnoreCase(updatedExpense.getDate())) {

                    values[2] = updatedExpense.getSpent(); // Update "spent" field
                    found = true;
                }
                updatedLines.add(String.join(",", values));
            }

            if (!found) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Expense not found");
            }

            // Write updated content back to the file
            Files.write(Paths.get(filePath), updatedLines, StandardCharsets.UTF_8);

            return ResponseEntity.ok("Expense updated successfully");

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error processing CSV file");
        }
    }
}



//public class updateController {
//
//    private static final String CSV_FILE = "expenses.csv";
//
//    @PutMapping("/update")
//    public ResponseEntity<String> updateExpense(@RequestBody Expense updatedExpense) {
//
//        String filePath = updatedExpense.getUserId() + "/" + CSV_FILE;
//        List<String[]> csvData = new ArrayList<>();
//        boolean found = false;
//
//        try {
//            // Use ClassLoader to get the InputStream (for resources)
//            ClassLoader classLoader = getClass().getClassLoader();
//            InputStream inputStream = classLoader.getResourceAsStream(filePath);
//
//            if (inputStream == null) {
//                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("CSV file not found in resources");
//            }
//
//            try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) { // Specify UTF-8
//                String line;
//                while ((line = br.readLine()) != null) {
//                    String[] values = line.split(",");
//                    if (values.length >= 4 && values[0].equalsIgnoreCase(updatedExpense.getCategory()) &&
//                            values[1].equalsIgnoreCase(updatedExpense.getTransaction()) &&
//                            values[3].equalsIgnoreCase(updatedExpense.getDate())) {
//
//                        values[2] = updatedExpense.getSpent();
//                        found = true;
//                    }
//                    csvData.add(values);
//                }
//            }
//
//        } catch (IOException e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error reading CSV file");
//        }
//
//        if (!found) {
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Expense not found");
//        }
//
//
//        try {
//            // Write back to the resource (if possible - see important note below)
//            ClassLoader classLoader = getClass().getClassLoader();
//            URL resourceUrl = classLoader.getResource(filePath);
//
//            if (resourceUrl == null) {
//                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Resource URL not found");
//            }
//
//            if (!resourceUrl.getProtocol().equals("file")) {
//                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//                        .body("Cannot write to resource inside JAR. Use a different storage mechanism.");
//            }
//
//            File file = new File(resourceUrl.toURI());
//            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, StandardCharsets.UTF_8))) { // Specify UTF-8
//                for (String[] row : csvData) {
//                    System.out.println("hmmmm");
//                    bw.write(String.join(",", row));
//                    bw.newLine();
//                }
//            }
//
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating CSV file");
//        }
//
//        return ResponseEntity.ok("Expense updated successfully");
//    }
//}


class Expense {
    private String category;
    private String transaction;
    private String spent;
    private String date;
    private String userId;

    // Default constructor (important for @RequestBody in Spring Boot)
    public Expense() {}

    public Expense(String category, String transaction, String spent, String date, String userId) {
        this.category = category;
        this.transaction = transaction;
        this.spent = spent;
        this.date = date;
        this.userId = userId;
    }

    // Getters
    public String getCategory() {
        return category;
    }

    public String getTransaction() {
        return transaction;
    }

    public String getSpent() {
        return spent;
    }

    public String getDate() {
        return date;
    }

    public String getUserId() {
        return userId;
    }

    // Setters (needed if you're modifying this object)
    public void setCategory(String category) {
        this.category = category;
    }

    public void setTransaction(String transaction) {
        this.transaction = transaction;
    }

    public void setSpent(String spent) {
        this.spent = spent;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}



