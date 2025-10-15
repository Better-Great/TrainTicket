package com.cloudbees.trainticket.replacement;

import java.io.File;
import java.io.IOException;
import java.util.Map;

/**
 * Main service class for replacing parameterized tokens in application configuration files.
 * 
 * This service:
 * 1. Reads environment-specific properties from properties/{env}.application.ini
 * 2. Scans all ts-* service directories for application.properties.ini templates
 * 3. Replaces ${VariableName} tokens with actual values
 * 4. Generates application.properties files in each service's src/main/resources directory
 * 
 * Usage:
 *   java -jar token-replacement-service.jar <environment> [project-root]
 * 
 * Arguments:
 *   environment  - The environment name (e.g., dev, qa, prod)
 *   project-root - Optional. Root directory of the TrainTicket project (defaults to current directory)
 * 
 * Example:
 *   java -jar token-replacement-service.jar dev
 *   java -jar token-replacement-service.jar qa /path/to/TrainTicket
 */
public class PropertyReplacementService {
    
    private static final String PROPERTIES_DIR = "properties";
    private static final String TEMPLATE_FILE = "application.properties.ini";
    private static final String OUTPUT_FILE = "application.properties";
    private static final String RESOURCES_DIR = "src/main/resources";
    
    public static void main(String[] args) {
        if (args.length < 1) {
            printUsage();
            System.exit(1);
        }
        
        String environment = args[0];
        String projectRoot = args.length > 1 ? args[1] : System.getProperty("user.dir");
        
        try {
            System.out.println("========================================");
            System.out.println("Token Replacement Service");
            System.out.println("========================================");
            System.out.println("Environment: " + environment);
            System.out.println("Project Root: " + projectRoot);
            System.out.println("========================================\n");
            
            PropertyReplacementService service = new PropertyReplacementService(projectRoot, environment);
            service.execute();
            
            System.out.println("\n========================================");
            System.out.println("Token replacement completed successfully!");
            System.out.println("========================================");
            
        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
    
    private static void printUsage() {
        System.out.println("Usage: java -jar token-replacement-service.jar <environment> [project-root]");
        System.out.println();
        System.out.println("Arguments:");
        System.out.println("  environment  - The environment name (e.g., dev, qa, prod)");
        System.out.println("  project-root - Optional. Root directory of the TrainTicket project");
        System.out.println();
        System.out.println("Example:");
        System.out.println("  java -jar token-replacement-service.jar dev");
        System.out.println("  java -jar token-replacement-service.jar qa /path/to/TrainTicket");
    }
    
    private final String projectRoot;
    private final String environment;
    private final PropertyReader propertyReader;
    private final TokenReplacer tokenReplacer;
    
    public PropertyReplacementService(String projectRoot, String environment) {
        this.projectRoot = projectRoot;
        this.environment = environment;
        this.propertyReader = new PropertyReader();
        this.tokenReplacer = new TokenReplacer();
    }
    
    public void execute() throws IOException {
        // Load environment-specific properties
        File propertiesFile = new File(projectRoot, PROPERTIES_DIR + File.separator + environment + ".application.ini");
        
        if (!propertiesFile.exists()) {
            throw new IOException("Environment properties file not found: " + propertiesFile.getAbsolutePath());
        }
        
        System.out.println("Loading properties from: " + propertiesFile.getAbsolutePath());
        Map<String, String> properties = propertyReader.readProperties(propertiesFile);
        System.out.println("Loaded " + properties.size() + " properties\n");
        
        // Scan for service directories
        File projectDir = new File(projectRoot);
        File[] serviceDirs = projectDir.listFiles((dir, name) -> name.startsWith("ts-") && new File(dir, name).isDirectory());
        
        if (serviceDirs == null || serviceDirs.length == 0) {
            System.out.println("No service directories found (ts-*)");
            return;
        }
        
        int processedCount = 0;
        int skippedCount = 0;
        
        // Process each service
        for (File serviceDir : serviceDirs) {
            File templateFile = new File(serviceDir, TEMPLATE_FILE);
            
            if (!templateFile.exists()) {
                System.out.println("[SKIP] " + serviceDir.getName() + " - No template file found");
                skippedCount++;
                continue;
            }
            
            try {
                processService(serviceDir, templateFile, properties);
                processedCount++;
            } catch (Exception e) {
                System.err.println("[ERROR] " + serviceDir.getName() + " - " + e.getMessage());
            }
        }
        
        System.out.println("\n----------------------------------------");
        System.out.println("Summary:");
        System.out.println("  Processed: " + processedCount);
        System.out.println("  Skipped:   " + skippedCount);
        System.out.println("  Total:     " + serviceDirs.length);
        System.out.println("----------------------------------------");
    }
    
    private void processService(File serviceDir, File templateFile, Map<String, String> properties) throws IOException {
        String serviceName = serviceDir.getName();
        System.out.println("[PROCESSING] " + serviceName);
        
        // Read template content
        String templateContent = propertyReader.readFile(templateFile);
        
        // Replace tokens
        String processedContent = tokenReplacer.replaceTokens(templateContent, properties);
        
        // Write output file
        File outputDir = new File(serviceDir, RESOURCES_DIR);
        if (!outputDir.exists()) {
            outputDir.mkdirs();
        }
        
        File outputFile = new File(outputDir, OUTPUT_FILE);
        propertyReader.writeFile(outputFile, processedContent);
        
        System.out.println("  ✓ Generated: " + outputFile.getAbsolutePath());
    }
}

