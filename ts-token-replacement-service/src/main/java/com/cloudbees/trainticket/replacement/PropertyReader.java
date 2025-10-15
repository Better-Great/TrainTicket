package com.cloudbees.trainticket.replacement;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Utility class for reading and writing property files.
 * 
 * Supports reading .ini files with key=value format.
 */
public class PropertyReader {
    
    /**
     * Reads properties from a file in key=value format.
     * 
     * @param file The properties file to read
     * @return Map of property keys to values
     * @throws IOException If file cannot be read
     */
    public Map<String, String> readProperties(File file) throws IOException {
        Map<String, String> properties = new LinkedHashMap<>();
        
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            
            String line;
            int lineNumber = 0;
            
            while ((line = reader.readLine()) != null) {
                lineNumber++;
                line = line.trim();
                
                // Skip empty lines and comments
                if (line.isEmpty() || line.startsWith("#") || line.startsWith(";")) {
                    continue;
                }
                
                // Parse key=value
                int separatorIndex = line.indexOf('=');
                if (separatorIndex > 0) {
                    String key = line.substring(0, separatorIndex).trim();
                    String value = line.substring(separatorIndex + 1).trim();
                    properties.put(key, value);
                } else {
                    System.err.println("WARNING: Invalid property format at line " + lineNumber + ": " + line);
                }
            }
        }
        
        return properties;
    }
    
    /**
     * Reads entire file content as a string.
     * 
     * @param file The file to read
     * @return File content as string
     * @throws IOException If file cannot be read
     */
    public String readFile(File file) throws IOException {
        StringBuilder content = new StringBuilder();
        
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append(System.lineSeparator());
            }
        }
        
        return content.toString();
    }
    
    /**
     * Writes content to a file.
     * 
     * @param file The file to write to
     * @param content The content to write
     * @throws IOException If file cannot be written
     */
    public void writeFile(File file, String content) throws IOException {
        // Ensure parent directory exists
        File parentDir = file.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            parentDir.mkdirs();
        }
        
        try (BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(new FileOutputStream(file), StandardCharsets.UTF_8))) {
            writer.write(content);
        }
    }
}

