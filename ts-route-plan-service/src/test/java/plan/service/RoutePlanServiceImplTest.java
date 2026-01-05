package plan.service;

import edu.fudan.common.entity.Trip;
import edu.fudan.common.entity.TripResponse;
import edu.fudan.common.entity.TripAllDetail;
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
import edu.fudan.common.entity.RoutePlanInfo;
import edu.fudan.common.entity.Route;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;

@RunWith(JUnit4.class)
public class RoutePlanServiceImplTest {

    @InjectMocks
    private RoutePlanServiceImpl routePlanServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    private HttpHeaders headers = new HttpHeaders();

    // Service host and port constants
    private static final String routeServiceHost = "ts-route-service";
    private static final int routeServicePort = 11178;
    private static final String travelServiceHost = "ts-travel-service";
    private static final int travelServicePort = 12346;
    private static final String travel2ServiceHost = "ts-travel2-service";
    private static final int travel2ServicePort = 16346;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Inject service host and port properties
        ReflectionTestUtils.setField(routePlanServiceImpl, "routeServiceHost", routeServiceHost);
        ReflectionTestUtils.setField(routePlanServiceImpl, "routeServicePort", routeServicePort);
        ReflectionTestUtils.setField(routePlanServiceImpl, "travelServiceHost", travelServiceHost);
        ReflectionTestUtils.setField(routePlanServiceImpl, "travelServicePort", travelServicePort);
        ReflectionTestUtils.setField(routePlanServiceImpl, "travel2ServiceHost", travel2ServiceHost);
        ReflectionTestUtils.setField(routePlanServiceImpl, "travel2ServicePort", travel2ServicePort);
    }

    @Test
    public void testSearchCheapestResult() {
        RoutePlanInfo info = new RoutePlanInfo("form_station", "to_station", "", 1);
        //mock getTripFromHighSpeedTravelServive() and getTripFromNormalTrainTravelService()
        ArrayList<TripResponse> tripResponses = new ArrayList<>();
        Response<ArrayList<TripResponse>> response1 = new Response<>(null, null, tripResponses);
        ResponseEntity<Response<ArrayList<TripResponse>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1);
        Response result = routePlanServiceImpl.searchCheapestResult(info, headers);
        Assert.assertEquals(new Response<>(1, "Success", new ArrayList<>()), result);
    }

    @Test
    public void testSearchQuickestResult() {
        RoutePlanInfo info = new RoutePlanInfo("form_station", "to_station", "", 1);
        //mock getTripFromHighSpeedTravelServive() and getTripFromNormalTrainTravelService()
        ArrayList<TripResponse> tripResponses = new ArrayList<>();
        Response<ArrayList<TripResponse>> response1 = new Response<>(null, null, tripResponses);
        ResponseEntity<Response<ArrayList<TripResponse>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1);
        Response result = routePlanServiceImpl.searchQuickestResult(info, headers);
        Assert.assertEquals(new Response<>(1, "Success", new ArrayList<>()), result);
    }

    @Test
    public void testSearchMinStopStations() {
        RoutePlanInfo info = new RoutePlanInfo("form_station", "to_station", "", 1);

        // Create a route with stations for the first call
        Route route = new Route();
        route.setId("route-1");
        route.setStations(Arrays.asList("form_station", "to_station"));
        ArrayList<Route> routeArrayList = new ArrayList<>();
        routeArrayList.add(route);
        Response<ArrayList<Route>> response1 = new Response<>(1, null, routeArrayList);
        ResponseEntity<Response<ArrayList<Route>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);

        // Create trips for travel service calls
        Trip trip = new Trip();
        trip.setTripId(new edu.fudan.common.entity.TripId("G1234"));
        trip.setRouteId("route-1");
        ArrayList<Trip> tripList = new ArrayList<>();
        tripList.add(trip);
        ArrayList<ArrayList<Trip>> tripLists = new ArrayList<>();
        tripLists.add(tripList);
        Response<ArrayList<ArrayList<Trip>>> response2 = new Response<>(1, null, tripLists);
        ResponseEntity<Response<ArrayList<ArrayList<Trip>>>> re2 = new ResponseEntity<>(response2, HttpStatus.OK);

        // Create TripAllDetail for trip detail calls
        TripResponse tripResponse = new TripResponse();
        tripResponse.setTrainTypeName("G");
        tripResponse.setStartStation("form_station");
        tripResponse.setTerminalStation("to_station");
        tripResponse.setStartTime("08:00");
        tripResponse.setEndTime("10:00");
        tripResponse.setPriceForConfortClass("100.0");
        tripResponse.setPriceForEconomyClass("50.0");
        TripAllDetail tripAllDetail = new TripAllDetail();
        tripAllDetail.setTripResponse(tripResponse);
        Response<TripAllDetail> response3 = new Response<>(1, null, tripAllDetail);
        ResponseEntity<Response<TripAllDetail>> re3 = new ResponseEntity<>(response3, HttpStatus.OK);

        // Create route for getRouteByRouteId calls
        Route routeForId = new Route();
        routeForId.setId("route-1");
        routeForId.setStations(Arrays.asList("form_station", "to_station"));
        Response<Route> response4 = new Response<>(1, null, routeForId);
        ResponseEntity<Response<Route>> re4 = new ResponseEntity<>(response4, HttpStatus.OK);

        // Mock the calls in order:
        // 1. Get routes (first call)
        // 2. Get trips from travel service (second call)
        // 3. Get trips from travel2 service (third call)
        // 4. Get trip details (multiple calls in loop)
        // 5. Get route by routeId (multiple calls in loop)
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1)  // First call: get routes
                .thenReturn(re2)  // Second call: get trips from travel service
                .thenReturn(re2)  // Third call: get trips from travel2 service
                .thenReturn(re3)  // Fourth call: get trip detail
                .thenReturn(re4)  // Fifth call: get route by routeId
                .thenReturn(re3)  // Additional trip detail calls if needed
                .thenReturn(re4); // Additional route calls if needed

        Response result = routePlanServiceImpl.searchMinStopStations(info, headers);
        Assert.assertEquals("Success.", result.getMsg());
    }

}
