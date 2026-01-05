package admintravel.service;

import edu.fudan.common.entity.AdminTrip;
import edu.fudan.common.entity.Route;
import edu.fudan.common.entity.TravelInfo;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RunWith(JUnit4.class)
public class AdminTravelServiceImplTest {

    // Service hosts and ports from properties/dev.application.ini (matching property names)
    private static final String travelServiceHost = "ts-travel-service";
    private static final int travelServicePort = 12346;
    private static final String travel2ServiceHost = "ts-travel2-service";
    private static final int travel2ServicePort = 16346;
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;
    private static final String trainServiceHost = "ts-train-service";
    private static final int trainServicePort = 14567;
    private static final String routeServiceHost = "ts-route-service";
    private static final int routeServicePort = 11178;

    @InjectMocks
    private AdminTravelServiceImpl adminTravelServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Set host and port values from properties using ReflectionTestUtils
        ReflectionTestUtils.setField(adminTravelServiceImpl, "travelServiceHost", travelServiceHost);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "travelServicePort", travelServicePort);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "travel2ServiceHost", travel2ServiceHost);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "travel2ServicePort", travel2ServicePort);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "stationServicePort", stationServicePort);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "trainServiceHost", trainServiceHost);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "trainServicePort", trainServicePort);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "routeServiceHost", routeServiceHost);
        ReflectionTestUtils.setField(adminTravelServiceImpl, "routeServicePort", routeServicePort);
    }

    @Test
    public void testGetAllTravels1() {
        Response<ArrayList<AdminTrip>> response = new Response<>(0, null, null);
        ResponseEntity<Response<ArrayList<AdminTrip>>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/admin_trip",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<ArrayList<AdminTrip>>>() {
                })).thenReturn(re);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/admin_trip",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<ArrayList<AdminTrip>>>() {
                })).thenReturn(re);
        Response result = adminTravelServiceImpl.getAllTravels(headers);
        Assert.assertEquals(new Response<>(0, null, new ArrayList<>()), result);
    }

    @Test
    public void testGetAllTravels2() {
        ArrayList<AdminTrip> adminTrips = new ArrayList<>();
        adminTrips.add(new AdminTrip());
        Response<ArrayList<AdminTrip>> response = new Response<>(1, null, adminTrips);
        ResponseEntity<Response<ArrayList<AdminTrip>>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/admin_trip",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<ArrayList<AdminTrip>>>() {
                })).thenReturn(re);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/admin_trip",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<ArrayList<AdminTrip>>>() {
                })).thenReturn(re);
        Response result = adminTravelServiceImpl.getAllTravels(headers);
        Assert.assertNotNull(result);
    }

    @Test
    public void testAddTravel1() {
        TravelInfo request = new TravelInfo();
        request.setTripId("G1234");
        request.setTrainTypeName("G");
        request.setRouteId("route-123");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        TrainType trainType = new TrainType("G", 100, 50);
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "G");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/G"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Route route = new Route("route-123", stations, new ArrayList<>(), "Shanghai", "Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-123");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-123"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock addTravel call
        HttpEntity requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response<>(0, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/trips",
                HttpMethod.POST,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.addTravel(request, headers);
        Assert.assertEquals(new Response<>(0, "Admin add new travel failed", null), result);
    }

    @Test
    public void testAddTravel2() {
        TravelInfo request = new TravelInfo();
        request.setTripId("G1234");
        request.setTrainTypeName("G");
        request.setRouteId("route-123");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        TrainType trainType = new TrainType("G", 100, 50);
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "G");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/G"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Route route = new Route("route-123", stations, new ArrayList<>(), "Shanghai", "Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-123");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-123"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock addTravel call
        HttpEntity<TravelInfo> requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/trips",
                HttpMethod.POST,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.addTravel(request, headers);
        Assert.assertEquals(new Response<>(1, "[Admin add new travel]", null), result);
    }

    @Test
    public void testAddTravel3() {
        TravelInfo request = new TravelInfo();
        request.setTripId("K1234");
        request.setTrainTypeName("K");
        request.setRouteId("route-456");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "K");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/K"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-456");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-456"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock addTravel call
        HttpEntity<TravelInfo> requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response<>(0, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/trips",
                HttpMethod.POST,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.addTravel(request, headers);
        Assert.assertEquals(new Response<>(0, "Admin add new travel failed", null), result);
    }

    @Test
    public void testAddTravel4() {
        TravelInfo request = new TravelInfo();
        request.setTripId("K1234");
        request.setTrainTypeName("K");
        request.setRouteId("route-456");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "K");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/K"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-456");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-456"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock addTravel call
        HttpEntity<TravelInfo> requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/trips",
                HttpMethod.POST,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.addTravel(request, headers);
        Assert.assertEquals(new Response<>(1, "[Admin add new travel]", null), result);
    }


    @Test
    public void testUpdateTravel1() {
        TravelInfo request = new TravelInfo();
        request.setTripId("G1234");
        request.setTrainTypeName("G");
        request.setRouteId("route-123");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        TrainType trainType = new TrainType("G", 100, 50);
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "G");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/G"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Route route = new Route("route-123", stations, new ArrayList<>(), "Shanghai", "Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-123");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-123"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock updateTravel call
        HttpEntity<TravelInfo> requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/trips",
                HttpMethod.PUT,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.updateTravel(request, headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testUpdateTravel2() {
        TravelInfo request = new TravelInfo();
        request.setTripId("K1234");
        request.setTrainTypeName("K");
        request.setRouteId("route-456");
        request.setStartStationName("Shanghai");
        request.setTerminalStationName("Beijing");
        
        // Mock checkStationsExists
        Map<String, String> stationMap = new HashMap<>();
        stationMap.put("Shanghai", "shanghai-id");
        stationMap.put("Beijing", "beijing-id");
        Response<Map<String, String>> stationResponse = new Response<>(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> stationRe = new ResponseEntity<>(stationResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(stationRe);
        
        // Mock queryTrainTypeByName
        Map<String, Object> trainTypeMap = new HashMap<>();
        trainTypeMap.put("id", null);
        trainTypeMap.put("name", "K");
        trainTypeMap.put("economyClass", 100);
        trainTypeMap.put("confortClass", 50);
        trainTypeMap.put("averageSpeed", 0);
        Response trainTypeResponse = new Response<>(1, null, trainTypeMap);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/trainservice/trains/byName/K"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(trainTypeRe);
        
        // Mock getRouteByRouteId
        List<String> stations = new ArrayList<>();
        stations.add("Shanghai");
        stations.add("Beijing");
        Map<String, Object> routeMap = new HashMap<>();
        routeMap.put("id", "route-456");
        routeMap.put("stations", stations);
        routeMap.put("distances", new ArrayList<>());
        routeMap.put("startStation", "Shanghai");
        routeMap.put("endStation", "Beijing");
        Response routeResponse = new Response<>(1, null, routeMap);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.contains("/api/v1/routeservice/routes/route-456"),
                Mockito.eq(HttpMethod.GET),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(routeRe);
        
        // Mock updateTravel call
        HttpEntity<TravelInfo> requestEntity2 = new HttpEntity<>(request, headers);
        Response response = new Response(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/trips",
                HttpMethod.PUT,
                requestEntity2,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.updateTravel(request, headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testDeleteTravel1() {
        Response response = new Response(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travelServiceHost + ":" + travelServicePort + "/api/v1/travelservice/trips/" + "GaoTie",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.deleteTravel("GaoTie", headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testDeleteTravel2() {
        Response response = new Response(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + travel2ServiceHost + ":" + travel2ServicePort + "/api/v1/travel2service/trips/" + "K1024",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        Response result = adminTravelServiceImpl.deleteTravel("K1024", headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

}
