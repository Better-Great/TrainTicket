package edu.fudan.common.tracing;

import org.slf4j.MDC;
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;

import java.io.IOException;

/**
 * Propagates the current MDC request ID onto outbound RestTemplate calls so downstream
 * services can pick it up via {@link RequestIdFilter} and continue the same log correlation.
 */
public class RequestIdClientInterceptor implements ClientHttpRequestInterceptor {

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution)
            throws IOException {
        String requestId = MDC.get(RequestIdFilter.MDC_KEY);
        if (requestId != null && !request.getHeaders().containsKey(RequestIdFilter.HEADER_NAME)) {
            request.getHeaders().add(RequestIdFilter.HEADER_NAME, requestId);
        }
        return execution.execute(request, body);
    }
}
