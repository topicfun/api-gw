package hu.alerant.backend2.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.hamcrest.Matchers.is;

@SpringBootTest
@AutoConfigureMockMvc
class Backend2ControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    void helloEndpointReturnsMessage() throws Exception {
        mockMvc.perform(get("/api/hello"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", is("Hello from Java Backend2 API!")));
    }

    @Test
    void dataEndpointReturnsMessage() throws Exception {
        mockMvc.perform(get("/api/data"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", is("This is some data from the backend2.")));
    }
}
