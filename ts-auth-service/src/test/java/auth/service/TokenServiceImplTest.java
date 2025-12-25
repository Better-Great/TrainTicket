package auth.service;

import auth.dto.BasicAuthDto;
import auth.entity.User;
import auth.exception.UserOperationException;
import auth.repository.UserRepository;
import auth.security.jwt.JWTProvider;
import auth.service.impl.TokenServiceImpl;
import edu.fudan.common.util.Response;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.http.*;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.util.Optional;

@RunWith(JUnit4.class)
public class TokenServiceImplTest {

    // Service host and port from properties/dev.application.ini (matching property names)
    private static final String verificationCodeServiceHost = "ts-verification-code-service";
    private static final int verificationCodeServicePort = 15678;

    @InjectMocks
    private TokenServiceImpl tokenServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private UserRepository userRepository;

    @Mock
    private JWTProvider jwtProvider;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private DiscoveryClient discoveryClient;

    private HttpHeaders headers = new HttpHeaders();
    HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Set host and port values from properties using ReflectionTestUtils
        ReflectionTestUtils.setField(tokenServiceImpl, "verificationCodeServiceHost", verificationCodeServiceHost);
        ReflectionTestUtils.setField(tokenServiceImpl, "verificationCodeServicePort", verificationCodeServicePort);
    }

    @Test
    public void testGetToken1() {
        BasicAuthDto dto = new BasicAuthDto(null, null, "verifyCode");
        ResponseEntity<Boolean> re = new ResponseEntity<>(false, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + verificationCodeServiceHost + ":" + verificationCodeServicePort + "/api/v1/verifycode/verify/" + "verifyCode",
                HttpMethod.GET,
                requestEntity,
                Boolean.class)).thenReturn(re);
        Response result = tokenServiceImpl.getToken(dto, headers);
        Assert.assertEquals(new Response<>(0, "Verification failed.", null), result);
    }

    @Test
    public void testGetToken2() throws UserOperationException {
        BasicAuthDto dto = new BasicAuthDto("username", null, "");
        User user = new User();
        Optional<User> optionalUser = Optional.of(user);
        Mockito.when(authenticationManager.authenticate(Mockito.any(UsernamePasswordAuthenticationToken.class))).thenReturn(null);
        Mockito.when(userRepository.findByUsername("username")).thenReturn(optionalUser);
        Mockito.when(jwtProvider.createToken(user)).thenReturn("token");
        Response result = tokenServiceImpl.getToken(dto, headers);
        Assert.assertEquals("login success", result.getMsg());
    }

}
