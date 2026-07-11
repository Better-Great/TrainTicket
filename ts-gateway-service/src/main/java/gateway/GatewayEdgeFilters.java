package gateway;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.Arrays;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Edge hardening: CORS allowlist + request ID propagation (TT-509 / TT-512).
 */
@Configuration
public class GatewayEdgeFilters {

    public static final String REQUEST_ID_HEADER = "X-Request-Id";

    @Bean
    public CorsWebFilter corsWebFilter(
            @Value("${GATEWAY_CORS_ORIGINS:http://localhost:5173,http://127.0.0.1:5173,http://localhost:8080}")
            String origins) {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(
                Arrays.stream(origins.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .collect(Collectors.toList()));
        config.addAllowedHeader("*");
        config.addAllowedMethod(HttpMethod.GET);
        config.addAllowedMethod(HttpMethod.POST);
        config.addAllowedMethod(HttpMethod.PUT);
        config.addAllowedMethod(HttpMethod.DELETE);
        config.addAllowedMethod(HttpMethod.PATCH);
        config.addAllowedMethod(HttpMethod.OPTIONS);
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsWebFilter(source);
    }

    @Bean
    public GlobalFilter requestIdFilter() {
        return new RequestIdGlobalFilter();
    }

    static final class RequestIdGlobalFilter implements GlobalFilter, Ordered {
        @Override
        public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
            String incoming = exchange.getRequest().getHeaders().getFirst(REQUEST_ID_HEADER);
            String requestId = (incoming == null || incoming.trim().isEmpty())
                    ? UUID.randomUUID().toString()
                    : incoming.trim();

            ServerHttpRequest request = exchange.getRequest().mutate()
                    .header(REQUEST_ID_HEADER, requestId)
                    .build();
            exchange.getResponse().getHeaders().set(REQUEST_ID_HEADER, requestId);
            HttpHeaders resp = exchange.getResponse().getHeaders();
            if (!resp.getAccessControlExposeHeaders().contains(REQUEST_ID_HEADER)) {
                resp.add(HttpHeaders.ACCESS_CONTROL_EXPOSE_HEADERS, REQUEST_ID_HEADER);
            }
            return chain.filter(exchange.mutate().request(request).build());
        }

        @Override
        public int getOrder() {
            return Ordered.HIGHEST_PRECEDENCE + 10;
        }
    }
}
