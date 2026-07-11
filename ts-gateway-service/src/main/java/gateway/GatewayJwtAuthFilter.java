package gateway;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.UnsupportedJwtException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * TT-501: central JWT check at the edge for protected prefixes
 * (admin + booking preserve/payment by default). {@code /welcome} under those
 * prefixes stays public for health/smoke. Same secret resolution as JWTUtil.
 */
@Component
public class GatewayJwtAuthFilter implements GlobalFilter, Ordered {

    private static final Logger LOGGER = LoggerFactory.getLogger(GatewayJwtAuthFilter.class);
    private static final String DEFAULT_SECRET = "secret";
    private static final String DEFAULT_PREFIXES =
            "/api/v1/admin,/api/v1/preserveservice,/api/v1/paymentservice,/api/v1/inside_pay_service";

    private final boolean enabled;
    private final String encodedSecret;
    private final List<String> protectedPrefixes;

    public GatewayJwtAuthFilter(
            @Value("${GATEWAY_JWT_ENABLED:true}") boolean enabled,
            @Value("${JWT_SECRET:${jwt.secret:secret}}") String rawSecret,
            @Value("${GATEWAY_JWT_PROTECTED_PREFIXES:" + DEFAULT_PREFIXES + "}") String prefixes) {
        this.enabled = enabled;
        String secret = (rawSecret == null || rawSecret.trim().isEmpty()) ? DEFAULT_SECRET : rawSecret.trim();
        if (DEFAULT_SECRET.equals(secret)) {
            LOGGER.warn("[JWT] Gateway using default secret — set JWT_SECRET for non-local use");
        }
        this.encodedSecret = Base64.getEncoder().encodeToString(secret.getBytes(StandardCharsets.UTF_8));
        this.protectedPrefixes = Arrays.stream(prefixes.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        if (!enabled || HttpMethod.OPTIONS.equals(exchange.getRequest().getMethod())) {
            return chain.filter(exchange);
        }

        String path = exchange.getRequest().getURI().getPath();
        if (!requiresAuth(path)) {
            return chain.filter(exchange);
        }

        String token = bearerToken(exchange.getRequest());
        if (token == null) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        try {
            if (!validate(token)) {
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            }
        } catch (RuntimeException ex) {
            LOGGER.debug("[JWT] reject path={} reason={}", path, ex.toString());
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        return chain.filter(exchange);
    }

    private boolean requiresAuth(String path) {
        if (path.endsWith("/welcome")) {
            return false;
        }
        for (String prefix : protectedPrefixes) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    private static String bearerToken(ServerHttpRequest request) {
        String header = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7).trim();
        }
        return null;
    }

    private boolean validate(String token) {
        try {
            Date exp = Jwts.parser()
                    .setSigningKey(encodedSecret)
                    .parseClaimsJws(token)
                    .getBody()
                    .getExpiration();
            return exp != null && !exp.before(new Date());
        } catch (ExpiredJwtException | UnsupportedJwtException | MalformedJwtException
                | SignatureException | IllegalArgumentException e) {
            throw e;
        }
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE + 20;
    }
}
