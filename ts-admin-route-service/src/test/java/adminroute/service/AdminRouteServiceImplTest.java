package adminroute.service;

import edu.fudan.common.entity.Route;
import edu.fudan.common.entity.RouteInfo;
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

@RunWith(JUnit4.class)
public class AdminRouteServiceImplTest {

    // Service hosts and ports from properties/dev.application.ini (matching property names)
    private static final String routeServiceHost = "ts-route-service";
    private static final int routeServicePort = 11178;
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;

    @InjectMocks
    private AdminRouteServiceImpl adminRouteServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);
    private Response response = new Response();
    private ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Set host and port values from properties using ReflectionTestUtils
        ReflectionTestUtils.setField(adminRouteServiceImpl, "routeServiceHost", routeServiceHost);
        ReflectionTestUtils.setField(adminRouteServiceImpl, "routeServicePort", routeServicePort);
        ReflectionTestUtils.setField(adminRouteServiceImpl, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(adminRouteServiceImpl, "stationServicePort", stationServicePort);
    }

    @Test
    public void testGetAllRoutes() {
        Mockito.when(restTemplate.exchange(
                "http://" + routeServiceHost + ":" + routeServicePort + "/api/v1/routeservice/routes",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        Response result = adminRouteServiceImpl.getAllRoutes(headers);
        Assert.assertEquals(new Response<>(null, null, null), result);
    }

    @Test
    public void testCreateAndModifyRoute() {
        RouteInfo request = new RouteInfo();
        request.setStartStation("A");
        request.setEndStation("B");
        request.setStationList("A,B");
        request.setDistanceList("10,20");
        
        // Mock the checkStationsExists call (station service)
        // The response should have status 1 and data should be a Map with non-null values
        java.util.Map<String, String> stationMap = new java.util.HashMap<>();
        stationMap.put("A", "stationA");
        stationMap.put("B", "stationB");
        Response checkResponse = new Response(1, "check stations Exist succeed", stationMap);
        ResponseEntity<Response> checkRe = new ResponseEntity<>(checkResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.eq("http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/idlist"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(checkRe);
        
        // Mock the route service call
        ResponseEntity<Response<Route>> re2 = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.eq("http://" + routeServiceHost + ":" + routeServicePort + "/api/v1/routeservice/routes"),
                Mockito.eq(HttpMethod.POST),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class))).thenReturn(re2);
        Response result = adminRouteServiceImpl.createAndModifyRoute(request, headers);
        Assert.assertEquals(new Response<>(null, null, null), result);
    }

    @Test
    public void testDeleteRoute() {
        Mockito.when(restTemplate.exchange(
                "http://" + routeServiceHost + ":" + routeServicePort + "/api/v1/routeservice/routes/" + "routeId",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        Response result = adminRouteServiceImpl.deleteRoute("routeId", headers);
        Assert.assertEquals(new Response<>(null, null, null), result);
    }

}
