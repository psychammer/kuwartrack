package com.example.demo.controller;

import org.apache.catalina.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;


import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth")
public class dataController {
    private static final String BASE_DIRECTORY = "C:\\flutter\\kuwartrack\\demo\\src\\main\\data\\"; // New writable location

    // GET endpoint to retrieve expenses (test via browser)
    @GetMapping("/get_data")
    public ResponseEntity<List<List<String>>> testGetData(@RequestParam String user_id) {
        return getExpenses(user_id);
    }

    // POST endpoint to retrieve expenses (test via HTTP request)
    @PostMapping("/post_data")
    public ResponseEntity<List<List<String>>> getData(@RequestBody UserRequest userRequest) {
        return getExpenses(userRequest.getUserId());
    }

    // Method to fetch expenses from CSV
    private ResponseEntity<List<List<String>>> getExpenses(String user_id) {
        List<List<String>> rows = new ArrayList<>();
        String filePath = BASE_DIRECTORY + user_id + "\\expenses.csv";

        File file = new File(filePath);
        if (!file.exists()) {
            return ResponseEntity.status(404).body(Collections.emptyList()); // Return empty if file not found
        }

        try {
            List<String> lines = Files.readAllLines(Paths.get(filePath), StandardCharsets.UTF_8);
            boolean firstLine = true; // Skip the first row (column headers)

            for (String line : lines) {
                if (firstLine) {
                    firstLine = false;
                    continue;
                }
                String[] fields = line.split(",");
                rows.add(Arrays.asList(fields));
            }

            return ResponseEntity.ok(rows);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build(); // Return error response
        }
    }
}

// DTO for User Request (used in POST body)
class UserRequest {
    @JsonProperty("user_id")
    private String user_id;

    // No-argument constructor
    public UserRequest() {}

    // Parameterized constructor
    public UserRequest(String in_user_id) {
        this.user_id = in_user_id;
    }

    // Getters and setters
    public String getUserId() {
        return user_id;
    }

    public void setUserId(String user_id) {
        this.user_id = user_id;
    }
}



