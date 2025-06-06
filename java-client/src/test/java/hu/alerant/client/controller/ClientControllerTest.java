package hu.alerant.client.controller;

import hu.alerant.client.model.Message;
import hu.alerant.client.service.ApiService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;

import static org.mockito.Mockito.when;

@WebFluxTest(ClientController.class)
class ClientControllerTest {
    @Autowired
    private WebTestClient webTestClient;

    @MockBean
    private ApiService apiService;

    @Test
    void callHelloReturnsBackendMessage() {
        when(apiService.getHelloMessageFromBackend()).thenReturn(Mono.just(new Message("hello")));
        webTestClient.get().uri("/client/callHello")
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.content").isEqualTo("hello");
    }
}
