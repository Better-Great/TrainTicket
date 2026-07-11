package edu.fudan.common.security.cors;

import java.util.Arrays;

/**
 * Shared CORS origin resolution for per-service SecurityConfig beans.
 * Origins: {@code CORS_ALLOWED_ORIGINS} env (comma-separated), else local dev origins only.
 */
public final class CorsOrigins {

    private CorsOrigins() {
        throw new IllegalStateException("Utility class");
    }

    private static final String[] DEFAULT_ORIGINS = {
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://localhost:8080"
    };

    public static String[] resolveAllowedOrigins() {
        String fromEnv = System.getenv("CORS_ALLOWED_ORIGINS");
        if (fromEnv == null || fromEnv.trim().isEmpty()) {
            return DEFAULT_ORIGINS;
        }
        return Arrays.stream(fromEnv.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toArray(String[]::new);
    }
}
