package fdse.microservice.service;

import edu.fudan.common.entity.*;
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
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.Date;
import java.util.UUID;

@RunWith(JUnit4.class)
public class BasicServiceImplTest {

    @InjectMocks
    private BasicServiceImpl basicServiceImpl;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private DiscoveryClient discoveryClient;

    // Service hosts and ports from properties/dev.application.ini (matching property names)
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;
    private static final String trainServiceHost = "ts-train-service";
    private static final int trainServicePort = 14567;
    private static final String routeServiceHost = "ts-route-service";
    private static final int routeServicePort = 11178;
    private static final String priceServiceHost = "ts-price-service";
    private static final int priceServicePort = 16579;

    private HttpHeaders headers = new HttpHeaders();
    private HttpEntity requestEntity = new HttpEntity(headers);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        // Set host and port values from properties using ReflectionTestUtils
        ReflectionTestUtils.setField(basicServiceImpl, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(basicServiceImpl, "stationServicePort", stationServicePort);
        ReflectionTestUtils.setField(basicServiceImpl, "trainServiceHost", trainServiceHost);
        ReflectionTestUtils.setField(basicServiceImpl, "trainServicePort", trainServicePort);
        ReflectionTestUtils.setField(basicServiceImpl, "routeServiceHost", routeServiceHost);
        ReflectionTestUtils.setField(basicServiceImpl, "routeServicePort", routeServicePort);
        ReflectionTestUtils.setField(basicServiceImpl, "priceServiceHost", priceServiceHost);
        ReflectionTestUtils.setField(basicServiceImpl, "priceServicePort", priceServicePort);
    }

    @Test
    public void testQueryForTravel() {
        Trip trip = new Trip();
        trip.setTripId(new TripId());
        trip.setRouteId("route_id");
        trip.setTrainTypeName(""); // Set empty trainTypeName to match the test expectation
        trip.setStartTime(StringUtils.Date2String(new Date()));
        trip.setEndTime(StringUtils.Date2String(new Date()));
        Travel info = new Travel();
        info.setTrip(trip);
        info.setStartPlace("starting_place");
        info.setEndPlace("end_place");
        info.setDepartureTime(StringUtils.Date2String(new Date()));
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        //mock checkStationExists() and queryForStationId()
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/id/" + "starting_place",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/id/" + "end_place",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        //mock queryTrainType() - return null data to trigger "Train type doesn't exist"
        Response trainTypeResponse = new Response<>(0, "Train type not found", null);
        ResponseEntity<Response> trainTypeRe = new ResponseEntity<>(trainTypeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains/byName/" + "",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(trainTypeRe);
        //mock getRouteByRouteId()
        Route route = new Route();
        route.setId("route_id");
        route.setStations(Arrays.asList("starting_place", "end_place"));
        route.setDistances(Arrays.asList(0, 100));
        Response routeResponse = new Response<>(1, null, route);
        ResponseEntity<Response> routeRe = new ResponseEntity<>(routeResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + routeServiceHost + ":" + routeServicePort + "/api/v1/routeservice/routes/" + "route_id",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(routeRe);
        //mock queryPriceConfigByRouteIdAndTrainType()
        HttpEntity requestEntity2 = new HttpEntity(null, headers);
        Response response2 = new Response<>(1, null, new PriceConfig(UUID.randomUUID(), "", "", 1.0, 2.0));
        ResponseEntity<Response> re2 = new ResponseEntity<>(response2, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + priceServiceHost + ":" + priceServicePort + "/api/v1/priceservice/prices/" + "route_id" + "/" + "",
                HttpMethod.GET,
                requestEntity2,
                Response.class)).thenReturn(re2);

        Response result = basicServiceImpl.queryForTravel(info, headers);
        Assert.assertEquals("Train type doesn't exist", result.getMsg());
    }

    @Test
    public void testQueryForStationId() {
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/id/" + "stationName",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        Response result = basicServiceImpl.queryForStationId("stationName", headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testCheckStationExists() {
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/id/" + "stationName",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        Boolean result = basicServiceImpl.checkStationExists("stationName", headers);
        Assert.assertTrue(result);
    }

    @Test
    public void testQueryTrainType() {
        // Mock response with status 0 to return null
        Response response = new Response<>(0, "Train type not found", null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains/byName/" + "trainTypeId",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        TrainType result = basicServiceImpl.queryTrainTypeByName("trainTypeId", headers);
        // When status is 0 or data is null, method returns null
        Assert.assertNull(result);
    }

}
