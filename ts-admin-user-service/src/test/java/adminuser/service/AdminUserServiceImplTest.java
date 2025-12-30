package adminuser.service;

import adminuser.dto.UserDto;
import edu.fudan.common.entity.User;
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

import java.util.List;

@RunWith(JUnit4.class)
public class AdminUserServiceImplTest {

    // Service host and port from properties/dev.application.ini (matching property names)
    private static final String userServiceHost = "ts-user-service";
    private static final int userServicePort = 12342;

    @InjectMocks
    private AdminUserServiceImpl adminUserServiceImpl;

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
        ReflectionTestUtils.setField(adminUserServiceImpl, "userServiceHost", userServiceHost);
        ReflectionTestUtils.setField(adminUserServiceImpl, "userServicePort", userServicePort);
    }

    @Test
    public void testGetAllUsers() {
        Response<List<User>> response = new Response<>(1, null, null);
        ResponseEntity<Response<List<User>>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + userServiceHost + ":" + userServicePort + "/api/v1/userservice/users",
                HttpMethod.GET,
                requestEntity,
                new ParameterizedTypeReference<Response<List<User>>>() {
                })).thenReturn(re);
        Response result = adminUserServiceImpl.getAllUsers(headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testDeleteUser() {
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.eq("http://" + userServiceHost + ":" + userServicePort + "/api/v1/userservice/users" + "/" + "userId"),
                Mockito.eq(HttpMethod.DELETE),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(re);
        Response result = adminUserServiceImpl.deleteUser("userId", headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testUpdateUser() {
        UserDto userDto = new UserDto();
        Response response = new Response<>(1, null, null);
        ResponseEntity<Response> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.eq("http://" + userServiceHost + ":" + userServicePort + "/api/v1/userservice/users"),
                Mockito.eq(HttpMethod.PUT),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(re);
        Response result = adminUserServiceImpl.updateUser(userDto, headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

    @Test
    public void testAddUser() {
        UserDto userDto = new UserDto();
        HttpEntity requestEntity2 = new HttpEntity(userDto, headers);
        Response<User> response = new Response<>(1, null, null);
        ResponseEntity<Response<User>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                "http://" + userServiceHost + ":" + userServicePort + "/api/v1/userservice/users" + "/register",
                HttpMethod.POST,
                requestEntity2,
                new ParameterizedTypeReference<Response<User>>() {
                })).thenReturn(re);
        Response result = adminUserServiceImpl.addUser(userDto, headers);
        Assert.assertEquals(new Response<>(1, null, null), result);
    }

}
