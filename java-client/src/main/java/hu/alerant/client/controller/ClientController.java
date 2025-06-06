package hu.alerant.client.controller;


import hu.alerant.client.model.Message;
import hu.alerant.client.service.ApiService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/client")
public class ClientController {

    private final ApiService apiService;

    public ClientController(ApiService apiService) {
        this.apiService = apiService;
    }

    @GetMapping("/callHello")
    public Mono<Message> callBackendHello() {
        return apiService.getHelloMessageFromBackend()
                .onErrorReturn(new Message("Backend Hello Service is currently unavailable. Please try again later.")); // <-- Hiba esetén fallback üzenet
    }

    @GetMapping("/callData")
    public Mono<Message> callBackendData() {
        return apiService.getDataFromBackend()
                .onErrorReturn(new Message("Backend Data Service is currently unavailable.")); // <-- Hiba esetén fallback üzenet
    }

    @GetMapping("/callBackend2Hello")
    public Mono<Message> callBackend2Hello() {
        return apiService.getHelloMessageFromBackend2()
                .onErrorReturn(new Message("Backend2 Hello Service is currently unavailable."));
    }
}