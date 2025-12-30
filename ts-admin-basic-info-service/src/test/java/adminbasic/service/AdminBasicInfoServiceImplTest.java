package adminbasic.service;

import adminbasic.entity.*;
import edu.fudan.common.entity.Config;
import edu.fudan.common.entity.Contacts;
import edu.fudan.common.entity.Station;
import edu.fudan.common.entity.TrainType;
import edu.fudan.common.util.Response;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.*;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.http.*;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

@RunWith(JUnit4.class)
public class AdminBasicInfoServiceImplTest {

    // Service hosts and ports from properties/dev.application.ini (matching property names)
    private static final String contactsServiceHost = "ts-contacts-service";
    private static final int contactsServicePort = 12347;
    private static final String stationServiceHost = "ts-station-service";
    private static final int stationServicePort = 12345;
    private static final String trainServiceHost = "ts-train-service";
    private static final int trainServicePort = 14567;
    private static final String configServiceHost = "ts-config-service";
    private static final int configServicePort = 15679;
    private static final String priceServiceHost = "ts-price-service";
    private static final int priceServicePort = 16579;

    @InjectMocks
    private AdminBasicInfoServiceImpl adminBasicInfoService;

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
        ReflectionTestUtils.setField(adminBasicInfoService, "contactsServiceHost", contactsServiceHost);
        ReflectionTestUtils.setField(adminBasicInfoService, "contactsServicePort", contactsServicePort);
        ReflectionTestUtils.setField(adminBasicInfoService, "stationServiceHost", stationServiceHost);
        ReflectionTestUtils.setField(adminBasicInfoService, "stationServicePort", stationServicePort);
        ReflectionTestUtils.setField(adminBasicInfoService, "trainServiceHost", trainServiceHost);
        ReflectionTestUtils.setField(adminBasicInfoService, "trainServicePort", trainServicePort);
        ReflectionTestUtils.setField(adminBasicInfoService, "configServiceHost", configServiceHost);
        ReflectionTestUtils.setField(adminBasicInfoService, "configServicePort", configServicePort);
        ReflectionTestUtils.setField(adminBasicInfoService, "priceServiceHost", priceServiceHost);
        ReflectionTestUtils.setField(adminBasicInfoService, "priceServicePort", priceServicePort);
    }

    @Test
    public void testGetAllContacts() {
        Mockito.when(restTemplate.exchange(
                "http://" + contactsServiceHost + ":" + contactsServicePort + "/api/v1/contactservice/contacts",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.getAllContacts(headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testDeleteContact() {
        Mockito.when(restTemplate.exchange(
                "http://" + contactsServiceHost + ":" + contactsServicePort + "/api/v1/contactservice/contacts/" + "contactsId",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.deleteContact("contactsId", headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testModifyContact() {
        Contacts mci = new Contacts();
        HttpEntity<Contacts> requestEntity = new HttpEntity<>(mci, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + contactsServiceHost + ":" + contactsServicePort + "/api/v1/contactservice/contacts",
                HttpMethod.PUT,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.modifyContact(mci, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testAddContact() {
        Contacts c = new Contacts();
        HttpEntity<Contacts> requestEntity = new HttpEntity<>(c, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + contactsServiceHost + ":" + contactsServicePort + "/api/v1/contactservice/contacts/admin",
                HttpMethod.POST,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.addContact(c, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testGetAllStations() {
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.getAllStations(headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testAddStation() {
        Station s = new Station();
        HttpEntity<Station> requestEntity = new HttpEntity<>(s, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations",
                HttpMethod.POST,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.addStation(s, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testDeleteStation() {
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations/" + "stationId",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.deleteStation("stationId", headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testModifyStation() {
        Station s = new Station();
        HttpEntity<Station> requestEntity = new HttpEntity<>(s, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + stationServiceHost + ":" + stationServicePort + "/api/v1/stationservice/stations",
                HttpMethod.PUT,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.modifyStation(s, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testGetAllTrains() {
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.getAllTrains(headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testAddTrain() {
        TrainType t = new TrainType();
        HttpEntity<TrainType> requestEntity = new HttpEntity<>(t, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains",
                HttpMethod.POST,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.addTrain(t, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testDeleteTrain() {
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains/" + "id",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.deleteTrain("id", headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testModifyTrain() {
        TrainType t = new TrainType();
        HttpEntity<TrainType> requestEntity = new HttpEntity<>(t, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + trainServiceHost + ":" + trainServicePort + "/api/v1/trainservice/trains",
                HttpMethod.PUT,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.modifyTrain(t, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testGetAllConfigs() {
        Mockito.when(restTemplate.exchange(
                "http://" + configServiceHost + ":" + configServicePort + "/api/v1/configservice/configs",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.getAllConfigs(headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testAddConfig() {
        Config c = new Config();
        HttpEntity<Config> requestEntity = new HttpEntity<>(c, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + configServiceHost + ":" + configServicePort + "/api/v1/configservice/configs",
                HttpMethod.POST,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.addConfig(c, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testDeleteConfig() {
        Mockito.when(restTemplate.exchange(
                "http://" + configServiceHost + ":" + configServicePort + "/api/v1/configservice/configs/" + "name",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.deleteConfig("name", headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testModifyConfig() {
        Config c = new Config();
        HttpEntity<Config> requestEntity = new HttpEntity<>(c, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + configServiceHost + ":" + configServicePort + "/api/v1/configservice/configs",
                HttpMethod.PUT,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.modifyConfig(c, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testGetAllPrices() {
        Mockito.when(restTemplate.exchange(
                "http://" + priceServiceHost + ":" + priceServicePort + "/api/v1/priceservice/prices",
                HttpMethod.GET,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.getAllPrices(headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testAddPrice() {
        PriceInfo pi = new PriceInfo();
        HttpEntity<PriceInfo> requestEntity = new HttpEntity<>(pi, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + priceServiceHost + ":" + priceServicePort + "/api/v1/priceservice/prices",
                HttpMethod.POST,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.addPrice(pi, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testDeletePrice() {
        Mockito.when(restTemplate.exchange(
                "http://" + priceServiceHost + ":" + priceServicePort + "/api/v1/priceservice/prices/" + "pricesId",
                HttpMethod.DELETE,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.deletePrice("pricesId", headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

    @Test
    public void testModifyPrice() {
        PriceInfo pi = new PriceInfo();
        HttpEntity<PriceInfo> requestEntity = new HttpEntity<>(pi, headers);
        Mockito.when(restTemplate.exchange(
                "http://" + priceServiceHost + ":" + priceServicePort + "/api/v1/priceservice/prices",
                HttpMethod.PUT,
                requestEntity,
                Response.class)).thenReturn(re);
        response = adminBasicInfoService.modifyPrice(pi, headers);
        Assert.assertEquals(new Response<>(null, null, null), response);
    }

}
