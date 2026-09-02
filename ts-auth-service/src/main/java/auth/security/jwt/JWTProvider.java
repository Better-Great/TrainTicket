package auth.security.jwt;

import auth.constant.InfoConstant;
import auth.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;

/**
 * Issues JWTs. Must use the same raw secret as {@code edu.fudan.common.security.jwt.JWTUtil}
 * ({@code JWT_SECRET} / {@code jwt.secret}).
 */
@Component
public class JWTProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(JWTProvider.class);
    private static final String DEFAULT_SECRET = "secret";

    @Value("${JWT_SECRET:${jwt.secret:secret}}")
    private String secretKey;

    @Value("${jwt.validity-ms:3600000}")
    private long validityInMilliseconds;

    @PostConstruct
    protected void init() {
        if (secretKey == null || secretKey.trim().isEmpty()) {
            secretKey = DEFAULT_SECRET;
        }
        secretKey = secretKey.trim();
        if (DEFAULT_SECRET.equals(secretKey)) {
            LOGGER.warn("[JWT] Using default secret — set JWT_SECRET for non-local use");
        }
        secretKey = Base64.getEncoder().encodeToString(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    public String createToken(User user) {

        Claims claims = Jwts.claims().setSubject(user.getUsername());
        claims.put(InfoConstant.ROLES, user.getRoles());
        claims.put(InfoConstant.ID, user.getUserId());

        Date now = new Date();
        Date validate = new Date(now.getTime() + validityInMilliseconds);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(validate)
                .signWith(SignatureAlgorithm.HS256, secretKey)
                .compact();
    }
}
