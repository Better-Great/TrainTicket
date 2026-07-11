package edu.fudan.common.security.swagger;

/**
 * Shared Swagger/OpenAPI exposure toggle for per-service SecurityConfig beans.
 * Disabled by default; set {@code SWAGGER_ENABLED=true} to expose swagger-ui (local/dev only).
 */
public final class SwaggerAccess {

    private SwaggerAccess() {
        throw new IllegalStateException("Utility class");
    }

    public static boolean isEnabled() {
        return "true".equalsIgnoreCase(System.getenv("SWAGGER_ENABLED"));
    }
}
