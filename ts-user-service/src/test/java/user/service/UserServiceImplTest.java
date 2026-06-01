package user.service;

import edu.fudan.common.util.Response;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;
import user.dto.AuthDto;
import user.dto.UserDto;
import user.entity.User;
import user.repository.UserRepository;
import user.service.impl.UserServiceImpl;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RunWith(MockitoJUnitRunner.class)
public class UserServiceImplTest {

    @InjectMocks
    private UserServiceImpl userServiceImpl;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private org.springframework.cloud.client.discovery.DiscoveryClient discoveryClient;

    private static final String authServiceHost = "ts-auth-service";
    private static final int authServicePort = 12340;

    private HttpHeaders headers = new HttpHeaders();

    @Before
    public void setUp() {
        org.springframework.test.util.ReflectionTestUtils.setField(userServiceImpl, "authServiceHost", authServiceHost);
        org.springframework.test.util.ReflectionTestUtils.setField(userServiceImpl, "authServicePort", authServicePort);
    }

    @Test
    public void testSaveUser() {
        UserDto userDto = new UserDto(UUID.randomUUID().toString(), "user_name", "xxx", 0, 1, "", "");
        Mockito.when(userRepository.findByUserName(Mockito.anyString())).thenReturn(null);

        //mock createDefaultAuthUser()
        Response<ArrayList<AuthDto>> response1 = new Response<>();
        ResponseEntity<Response<ArrayList<AuthDto>>> re1 = new ResponseEntity<>(response1, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)))
                .thenReturn(re1);

        User user = new User();
        Mockito.when(userRepository.save(Mockito.any(User.class))).thenReturn(user);
        Response result = userServiceImpl.saveUser(userDto, headers);
        Assert.assertEquals(new Response<>(1, "REGISTER USER SUCCESS", user), result);
    }

    @Test
    public void testGetAllUsers1() {
        List<User> users = new ArrayList<>();
        users.add(new User());
        Mockito.when(userRepository.findAll()).thenReturn(users);
        Response result = userServiceImpl.getAllUsers(headers);
        Assert.assertEquals(new Response<>(1, "Success", users), result);
    }

    @Test
    public void testGetAllUsers2() {
        Mockito.when(userRepository.findAll()).thenReturn(null);
        Response result = userServiceImpl.getAllUsers(headers);
        Assert.assertEquals(new Response<>(0, "NO User", null), result);
    }

    @Test
    public void testFindByUserName1() {
        User user = new User();
        Mockito.when(userRepository.findByUserName(Mockito.anyString())).thenReturn(user);
        Response result = userServiceImpl.findByUserName("user_name", headers);
        Assert.assertEquals(new Response<>(1, "Find User Success", user), result);
    }

    @Test
    public void testFindByUserName2() {
        Mockito.when(userRepository.findByUserName(Mockito.anyString())).thenReturn(null);
        Response result = userServiceImpl.findByUserName("user_name", headers);
        Assert.assertEquals(new Response<>(0, "No User", null), result);
    }

    @Test
    public void testFindByUserId1() {
        String userId = UUID.randomUUID().toString();
        User user = new User();
        Mockito.when(userRepository.findByUserId(Mockito.anyString())).thenReturn(user);
        Response result = userServiceImpl.findByUserId(userId, headers);
        Assert.assertEquals(new Response<>(1, "Find User Success", user), result);
    }

    @Test
    public void testFindByUserId2() {
        String userId = UUID.randomUUID().toString();
        Mockito.when(userRepository.findByUserId(Mockito.anyString())).thenReturn(null);
        Response result = userServiceImpl.findByUserId(userId, headers);
        Assert.assertEquals(new Response<>(0, "No User", null), result);
    }

    @Test
    public void testDeleteUser1() {
        String userId = UUID.randomUUID().toString();
        User user = new User();
        Mockito.when(userRepository.findByUserId(Mockito.anyString())).thenReturn(user);
        HttpEntity<Response> httpEntity = new HttpEntity<>(headers);
        Response mockResponse = new Response<>(1, "Success", null);
        ResponseEntity<Response> responseEntity = new ResponseEntity<>(mockResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(Mockito.anyString(),
                Mockito.eq(HttpMethod.DELETE),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(responseEntity);
        Mockito.doNothing().when(userRepository).deleteByUserId(Mockito.anyString());
        Response result = userServiceImpl.deleteUser(userId, headers);
        Assert.assertEquals(new Response<>(1, "DELETE SUCCESS", null), result);
    }

    @Test
    public void testDeleteUser2() {
        String userId = UUID.randomUUID().toString();
        Mockito.when(userRepository.findByUserId(Mockito.anyString())).thenReturn(null);
        Response result = userServiceImpl.deleteUser(userId, headers);
        Assert.assertEquals(new Response<>(0, "USER NOT EXISTS", null), result);
    }

    @Test
    public void testUpdateUser1() {
        UserDto userDto = new UserDto();
        String userId = UUID.randomUUID().toString();
        userDto.setUserId(userId); // Set userId for the test
        User oldUser = new User();
        oldUser.setUserId(userId); // Set userId on oldUser
        Mockito.when(userRepository.findByUserId(Mockito.eq(userId))).thenReturn(oldUser);
        Mockito.doNothing().when(userRepository).deleteByUserId(Mockito.eq(userId));
        User savedUser = new User();
        savedUser.setUserId(userId);
        Mockito.when(userRepository.save(Mockito.any(User.class))).thenReturn(savedUser);
        Response result = userServiceImpl.updateUser(userDto, headers);
        Assert.assertEquals("SAVE USER SUCCESS", result.getMsg());
    }

    @Test
    public void testUpdateUser2() {
        UserDto userDto = new UserDto();
        userDto.setUserId(UUID.randomUUID().toString());
        Mockito.when(userRepository.findByUserId(Mockito.anyString())).thenReturn(null);
        Response result = userServiceImpl.updateUser(userDto, headers);
        Assert.assertEquals(new Response<>(0, "USER NOT EXISTS", null), result);
    }

    @Test
    public void testDeleteUserAuth() {
        String userId = UUID.randomUUID().toString();
        HttpEntity<Response> httpEntity = new HttpEntity<>(headers);
        Response mockResponse = new Response<>(1, "Success", null);
        ResponseEntity<Response> responseEntity = new ResponseEntity<>(mockResponse, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(Mockito.anyString(),
                Mockito.eq(HttpMethod.DELETE),
                Mockito.any(HttpEntity.class),
                Mockito.eq(Response.class))).thenReturn(responseEntity);
        userServiceImpl.deleteUserAuth(userId, headers);
        Mockito.verify(restTemplate, Mockito.times(1))
                .exchange(Mockito.anyString(), Mockito.eq(HttpMethod.DELETE), Mockito.any(HttpEntity.class), Mockito.eq(Response.class));
    }

}
