package edu.fudan.common.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author fdse
 */
@Configuration
public class SwaggerConfig {

    @Value("${swagger.controllerPackage}")
    private String controllerPackagePath;

    private static final Logger LOGGER = LoggerFactory.getLogger(SwaggerConfig.class);

    @Bean
    public GroupedOpenApi createRestApi() {
        SwaggerConfig.LOGGER.info("[createRestApi][create][controllerPackagePath: {}]", controllerPackagePath);
        return GroupedOpenApi.builder()
                .group("train-ticket")
                .packagesToScan(controllerPackagePath)
                .build();
    }

    @Bean
    public OpenAPI trainTicketOpenApi() {
        return new OpenAPI().info(new Info()
                .title("TrainTicket API")
                .description("TrainTicket service REST API")
                .termsOfService("https://github.com/FudanSELab/train-ticket")
                .version("1.0"));
    }

}
