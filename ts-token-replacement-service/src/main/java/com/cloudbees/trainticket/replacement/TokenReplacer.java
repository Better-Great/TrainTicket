package com.cloudbees.trainticket.replacement;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class for replacing parameterized tokens in text.
 * 
 * Supports tokens in the format: ${VariableName}
 */
public class TokenReplacer {
    
    private static final Pattern TOKEN_PATTERN = Pattern.compile("\\$\\{([^}]+)\\}");
    
    /**
     * Replaces all ${VariableName} tokens in the content with actual values from properties.
     * 
     * @param content The content containing tokens
     * @param properties Map of property keys to values
     * @return Content with tokens replaced
     */
    public String replaceTokens(String content, Map<String, String> properties) {
        if (content == null || content.isEmpty()) {
            return content;
        }
        
        List<String> missingTokens = new ArrayList<>();
        StringBuffer result = new StringBuffer();
        Matcher matcher = TOKEN_PATTERN.matcher(content);
        
        while (matcher.find()) {
            String token = matcher.group(1); // Variable name without ${}
            String value = properties.get(token);
            
            if (value != null) {
                // Replace with actual value, escaping special regex characters
                matcher.appendReplacement(result, Matcher.quoteReplacement(value));
            } else {
                // Keep original token if no replacement value found
                missingTokens.add(token);
                matcher.appendReplacement(result, Matcher.quoteReplacement(matcher.group(0)));
            }
        }
        
        matcher.appendTail(result);
        
        // Report missing tokens
        if (!missingTokens.isEmpty()) {
            System.out.println("  WARNING: Missing property values for tokens: " + missingTokens);
        }
        
        return result.toString();
    }
    
    /**
     * Finds all tokens in the content.
     * 
     * @param content The content to scan for tokens
     * @return List of token names (without ${})
     */
    public List<String> findTokens(String content) {
        List<String> tokens = new ArrayList<>();
        Matcher matcher = TOKEN_PATTERN.matcher(content);
        
        while (matcher.find()) {
            String token = matcher.group(1);
            if (!tokens.contains(token)) {
                tokens.add(token);
            }
        }
        
        return tokens;
    }
}

