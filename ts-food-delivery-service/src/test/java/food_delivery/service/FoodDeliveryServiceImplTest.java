package food_delivery.service;

import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

public class FoodDeliveryServiceImplTest {
    @InjectMocks
    private FoodDeliveryServiceImpl foodDeliveryServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private static final String stationFoodServiceHost = "ts-station-food-service";
    private static final int stationFoodServicePort = 18855;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        ReflectionTestUtils.setField(foodDeliveryServiceImpl, "stationFoodServiceHost", stationFoodServiceHost);
        ReflectionTestUtils.setField(foodDeliveryServiceImpl, "stationFoodServicePort", stationFoodServicePort);
    }

}
