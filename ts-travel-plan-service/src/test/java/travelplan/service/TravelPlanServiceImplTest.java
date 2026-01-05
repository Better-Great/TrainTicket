package travelplan.service;

import edu.fudan.common.entity.TrainType;
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
import travelplan.entity.TransferTravelInfo;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@RunWith(JUnit4.class)
public class TravelPlanServiceImplTest {

    @InjectMocks
    private TravelPlanServiceImpl travelPlanServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private static final String seatServiceHost = "ts-seat-service";
    private static final int seatServicePort = 18898;
    private static final String routePlanServiceHost = "ts-route-plan-service";
    private static final int routePlanServicePort = 14578;
    private static final String travelServiceHost = "ts-travel-service";
    private static final int travelServicePort = 12346;
    private static final String travel2ServiceHost = "ts-travel2-service";
    private static final int travel2ServicePort = 16346;
    private static final String trainServiceHost = "ts-train-service";
    private static final int trainServicePort = 14567;

    private HttpHeaders headers = new HttpHeaders();

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "seatServiceHost", seatServiceHost);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "seatServicePort", seatServicePort);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "routePlanServiceHost", routePlanServiceHost);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "routePlanServicePort", routePlanServicePort);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "travelServiceHost", travelServiceHost);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "travelServicePort", travelServicePort);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "travel2ServiceHost", travel2ServiceHost);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "travel2ServicePort", travel2ServicePort);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "trainServiceHost", trainServiceHost);
        ReflectionTestUtils.setField(travelPlanServiceImpl, "trainServicePort", trainServicePort);
    }

    @Test
    public void testGetTransferSearch() {
        TransferTravelInfo info = new TransferTravelInfo("from_station", "", "to_station", "", "G");

        //mock tripsFromHighSpeed() and tripsFromNormal() - 4 calls total (2 for first section, 2 for second section)
        List<TripResponse> tripResponseList = new ArrayList<>();
        Response<List<TripResponse>> response1 = new Response<>(1, "Success", tripResponseList);
        ResponseEntity<Response<List<TripResponse>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);
        
        ArrayList<TripResponse> tripResponseArrayList = new ArrayList<>();
        Response<ArrayList<TripResponse>> response2 = new Response<>(1, "Success", tripResponseArrayList);
        ResponseEntity<Response<ArrayList<TripResponse>>> re2 = new ResponseEntity<>(response2, HttpStatus.OK);
        
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1) // First call: tripsFromHighSpeed for first section
                .thenReturn(re2) // Second call: tripsFromNormal for first section
                .thenReturn(re1) // Third call: tripsFromHighSpeed for second section
                .thenReturn(re2); // Fourth call: tripsFromNormal for second section
        
        Response result = travelPlanServiceImpl.getTransferSearch(info, headers);
        Assert.assertEquals("Success.", result.getMsg());
    }

    @Test
    public void testGetCheapest() {
        TripInfo info = new TripInfo("start_station", "end_station", "");

        //response for getRoutePlanResultCheapest()
        RoutePlanResultUnit rpru = new RoutePlanResultUnit("trip_id", "type_id", "from_station", "to_station", new ArrayList<>(), "1.0", "2.0", "", "");
        ArrayList<RoutePlanResultUnit> routePlanResultUnits = new ArrayList<RoutePlanResultUnit>(){{ add(rpru); }};
        Response<ArrayList<RoutePlanResultUnit>> response1 = new Response<>(1, "Success", routePlanResultUnits);
        ResponseEntity<Response<ArrayList<RoutePlanResultUnit>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        //response for queryTrainTypeByName() - GET request to train service
        TrainType trainType = new TrainType();
        trainType.setName("type_id");
        trainType.setConfortClass(100);
        trainType.setEconomyClass(200);
        Response trainTypeResponse = new Response<>(1, "Success", trainType);
        ResponseEntity<Response> reTrainType = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);

        //response for getRestTicketNumber()
        Response<Integer> response4 = new Response<>(1, "Success", 50);
        ResponseEntity<Response<Integer>> re4 = new ResponseEntity<>(response4, HttpStatus.OK);

        // Mock for queryTrainTypeByName (uses Response.class, not ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class)))
                .thenReturn(reTrainType);

        // Mock for other exchange calls (uses ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1) // First call: getRoutePlanResultCheapest
                .thenReturn(re4) // Second call: getRestTicketNumber for first class
                .thenReturn(re4); // Third call: getRestTicketNumber for second class

        Response result = travelPlanServiceImpl.getCheapest(info, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testGetQuickest() {
        TripInfo info = new TripInfo("start_station", "end_station", "");

        //response for getRoutePlanResultQuickest()
        RoutePlanResultUnit rpru = new RoutePlanResultUnit("trip_id", "type_id", "from_station", "to_station", new ArrayList<>(), "1.0", "2.0", "", "");
        ArrayList<RoutePlanResultUnit> routePlanResultUnits = new ArrayList<RoutePlanResultUnit>(){{ add(rpru); }};
        Response<ArrayList<RoutePlanResultUnit>> response1 = new Response<>(1, "Success", routePlanResultUnits);
        ResponseEntity<Response<ArrayList<RoutePlanResultUnit>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        //response for queryTrainTypeByName() - GET request to train service
        TrainType trainType = new TrainType();
        trainType.setName("type_id");
        trainType.setConfortClass(100);
        trainType.setEconomyClass(200);
        Response trainTypeResponse = new Response<>(1, "Success", trainType);
        ResponseEntity<Response> reTrainType = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);

        //response for getRestTicketNumber()
        Response<Integer> response4 = new Response<>(1, "Success", 50);
        ResponseEntity<Response<Integer>> re4 = new ResponseEntity<>(response4, HttpStatus.OK);

        // Mock for queryTrainTypeByName (uses Response.class, not ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class)))
                .thenReturn(reTrainType);

        // Mock for other exchange calls (uses ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1) // First call: getRoutePlanResultQuickest
                .thenReturn(re4) // Second call: getRestTicketNumber for first class
                .thenReturn(re4); // Third call: getRestTicketNumber for second class

        Response result = travelPlanServiceImpl.getQuickest(info, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testGetMinStation() {
        TripInfo info = new TripInfo("start_station", "end_station", "");

        //response for getRoutePlanResultMinStation()
        RoutePlanResultUnit rpru = new RoutePlanResultUnit("trip_id", "type_id", "from_station", "to_station", new ArrayList<>(), "1.0", "2.0", "", "");
        ArrayList<RoutePlanResultUnit> routePlanResultUnits = new ArrayList<RoutePlanResultUnit>(){{ add(rpru); }};
        Response<ArrayList<RoutePlanResultUnit>> response1 = new Response<>(1, "Success", routePlanResultUnits);
        ResponseEntity<Response<ArrayList<RoutePlanResultUnit>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        //response for queryTrainTypeByName() - GET request to train service
        TrainType trainType = new TrainType();
        trainType.setName("type_id");
        trainType.setConfortClass(100);
        trainType.setEconomyClass(200);
        Response trainTypeResponse = new Response<>(1, "Success", trainType);
        ResponseEntity<Response> reTrainType = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);

        //response for getRestTicketNumber()
        Response<Integer> response4 = new Response<>(1, "Success", 50);
        ResponseEntity<Response<Integer>> re4 = new ResponseEntity<>(response4, HttpStatus.OK);

        // Mock for queryTrainTypeByName (uses Response.class, not ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class)))
                .thenReturn(reTrainType);

        // Mock for other exchange calls (uses ParameterizedTypeReference)
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1) // First call: getRoutePlanResultMinStation
                .thenReturn(re4) // Second call: getRestTicketNumber for first class
                .thenReturn(re4); // Third call: getRestTicketNumber for second class

        Response result = travelPlanServiceImpl.getMinStation(info, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

}
