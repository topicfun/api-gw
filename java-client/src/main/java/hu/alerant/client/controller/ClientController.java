package hu.alerant.client.controller;


import hu.alerant.client.model.Message;
import hu.alerant.client.service.ApiService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/client")
@Slf4j
public class ClientController {

    private final ApiService apiService;

    public ClientController(ApiService apiService) {
        this.apiService = apiService;
    }

    @GetMapping("/callHello")
    public Mono<Message> callBackendHello() {
        log.info("client calls Hello");
        return apiService.getHelloMessageFromBackend()
                .onErrorReturn(new Message("Backend Hello Service is currently unavailable. Please try again later.")); // <-- Hiba esetén fallback üzenet
    }

    @GetMapping("/callData")
    public Mono<Message> callBackendData() {
        log.info("client calls Data");
        return apiService.getDataFromBackend()
                .onErrorReturn(new Message("Backend Data Service is currently unavailable.")); // <-- Hiba esetén fallback üzenet
    }

    @GetMapping("/callBackend2Hello")
    public Mono<Message> callBackend2Hello() {
        log.info("client calls Hello2");
        return apiService.getHelloMessageFromBackend2()
                .onErrorReturn(new Message("Backend2 Hello Service is currently unavailable."));
    }
}