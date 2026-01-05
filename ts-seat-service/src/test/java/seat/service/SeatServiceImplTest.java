package seat.service;

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
import edu.fudan.common.entity.*;

import java.util.ArrayList;

@RunWith(JUnit4.class)
public class SeatServiceImplTest {

    @InjectMocks
    private SeatServiceImpl seatServiceImpl;

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
    private static final String configServiceHost = "ts-config-service";
    private static final int configServicePort = 15679;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Inject service host and port properties
        ReflectionTestUtils.setField(seatServiceImpl, "orderServiceHost", orderServiceHost);
        ReflectionTestUtils.setField(seatServiceImpl, "orderServicePort", orderServicePort);
        ReflectionTestUtils.setField(seatServiceImpl, "orderOtherServiceHost", orderOtherServiceHost);
        ReflectionTestUtils.setField(seatServiceImpl, "orderOtherServicePort", orderOtherServicePort);
        ReflectionTestUtils.setField(seatServiceImpl, "configServiceHost", configServiceHost);
        ReflectionTestUtils.setField(seatServiceImpl, "configServicePort", configServicePort);
    }

    @Test
    public void testDistributeSeat1() {
        Seat seat = new Seat();
        seat.setTrainNumber("G");
        seat.setSeatType(2);
        seat.setStartStation("start_station");
        seat.setDestStation("dest_station");
        seat.setStations(new ArrayList<>());
        seat.setTotalNum(100);

        LeftTicketInfo leftTicketInfo = new LeftTicketInfo();
        leftTicketInfo.setSoldTickets(new java.util.HashSet<>());
        Response<LeftTicketInfo> response = new Response<>(1, null, leftTicketInfo);
        ResponseEntity<Response<LeftTicketInfo>> re = new ResponseEntity<>(response, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re);
        Response result = seatServiceImpl.distributeSeat(seat, headers);
        Assert.assertEquals("Use a new seat number!", result.getMsg());
    }

    @Test
    public void testDistributeSeat2() {
        Seat seat = new Seat();
        seat.setTrainNumber("K");
        seat.setSeatType(3);
        seat.setStartStation("start_station");
        seat.setDestStation("dest_station");
        seat.setStations(new ArrayList<>());
        seat.setTotalNum(100);

        LeftTicketInfo leftTicketInfo = new LeftTicketInfo();
        leftTicketInfo.setSoldTickets(new java.util.HashSet<>());
        Response<LeftTicketInfo> response = new Response<>(1, null, leftTicketInfo);
        ResponseEntity<Response<LeftTicketInfo>> re = new ResponseEntity<>(response, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re);
        Response result = seatServiceImpl.distributeSeat(seat, headers);
        Assert.assertEquals("Use a new seat number!", result.getMsg());
    }

    @Test
    public void testGetLeftTicketOfInterval() {
        Seat seat = new Seat();
        seat.setTrainNumber("G");
        seat.setSeatType(2);
        seat.setStartStation("start_station");
        seat.setDestStation("dest_station");
        ArrayList<String> stations = new ArrayList<>();
        stations.add("start_place");
        seat.setStations(stations);
        seat.setTotalNum(100);

        LeftTicketInfo leftTicketInfo = new LeftTicketInfo();
        leftTicketInfo.setSoldTickets(new java.util.HashSet<>());
        Response<LeftTicketInfo> response1 = new Response<>(1, null, leftTicketInfo);
        ResponseEntity<Response<LeftTicketInfo>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        Config config = new Config();
        config.setValue("0.5");
        Response<Config> response2 = new Response<>(1, null, config);
        ResponseEntity<Response<Config>> re2 = new ResponseEntity<>(response2, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1).thenReturn(re2);
        Response result = seatServiceImpl.getLeftTicketOfInterval(seat, headers);
        Assert.assertEquals("Get Left Ticket of Internal Success", result.getMsg());
    }

    @Test
    public void testGetLeftTicketOfInterva2() {
        Seat seat = new Seat();
        seat.setTrainNumber("K");
        seat.setSeatType(3);
        seat.setStartStation("start_station");
        seat.setDestStation("dest_station");
        ArrayList<String> stations = new ArrayList<>();
        stations.add("start_place");
        seat.setStations(stations);
        seat.setTotalNum(100);

        LeftTicketInfo leftTicketInfo = new LeftTicketInfo();
        leftTicketInfo.setSoldTickets(new java.util.HashSet<>());
        Response<LeftTicketInfo> response1 = new Response<>(1, null, leftTicketInfo);
        ResponseEntity<Response<LeftTicketInfo>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        Config config = new Config();
        config.setValue("0.5");
        Response<Config> response2 = new Response<>(1, null, config);
        ResponseEntity<Response<Config>> re2 = new ResponseEntity<>(response2, HttpStatus.OK);

        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1).thenReturn(re2);
        Response result = seatServiceImpl.getLeftTicketOfInterval(seat, headers);
        Assert.assertEquals("Get Left Ticket of Internal Success", result.getMsg());
    }

}
