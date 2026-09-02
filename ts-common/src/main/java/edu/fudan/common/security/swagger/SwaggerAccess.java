package edu.fudan.common.security.swagger;

import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.authorization.AuthorizationManager;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;

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

    public static AuthorizationManager<RequestAuthorizationContext> authorizationManager() {
        return (authentication, context) -> new AuthorizationDecision(isEnabled());
    }
}
