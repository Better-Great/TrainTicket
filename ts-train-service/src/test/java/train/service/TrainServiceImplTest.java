package train.service;

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
import train.entity.TrainType;
import train.repository.TrainTypeRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RunWith(JUnit4.class)
public class TrainServiceImplTest {

    @InjectMocks
    private TrainServiceImpl trainServiceImpl;

    @Mock
    private TrainTypeRepository repository;

    private HttpHeaders headers = new HttpHeaders();

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testCreate1() {
        TrainType trainType = new TrainType();
        trainType.setName("test_train"); // Set a name for the train
        Mockito.when(repository.findByName(Mockito.anyString())).thenReturn(null); // Train doesn't exist
        TrainType savedTrainType = new TrainType("test_train", 100, 50);
        Mockito.when(repository.save(Mockito.any(TrainType.class))).thenReturn(savedTrainType);
        boolean result = trainServiceImpl.create(trainType, headers);
        Assert.assertTrue(result);
    }

    @Test
    public void testCreate2() {
        TrainType trainType = new TrainType();
        trainType.setName("test_train"); // Set a name for the train
        TrainType existingTrain = new TrainType("test_train", 100, 50);
        Mockito.when(repository.findByName(Mockito.anyString())).thenReturn(existingTrain); // Train already exists
        boolean result = trainServiceImpl.create(trainType, headers);
        Assert.assertFalse(result);
    }

    @Test
    public void testRetrieve1() {
        Mockito.when(repository.findById(Mockito.anyString())).thenReturn(Optional.empty()); // Train not found
        TrainType result = trainServiceImpl.retrieve("id", headers);
        Assert.assertNull(result);
    }

    @Test
    public void testRetrieve2() {
        TrainType trainType = new TrainType();
        trainType.setId("id");
        Mockito.when(repository.findById(Mockito.anyString())).thenReturn(Optional.of(trainType)); // Train found
        TrainType result = trainServiceImpl.retrieve("id", headers);
        Assert.assertNotNull(result);
    }

    @Test
    public void testUpdate1() {
        TrainType trainType = new TrainType();
        trainType.setId(UUID.randomUUID().toString()); // Set an ID
        trainType.setName("test_train");
        TrainType existingTrain = new TrainType("test_train", 100, 50);
        existingTrain.setId(trainType.getId());
        Mockito.when(repository.findById(Mockito.anyString())).thenReturn(Optional.of(existingTrain)); // Train exists
        Mockito.when(repository.save(Mockito.any(TrainType.class))).thenReturn(existingTrain);
        boolean result = trainServiceImpl.update(trainType, headers);
        Assert.assertTrue(result);
    }

    @Test
    public void testUpdate2() {
        TrainType trainType = new TrainType();
        trainType.setId(UUID.randomUUID().toString()); // Set an ID
        Mockito.when(repository.findById(Mockito.anyString())).thenReturn(Optional.empty()); // Train not found
        boolean result = trainServiceImpl.update(trainType, headers);
        Assert.assertFalse(result);
    }

    @Test
    public void testDelete1() {
        String trainId = UUID.randomUUID().toString();
        TrainType trainType = new TrainType();
        trainType.setId(trainId);
        Mockito.when(repository.findById(Mockito.eq(trainId))).thenReturn(Optional.of(trainType)); // Train exists
        Mockito.doNothing().when(repository).deleteById(Mockito.anyString());
        boolean result = trainServiceImpl.delete(trainId, headers);
        Assert.assertTrue(result);
    }

    @Test
    public void testDelete2() {
        String trainId = UUID.randomUUID().toString();
        Mockito.when(repository.findById(Mockito.anyString())).thenReturn(Optional.empty()); // Train not found
        boolean result = trainServiceImpl.delete(trainId, headers);
        Assert.assertFalse(result);
    }

    @Test
    public void testQuery() {
        List<TrainType> trainTypes = new ArrayList<>();
        Mockito.when(repository.findAll()).thenReturn(trainTypes); // Return empty list
        List<TrainType> result = trainServiceImpl.query(headers);
        Assert.assertNotNull(result);
        Assert.assertEquals(trainTypes, result);
    }

}
