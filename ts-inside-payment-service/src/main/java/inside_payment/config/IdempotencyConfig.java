package inside_payment.config;

import edu.fudan.common.idempotency.IdempotencyGuard;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.time.Duration;

@Configuration
public class IdempotencyConfig {

    @Bean
    public IdempotencyGuard idempotencyGuard(StringRedisTemplate redisTemplate) {
        return new IdempotencyGuard(redisTemplate, Duration.ofMinutes(10));
    }
}
