package security.service;

import edu.fudan.common.entity.OrderSecurity;
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
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;
import security.entity.SecurityConfig;
import security.repository.SecurityRepository;

import java.util.ArrayList;
import java.util.Optional;
import java.util.UUID;

@RunWith(JUnit4.class)
public class SecurityServiceImplTest {

    @InjectMocks
    private SecurityServiceImpl securityServiceImpl;

    @Mock
    private SecurityRepository securityRepository;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private HttpHeaders headers = new HttpHeaders();

    // Service host and port constants
    private static final String orderServiceHost = "ts-order-service";
    private static final int orderServicePort = 12031;
    private static final String orderOtherServiceHost = "ts-order-other-service";
    private static final int orderOtherServicePort = 12032;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Inject service host and port properties
        ReflectionTestUtils.setField(securityServiceImpl, "orderServiceHost", orderServiceHost);
        ReflectionTestUtils.setField(securityServiceImpl, "orderServicePort", orderServicePort);
        ReflectionTestUtils.setField(securityServiceImpl, "orderOtherServiceHost", orderOtherServiceHost);
        ReflectionTestUtils.setField(securityServiceImpl, "orderOtherServicePort", orderOtherServicePort);
    }

    @Test
    public void testFindAllSecurityConfig1() {
        ArrayList<SecurityConfig> securityConfigs = new ArrayList<>();
        securityConfigs.add(new SecurityConfig());
        Mockito.when(securityRepository.findAll()).thenReturn(securityConfigs);
        Response result = securityServiceImpl.findAllSecurityConfig(headers);
        Assert.assertEquals(new Response<>(1, "Success", securityConfigs), result);
    }

    @Test
    public void testFindAllSecurityConfig2() {
        Mockito.when(securityRepository.findAll()).thenReturn(null);
        Response result = securityServiceImpl.findAllSecurityConfig(headers);
        Assert.assertEquals(new Response<>(0, "No Content", null), result);
    }

    @Test
    public void testAddNewSecurityConfig1() {
        SecurityConfig sc = new SecurityConfig();
        sc.setName("test_name");
        SecurityConfig existing = new SecurityConfig();
        existing.setName("test_name");
        Mockito.when(securityRepository.findByName("test_name")).thenReturn(existing);
        Response result = securityServiceImpl.addNewSecurityConfig(sc, headers);
        Assert.assertEquals(new Response<>(0, "Security Config Already Exist", null), result);
    }

    @Test
    public void testAddNewSecurityConfig2() {
        SecurityConfig sc = new SecurityConfig();
        Mockito.when(securityRepository.findByName(Mockito.anyString())).thenReturn(null);
        Mockito.when(securityRepository.save(Mockito.any(SecurityConfig.class))).thenReturn(null);
        Response result = securityServiceImpl.addNewSecurityConfig(sc, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testModifySecurityConfig1() {
        SecurityConfig sc = new SecurityConfig();
        sc.setId("test-id");
        Mockito.when(securityRepository.findById("test-id")).thenReturn(Optional.empty());
        Response result = securityServiceImpl.modifySecurityConfig(sc, headers);
        Assert.assertEquals(new Response<>(0, "Security Config Not Exist", null), result);
    }

    @Test
    public void testModifySecurityConfig2() {
        SecurityConfig sc = new SecurityConfig();
        sc.setId("test-id");
        SecurityConfig existing = new SecurityConfig();
        existing.setId("test-id");
        Mockito.when(securityRepository.findById("test-id")).thenReturn(Optional.of(existing));
        Mockito.when(securityRepository.save(Mockito.any(SecurityConfig.class))).thenReturn(existing);
        Response result = securityServiceImpl.modifySecurityConfig(sc, headers);
        Assert.assertEquals(new Response<>(1, "Success", existing), result);
    }

    @Test
    public void testDeleteSecurityConfig1() {
        String id = UUID.randomUUID().toString();
        Mockito.doNothing().when(securityRepository).deleteById(id);
        Mockito.when(securityRepository.findById(id)).thenReturn(Optional.empty());
        Response result = securityServiceImpl.deleteSecurityConfig(id, headers);
        Assert.assertEquals(new Response<>(1, "Success", id), result);
    }

    @Test
    public void testDeleteSecurityConfig2() {
        String id = UUID.randomUUID().toString();
        SecurityConfig sc = new SecurityConfig();
        sc.setId(id);
        Mockito.doNothing().when(securityRepository).deleteById(id);
        Mockito.when(securityRepository.findById(id)).thenReturn(Optional.of(sc));
        Response result = securityServiceImpl.deleteSecurityConfig(id, headers);
        Assert.assertEquals("Reason Not clear", result.getMsg());
    }

    @Test
    public void testCheck() {
        //mock getSecurityOrderInfoFromOrder() and getSecurityOrderOtherInfoFromOrder()
        OrderSecurity orderSecurity = new OrderSecurity(1, 1);
        Response<OrderSecurity> response1 = new Response<>(1, null, orderSecurity);
        ResponseEntity<Response<OrderSecurity>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1).thenReturn(re1);

        SecurityConfig configMaxInHour = new SecurityConfig();
        configMaxInHour.setValue("10");
        SecurityConfig configMaxNotUse = new SecurityConfig();
        configMaxNotUse.setValue("20");
        Mockito.when(securityRepository.findByName("max_order_1_hour")).thenReturn(configMaxInHour);
        Mockito.when(securityRepository.findByName("max_order_not_use")).thenReturn(configMaxNotUse);
        Response result = securityServiceImpl.check("account_id", headers);
        Assert.assertEquals(new Response<>(1, "Success.r", "account_id"), result);
    }

}
