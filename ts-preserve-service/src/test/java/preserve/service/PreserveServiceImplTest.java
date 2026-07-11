package preserve.service;

import edu.fudan.common.idempotency.IdempotencyGuard;
import edu.fudan.common.util.Response;
import edu.fudan.common.util.StringUtils;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.cloud.client.circuitbreaker.CircuitBreaker;
import org.springframework.cloud.client.circuitbreaker.CircuitBreakerFactory;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;
import preserve.mq.RabbitSend;
import edu.fudan.common.entity.*;

import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import java.util.function.Supplier;

@RunWith(JUnit4.class)
public class PreserveServiceImplTest {

    @InjectMocks
    private PreserveServiceImpl preserveServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    @Mock
    private RabbitSend sendService;

    @Mock
    private IdempotencyGuard idempotencyGuard;

    @Mock
    private CircuitBreakerFactory circuitBreakerFactory;

    @Mock
    private CircuitBreaker circuitBreaker;

    private static final String basicServiceHost = "ts-basic-service";
    private static final int basicServicePort = 15678;
    private static final String seatServiceHost = "ts-seat-service";
    private static final int seatServicePort = 18898;
    private static final String userServiceHost = "ts-user-service";
    private static final int userServicePort = 12342;
    private static final String assuranceServiceHost = "ts-assurance-service";
    private static final int assuranceServicePort = 18888;
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;
    private static final String securityServiceHost = "ts-security-service";
    private static final int securityServicePort = 18889;
    private static final String travelServiceHost = "ts-travel-service";
    private static final int travelServicePort = 12346;
    private static final String contactsServiceHost = "ts-contacts-service";
    private static final int contactsServicePort = 12003;
    private static final String orderServiceHost = "ts-order-service";
    private static final int orderServicePort = 12031;
    private static final String foodServiceHost = "ts-food-service";
    private static final int foodServicePort = 18856;
    private static final String consignServiceHost = "ts-consign-service";
    private static final int consignServicePort = 16111;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        ReflectionTestUtils.setField(preserveServiceImpl, "basicServiceHost", basicServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "basicServicePort", basicServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "seatServiceHost", seatServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "seatServicePort", seatServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "userServiceHost", userServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "userServicePort", userServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "assuranceServiceHost", assuranceServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "assuranceServicePort", assuranceServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "stationServicePort", stationServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "securityServiceHost", securityServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "securityServicePort", securityServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "travelServiceHost", travelServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "travelServicePort", travelServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "contactsServiceHost", contactsServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "contactsServicePort", contactsServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "orderServiceHost", orderServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "orderServicePort", orderServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "foodServiceHost", foodServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "foodServicePort", foodServicePort);
        ReflectionTestUtils.setField(preserveServiceImpl, "consignServiceHost", consignServiceHost);
        ReflectionTestUtils.setField(preserveServiceImpl, "consignServicePort", consignServicePort);

        Mockito.when(idempotencyGuard.reserve(Mockito.anyString())).thenReturn(true);
        Mockito.when(idempotencyGuard.getCachedResult(Mockito.anyString())).thenReturn(Optional.empty());
        Mockito.when(circuitBreakerFactory.create(Mockito.anyString())).thenReturn(circuitBreaker);
        Mockito.when(circuitBreaker.run(Mockito.any(Supplier.class), Mockito.any(Function.class)))
                .thenAnswer(invocation -> ((Supplier) invocation.getArgument(0)).get());
    }

    @Test
    public void testPreserve() {
        OrderTicketsInfo oti = OrderTicketsInfo.builder()
                .accountId(UUID.randomUUID().toString())
                .contactsId(UUID.randomUUID().toString())
                .from("from_station")
                .to("to_station")
                .date(StringUtils.Date2String(new Date()))
                .handleDate("handle_date")
                .tripId("G1255")
                .seatType(2)
                .assurance(1)
                .foodType(1)
                .foodName("food_name")
                .foodPrice(1.0)
                .stationName("station_name")
                .storeName("store_name")
                .consigneeName("consignee_name")
                .consigneePhone("123456789")
                .consigneeWeight(1.0)
                .isWithin(true)
                .build();

        //response for checkSecurity()、addAssuranceForOrder()、createFoodOrder()、createConsign()
        Response response1 = new Response<>(1, null, null);
        ResponseEntity<Response> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(Class.class)))
                .thenReturn(re1).thenReturn(re1).thenReturn(re1).thenReturn(re1);


        //response for getContactsById()
        Contacts contacts = new Contacts();
        contacts.setDocumentNumber("document_number");
        contacts.setName("name");
        contacts.setDocumentType(1);
        Response<Contacts> response2 = new Response<>(1, null, contacts);
        ResponseEntity<Response<Contacts>> re2 = new ResponseEntity<>(response2, HttpStatus.OK);

        //response for getTripAllDetailInformation()
        TripResponse tripResponse = new TripResponse();
        tripResponse.setConfortClass(1);
        tripResponse.setStartTime(StringUtils.Date2String(new Date()));
        TripAllDetail tripAllDetail = new TripAllDetail(true, "message", tripResponse, new Trip());
        Response<TripAllDetail> response3 = new Response<>(1, null, tripAllDetail);
        ResponseEntity<Response<TripAllDetail>> re3 = new ResponseEntity<>(response3, HttpStatus.OK);

        //response for travel result
        TravelResult travelResult = new TravelResult();
        travelResult.setPrices( new HashMap<String, String>(){{ put("confortClass", "1.0"); put("economyClass", "0.75"); }} );
        
        // Create Route with stations
        Route route = new Route();
        route.setStations(Arrays.asList("from_station", "to_station"));
        route.setDistances(Arrays.asList(0, 100));
        travelResult.setRoute(route);
        
        // Create TrainType
        TrainType trainType = new TrainType();
        trainType.setConfortClass(50);
        trainType.setEconomyClass(100);
        travelResult.setTrainType(trainType);
        
        Response<TravelResult> response5 = new Response<>(1, null, travelResult);
        ResponseEntity<Response<TravelResult>> re5 = new ResponseEntity<>(response5, HttpStatus.OK);

        //response for dipatchSeat()
        Ticket ticket = new Ticket();
        ticket.setSeatNo(1);
        Response<Ticket> response6 = new Response<>(1, null, ticket);
        ResponseEntity<Response<Ticket>> re6 = new ResponseEntity<>(response6, HttpStatus.OK);

        //response for createOrder()
        Order order = new Order();
        order.setId(UUID.randomUUID().toString());
        order.setAccountId(UUID.randomUUID().toString());
        order.setTravelDate(StringUtils.Date2String(new Date()));
        order.setFrom("from_station");
        order.setTo("to_station");
        Response<Order> response7 = new Response<>(1, null, order);
        ResponseEntity<Response<Order>> re7 = new ResponseEntity<>(response7, HttpStatus.OK);

        //response for getAccount()
        User user = new User();
        user.setEmail("email");
        user.setUserName("user_name");
        Response<User> response9 = new Response<>(1, null, user);
        ResponseEntity<Response<User>> re9 = new ResponseEntity<>(response9, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re2).thenReturn(re3).thenReturn(re5).thenReturn(re6).thenReturn(re7).thenReturn(re9);

        Response result = preserveServiceImpl.preserve(oti, headers);
        Assert.assertEquals(new Response<>(1, "Success.", null), result);
    }

    @Test
    public void testDipatchSeat() {
        long mills = System.currentTimeMillis();
        Seat seatRequest = new Seat(StringUtils.Date2String(new Date()), "G1234", "start_station", "dest_station", 2, 100, null);
        HttpEntity requestEntityTicket = new HttpEntity(seatRequest, headers);
        Response<Ticket> response = new Response<>();
        ResponseEntity<Response<Ticket>> reTicket = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class))).thenReturn(reTicket);
        Ticket result = preserveServiceImpl.dipatchSeat(StringUtils.Date2String(new Date()), "G1234", "start_station", "dest_station", 2, 100, null, headers);
        Assert.assertNull(result);
    }

    @Test
    public void testSendEmail() {
        NotifyInfo notifyInfo = new NotifyInfo();
        Mockito.doNothing().when(sendService).send(Mockito.anyString());
        boolean result = preserveServiceImpl.sendEmail(notifyInfo, headers);
        Assert.assertTrue(result);
        Mockito.verify(sendService, Mockito.times(1)).send(Mockito.anyString());
    }

    @Test
    public void testGetAccount() {
        User user = new User();
        user.setEmail("test@example.com");
        user.setUserName("testuser");
        Response<User> response = new Response<>(1, null, user);
        ResponseEntity<Response<User>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class))).thenReturn(re);
        User result = preserveServiceImpl.getAccount("1", headers);
        Assert.assertNotNull(result);
        Assert.assertEquals("test@example.com", result.getEmail());
        Assert.assertEquals("testuser", result.getUserName());
    }

}
