package verifycode.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.springframework.http.HttpHeaders;
import verifycode.service.impl.VerifyCodeServiceImpl;

import java.io.OutputStream;
import java.util.Map;

import static org.mockito.Mockito.mock;

@RunWith(JUnit4.class)
public class VerifyCodeServiceImplTest {

    private final VerifyCodeServiceImpl verifyCodeService = new VerifyCodeServiceImpl();
    private final HttpHeaders headers = new HttpHeaders();
    private final HttpServletRequest request = mock(HttpServletRequest.class);
    private final HttpServletResponse response = mock(HttpServletResponse.class);

    @Test
    public void testGetImageCode() {
        OutputStream output = System.out;
        Map<String, Object> result =
                verifyCodeService.getImageCode(60, 20, output, request, response, headers);

        Assert.assertNotNull(result);
        Assert.assertNotNull(result.get("strEnsure"));
    }

    @Test
    public void testVerifyCode() {
        boolean result = verifyCodeService.verifyCode(request, response, "XYZ5", headers);

        Assert.assertFalse(result);
    }
}
