package order.service;


import edu.fudan.common.entity.OrderSecurity;
import edu.fudan.common.entity.Seat;
import edu.fudan.common.util.Response;
import order.entity.*;
import order.repository.OrderRepository;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.mockito.internal.verification.VerificationModeFactory.times;

@RunWith(JUnit4.class)
public class OrderServiceImplTest {

    @InjectMocks
    private OrderServiceImpl orderServiceImpl;

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private RestTemplate restTemplate;

    private HttpHeaders headers = new HttpHeaders();

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetSoldTickets1() {
        Seat seatRequest = new Seat();
        ArrayList<Order> list = new ArrayList<>();
        list.add(new Order());
        Mockito.when(orderRepository.findByTravelDateAndTrainNumber(Mockito.any(String.class), Mockito.anyString())).thenReturn(list);
        Response result = orderServiceImpl.getSoldTickets(seatRequest, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testGetSoldTickets2() {
        Seat seatRequest = new Seat();
        Mockito.when(orderRepository.findByTravelDateAndTrainNumber(Mockito.any(String.class), Mockito.anyString())).thenReturn(null);
        Response result = orderServiceImpl.getSoldTickets(seatRequest, headers);
        Assert.assertEquals(new Response<>(0, "Order is Null.", null), result);
    }

    @Test
    public void testFindOrderById1() {
        String id = UUID.randomUUID().toString();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.findOrderById(id, headers);
        Assert.assertEquals(new Response<>(0, "No Content by this id", null), result);
    }

    @Test
    public void testFindOrderById2() {
        String id = UUID.randomUUID().toString();
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Response result = orderServiceImpl.findOrderById(id, headers);
        Assert.assertEquals(new Response<>(1, "Success", order), result);
    }

    @Test
    public void testCreate1() {
        Order order = new Order();
        order.setAccountId("test-account");
        ArrayList<Order> accountOrders = new ArrayList<>();
        accountOrders.add(order);
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(accountOrders);
        Response result = orderServiceImpl.create(order, headers);
        Assert.assertEquals(new Response<>(0, "Order already exist", null), result);
    }

    @Test
    public void testCreate2() {
        Order order = new Order();
        order.setAccountId("test-account");
        ArrayList<Order> accountOrders = new ArrayList<>();
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(accountOrders);
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.create(order, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testInitOrder1() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        orderServiceImpl.initOrder(order, headers);
        Mockito.verify(orderRepository, times(1)).save(Mockito.any(Order.class));
    }

    @Test
    public void testInitOrder2() {
        Order order = new Order();
        order.setId("test-id");
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        orderServiceImpl.initOrder(order, headers);
        Mockito.verify(orderRepository, times(0)).save(Mockito.any(Order.class));
    }

    @Test
    public void testAlterOrder1() {
        OrderAlterInfo oai = new OrderAlterInfo();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.alterOrder(oai, headers);
        Assert.assertEquals(new Response<>(0, "Old Order Does Not Exists", null), result);
    }

    @Test
    public void testAlterOrder2() {
        OrderAlterInfo oai = new OrderAlterInfo(UUID.randomUUID().toString(), UUID.randomUUID().toString(), "login_token", new Order());
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        //mock create()
        ArrayList<Order> accountOrders = new ArrayList<>();
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(accountOrders);
        Response result = orderServiceImpl.alterOrder(oai, headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testQueryOrders() {
        ArrayList<Order> list = new ArrayList<>();
        Order order = new Order();
        order.setStatus(1);
        order.setBoughtDate("2023-01-01 10:00:00");
        order.setTravelDate("2023-01-02 10:00:00");
        list.add(order);
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(list);
        OrderInfo qi = new OrderInfo();
        qi.setEnableStateQuery(true);
        qi.setEnableBoughtDateQuery(false);
        qi.setEnableTravelDateQuery(false);
        qi.setState(1);
        qi.setBoughtDateStart("2023-01-01 00:00:00");
        qi.setBoughtDateEnd("2023-12-31 23:59:59");
        qi.setTravelDateEnd("2023-12-31 23:59:59");
        Response result = orderServiceImpl.queryOrders(qi, UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(1, "Get order num", list), result);
    }

    @Test
    public void testQueryOrdersForRefresh() {
        ArrayList<Order> list = new ArrayList<>();
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(list);
        //mock queryForStationId()
        Response<List<String>> response = new Response<>();
        ResponseEntity<Response<List<String>>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)
        )).thenReturn(re);
        OrderInfo qi = new OrderInfo();
        qi.setEnableStateQuery(false);
        qi.setEnableBoughtDateQuery(false);
        qi.setEnableTravelDateQuery(false);
        Response result = orderServiceImpl.queryOrdersForRefresh(qi, UUID.randomUUID().toString(), headers);
        Assert.assertEquals("Query Orders For Refresh Success", result.getMsg());
    }

    @Test
    public void testQueryForStationId() {
        List<String> ids = new ArrayList<>();
        HttpEntity requestEntity = new HttpEntity<>(ids, headers);
        Response<List<String>> response = new Response<>();
        response.setData(new ArrayList<>());
        ResponseEntity<Response<List<String>>> re = new ResponseEntity<>(response, HttpStatus.OK);
        Mockito.when(restTemplate.exchange(
                Mockito.anyString(),
                Mockito.any(HttpMethod.class),
                Mockito.any(HttpEntity.class),
                Mockito.any(ParameterizedTypeReference.class)
        )).thenReturn(re);
        List<String> result = orderServiceImpl.queryForStationId(ids, headers);
        Assert.assertNotNull(result);
    }

    @Test
    public void testSaveChanges1() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.saveChanges(order, headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", null), result);
    }

    @Test
    public void testSaveChanges2() {
        Order order = new Order();
        order.setId("test-id");
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.saveChanges(order, headers);
        Assert.assertEquals(new Response<>(1, "Success", order), result);
    }

    @Test
    public void testCancelOrder1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.cancelOrder(UUID.randomUUID().toString(), UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", null), result);
    }

    @Test
    public void testCancelOrder2() {
        Order oldOrder = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(oldOrder));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(oldOrder);
        Response result = orderServiceImpl.cancelOrder(UUID.randomUUID().toString(), UUID.randomUUID().toString(), headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testQueryAlreadySoldOrders() {
        ArrayList<Order> orders = new ArrayList<>();
        Mockito.when(orderRepository.findByTravelDateAndTrainNumber(Mockito.any(String.class), Mockito.anyString())).thenReturn(orders);
        Response result = orderServiceImpl.queryAlreadySoldOrders(new Date(), "G1234", headers);
        Assert.assertEquals("Success", result.getMsg());
    }

    @Test
    public void testGetAllOrders1() {
        Mockito.when(orderRepository.findAll()).thenReturn(null);
        Response result = orderServiceImpl.getAllOrders(headers);
        Assert.assertEquals(new Response<>(0, "No Content.", null), result);
    }

    @Test
    public void testGetAllOrders2() {
        ArrayList<Order> orders = new ArrayList<>();
        orders.add(new Order());
        Mockito.when(orderRepository.findAll()).thenReturn(orders);
        Response result = orderServiceImpl.getAllOrders(headers);
        Assert.assertEquals(new Response<>(1, "Success.", orders), result);
    }

    @Test
    public void testModifyOrder1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.modifyOrder(UUID.randomUUID().toString(), 1, headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", null), result);
    }

    @Test
    public void testModifyOrder2() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.modifyOrder(UUID.randomUUID().toString(), 1, headers);
        Assert.assertEquals("Modify Order Success", result.getMsg());
    }

    @Test
    public void testGetOrderPrice1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.getOrderPrice(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", "-1.0"), result);
    }

    @Test
    public void testGetOrderPrice2() {
        Order order = new Order();
        order.setPrice("100.0");
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Response result = orderServiceImpl.getOrderPrice(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(1, "Success", order.getPrice()), result);
    }

    @Test
    public void testPayOrder1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.payOrder(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", null), result);
    }

    @Test
    public void testPayOrder2() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.payOrder(UUID.randomUUID().toString(), headers);
        Assert.assertEquals("Pay Order Success.", result.getMsg());
    }

    @Test
    public void testGetOrderById1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.getOrderById(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found", null), result);
    }

    @Test
    public void testGetOrderById2() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Response result = orderServiceImpl.getOrderById(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(1, "Success.", order), result);
    }

    @Test
    public void testCheckSecurityAboutOrder() {
        ArrayList<Order> orders = new ArrayList<>();
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(orders);
        Response result = orderServiceImpl.checkSecurityAboutOrder(new Date(), UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(1, "Check Security Success . ", new OrderSecurity(0, 0)), result);
    }

    @Test
    public void testDeleteOrder1() {
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.deleteOrder(UUID.randomUUID().toString(), headers);
        Assert.assertEquals(new Response<>(0, "Order Not Exist.", null), result);
    }

    @Test
    public void testDeleteOrder2() {
        Order order = new Order();
        String orderUuid = UUID.randomUUID().toString();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.doNothing().when(orderRepository).deleteById(Mockito.any(String.class));
        Response result = orderServiceImpl.deleteOrder(orderUuid.toString(), headers);
        Assert.assertEquals(new Response<>(1, "Delete Order Success", order), result);
    }

    @Test
    public void testAddNewOrder1() {
        Order order = new Order();
        order.setAccountId("test-account");
        ArrayList<Order> accountOrders = new ArrayList<>();
        accountOrders.add(order);
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(accountOrders);
        Response result = orderServiceImpl.addNewOrder(order, headers);
        Assert.assertEquals(new Response<>(0, "Order already exist", null), result);
    }

    @Test
    public void testAddNewOrder2() {
        Order order = new Order();
        order.setAccountId("test-account");
        ArrayList<Order> accountOrders = new ArrayList<>();
        Mockito.when(orderRepository.findByAccountId(Mockito.any(String.class))).thenReturn(accountOrders);
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.addNewOrder(order, headers);
        Assert.assertEquals("Add new Order Success", result.getMsg());
    }

    @Test
    public void testUpdateOrder1() {
        Order order = new Order();
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.empty());
        Response result = orderServiceImpl.updateOrder(order, headers);
        Assert.assertEquals(new Response<>(0, "Order Not Found, Can't update", null), result);
    }

    @Test
    public void testUpdateOrder2() {
        Order order = new Order();
        order.setId("test-id");
        Mockito.when(orderRepository.findById(Mockito.any(String.class))).thenReturn(Optional.of(order));
        Mockito.when(orderRepository.save(Mockito.any(Order.class))).thenReturn(order);
        Response result = orderServiceImpl.updateOrder(order, headers);
        Assert.assertEquals("Admin Update Order Success", result.getMsg());
    }

}
