package com.trainticket.service;

import com.trainticket.entity.Money;
import com.trainticket.entity.Payment;
import com.trainticket.repository.AddMoneyRepository;
import com.trainticket.repository.PaymentRepository;
import edu.fudan.common.idempotency.IdempotencyGuard;
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
import org.springframework.http.HttpHeaders;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RunWith(JUnit4.class)
public class PaymentServiceImplTest {

    @InjectMocks
    private PaymentServiceImpl paymentServiceImpl;

    @Mock
    private PaymentRepository paymentRepository;

    @Mock
    private AddMoneyRepository addMoneyRepository;

    @Mock
    private IdempotencyGuard idempotencyGuard;

    private HttpHeaders headers = new HttpHeaders();

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        Mockito.when(idempotencyGuard.reserve(Mockito.anyString())).thenReturn(true);
        Mockito.when(idempotencyGuard.getCachedResult(Mockito.anyString())).thenReturn(Optional.empty());
    }

    @Test
    public void testPay1() {
        Payment info = new Payment();
        Mockito.when(paymentRepository.findByOrderId(Mockito.anyString())).thenReturn(null);
        Mockito.when(paymentRepository.save(Mockito.any(Payment.class))).thenReturn(null);
        Response result = paymentServiceImpl.pay(info, headers);
        Assert.assertEquals(new Response<>(1, "Pay Success", null), result);
    }

    @Test
    public void testPay2() {
        Payment info = new Payment();
        Mockito.when(paymentRepository.findByOrderId(Mockito.anyString())).thenReturn(info);
        Response result = paymentServiceImpl.pay(info, headers);
        Assert.assertEquals(new Response<>(0, "Pay Failed, order not found with order id", null), result);
    }

    @Test
    public void testAddMoney() {
        Payment info = new Payment();
        // The implementation creates a new Money object and sets userId and money from the Payment
        // Since Payment constructor initializes fields to empty strings, Money will have empty strings too
        Mockito.when(addMoneyRepository.save(Mockito.any(Money.class))).thenAnswer(invocation -> {
            Money money = invocation.getArgument(0);
            return money; // Return the same Money object that was passed in
        });
        Response result = paymentServiceImpl.addMoney(info, headers);
        Assert.assertEquals(1, result.getStatus().intValue());
        Assert.assertEquals("Add Money Success", result.getMsg());
        Assert.assertNotNull(result.getData());
        Assert.assertTrue(result.getData() instanceof Money);
        Money returnedMoney = (Money) result.getData();
        // The Money object will have empty strings for userId and money (from Payment constructor)
        Assert.assertEquals("", returnedMoney.getUserId());
        Assert.assertEquals("", returnedMoney.getMoney());
    }

    @Test
    public void testQuery1() {
        List<Payment> payments = new ArrayList<>();
        payments.add(new Payment());
        Mockito.when(paymentRepository.findAll()).thenReturn(payments);
        Response result = paymentServiceImpl.query(headers);
        Assert.assertEquals(new Response<>(1,"Query Success",  payments), result);
    }

    @Test
    public void testQuery2() {
        Mockito.when(paymentRepository.findAll()).thenReturn(null);
        Response result = paymentServiceImpl.query(headers);
        Assert.assertEquals(new Response<>(0, "No Content", null), result);
    }

    @Test
    public void testInitPayment1() {
        Payment payment = new Payment();
        payment.setId("test-id");
        Mockito.when(paymentRepository.findById(Mockito.anyString())).thenReturn(java.util.Optional.empty());
        Mockito.when(paymentRepository.save(Mockito.any(Payment.class))).thenReturn(null);
        paymentServiceImpl.initPayment(payment, headers);
        Mockito.verify(paymentRepository, Mockito.times(1)).save(Mockito.any(Payment.class));
    }

    @Test
    public void testInitPayment2() {
        Payment payment = new Payment();
        payment.setId("test-id");
        Payment existingPayment = new Payment();
        Mockito.when(paymentRepository.findById(Mockito.anyString())).thenReturn(java.util.Optional.of(existingPayment));
        Mockito.when(paymentRepository.save(Mockito.any(Payment.class))).thenReturn(null);
        paymentServiceImpl.initPayment(payment, headers);
        Mockito.verify(paymentRepository, Mockito.times(0)).save(Mockito.any(Payment.class));
    }

}
