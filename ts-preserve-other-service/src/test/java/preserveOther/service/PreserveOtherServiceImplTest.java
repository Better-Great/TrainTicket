package preserveOther.service;

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
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;
import preserveOther.mq.RabbitSend;
import edu.fudan.common.entity.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

@RunWith(JUnit4.class)
public class PreserveOtherServiceImplTest {

    @InjectMocks
    private PreserveOtherServiceImpl preserveOtherServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    @Mock
    private RabbitSend sendService;

    private static final String basicServiceHost = "ts-basic-service";
    private static final int basicServicePort = 15678;
    private static final String seatServiceHost = "ts-seat-service";
    private static final int seatServicePort = 18890;
    private static final String userServiceHost = "ts-user-service";
    private static final int userServicePort = 12342;
    private static final String assuranceServiceHost = "ts-assurance-service";
    private static final int assuranceServicePort = 18888;
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;
    private static final String securityServiceHost = "ts-security-service";
    private static final int securityServicePort = 18889;
    private static final String travel2ServiceHost = "ts-travel2-service";
    private static final int travel2ServicePort = 16346;
    private static final String contactsServiceHost = "ts-contacts-service";
    private static final int contactsServicePort = 12003;
    private static final String orderOtherServiceHost = "ts-order-other-service";
    private static final int orderOtherServicePort = 12032;
    private static final String foodServiceHost = "ts-food-service";
    private static final int foodServicePort = 18856;
    private static final String consignServiceHost = "ts-consign-service";
    private static final int consignServicePort = 16111;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "basicServiceHost", basicServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "basicServicePort", basicServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "seatServiceHost", seatServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "seatServicePort", seatServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "userServiceHost", userServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "userServicePort", userServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "assuranceServiceHost", assuranceServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "assuranceServicePort", assuranceServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "stationServicePort", stationServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "securityServiceHost", securityServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "securityServicePort", securityServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "travel2ServiceHost", travel2ServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "travel2ServicePort", travel2ServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "contactsServiceHost", contactsServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "contactsServicePort", contactsServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "orderOtherServiceHost", orderOtherServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "orderOtherServicePort", orderOtherServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "foodServiceHost", foodServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "foodServicePort", foodServicePort);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "consignServiceHost", consignServiceHost);
        ReflectionTestUtils.setField(preserveOtherServiceImpl, "consignServicePort", consignServicePort);
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

        //response for checkSecurity()、createFoodOrder()、createConsign()
        Response response1 = new Response<>(1, null, null);
        ResponseEntity<Response> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        //response for sendEmail()
        ResponseEntity<Boolean> re10 = new ResponseEntity<>(true, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(Class.class)))
                .thenReturn(re1).thenReturn(re1).thenReturn(re1).thenReturn(re10);


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

        //response for queryForStationId()
        Response<String> response4 = new Response<>(null, null, "");
        ResponseEntity<Response<String>> re4 = new ResponseEntity<>(response4, HttpStatus.OK);

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
        
        Response<TravelResult> response5 = new Response<>(null, null, travelResult);
        ResponseEntity<Response<TravelResult>> re5 = new ResponseEntity<>(response5, HttpStatus.OK);

        //response for dipatchSeat()
        Ticket ticket = new Ticket();
        ticket.setSeatNo(1);
        Response<Ticket> response6 = new Response<>(null, null, ticket);
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

        //response for addAssuranceForOrder()
        Response<Assurance> response8 = new Response<>(1, null, null);
        ResponseEntity<Response<Assurance>> re8 = new ResponseEntity<>(response8, HttpStatus.OK);

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
                .thenReturn(re2).thenReturn(re3).thenReturn(re4).thenReturn(re4).thenReturn(re5).thenReturn(re6).thenReturn(re7).thenReturn(re8).thenReturn(re9);

        Response result = preserveOtherServiceImpl.preserve(oti, headers);
        Assert.assertEquals(new Response<>(1, "Success.", null), result);
    }

    @Test
    public void testDipatchSeat() {
        long mills = System.currentTimeMillis();
        Seat seatRequest = new Seat(StringUtils.Date2String(new Date()), "G1234", "start_station", "dest_station", 2, 100, null);
        HttpEntity requestEntityTicket = new HttpEntity<>(seatRequest, headers);
        Response<Ticket> response = new Response<>();
        ResponseEntity<Response<Ticket>> reTicket = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + seatServiceHost + ":" + seatServicePort + "/api/v1/seatservice/seats",
                HttpMethod.POST,
                requestEntityTicket,
                new ParameterizedTypeReference<Response<Ticket>>() {
                })).thenReturn(reTicket);
        Ticket result = preserveOtherServiceImpl.dipatchSeat(StringUtils.Date2String(new Date()), "G1234", "start_station", "dest_station", 2, 100, null, headers);
        Assert.assertNull(result);
    }

    @Test
    public void testSendEmail() {
        NotifyInfo notifyInfo = new NotifyInfo();
        // sendEmail uses RabbitMQ sendService, not RestTemplate
        Mockito.doNothing().when(sendService).send(Mockito.anyString());
        boolean result = preserveOtherServiceImpl.sendEmail(notifyInfo, headers);
        Assert.assertTrue(result);
        Mockito.verify(sendService, Mockito.times(1)).send(Mockito.anyString());
    }

    @Test
    public void testGetAccount() {
        Response<User> response = new Response<>();
        ResponseEntity<Response<User>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + userServiceHost + ":" + userServicePort + "/api/v1/userservice/users/id/1",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<User>>() {
                })).thenReturn(re);
        User result = preserveOtherServiceImpl.getAccount("1", headers);
        Assert.assertNull(result);
    }

}
