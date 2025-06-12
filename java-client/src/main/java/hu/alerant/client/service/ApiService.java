package hu.alerant.client.service;


//import hu.alerant.client.model.Message;
//import org.springframework.http.MediaType;
//import org.springframework.stereotype.Service;
//import org.springframework.web.reactive.function.client.WebClient;
//import reactor.core.publisher.Mono;
//
//@Service
//public class ApiService {
//
//    private final WebClient webClient;
//
//    // A konstruktorban injektáljuk a WebClient-et
//    public ApiService(WebClient.Builder webClientBuilder) {
//        // A 'http://java-backend:8080' URI a Docker hálózaton belüli kommunikációhoz
//        // Figyelem: A /api/ prefixet itt nem használjuk, mert a WebClient közvetlenül a backendhez szól,
//        // nem az Nginx-en keresztül. Az Nginx csak a külső kéréseket proxizza.
//        this.webClient = webClientBuilder.baseUrl("http://java-backend:8080").build();
//    }
//
//    public Mono<Message> getHelloMessageFromBackend() {
//        return webClient.get()
//                .uri("/api/hello") // Az API végpontja
//                .accept(MediaType.APPLICATION_JSON)
//                .retrieve()
//                .bodyToMono(Message.class);
//    }
//
//    public Mono<Message> getDataFromBackend() {
//        return webClient.get()
//                .uri("/api/data")
//                .accept(MediaType.APPLICATION_JSON)
//                .retrieve()
//                .bodyToMono(Message.class);
//    }
//}


import hu.alerant.client.model.Message;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;
import java.time.Duration;

@Service
public class ApiService {

    private final WebClient webClient;

    public ApiService(WebClient.Builder webClientBuilder) {
        // A WebClient most a 'nginx' konténer nevét hívja a Docker hálózaton belül,
        // annak alapértelmezett 80-as HTTP portján.
        this.webClient = webClientBuilder.baseUrl("http://nginx").build();
    }

    private <T> Mono<T> makeRequest(String path, Class<T> responseType) {
        return webClient.get()
                .uri(path) // Az útvonal már tartalmazza a proxy prefixet, pl. /backend-api/hello
                .header("X-App-Header", "from-client")
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .onStatus(HttpStatusCode::isError, response -> {
                    if (response.statusCode().is5xxServerError() || response.statusCode().equals(HttpStatus.NOT_FOUND)) {
                        System.err.println("Backend service error or not found (via Nginx): " + response.statusCode());
                        return Mono.error(new RuntimeException("Upstream service not available or returned error status " + response.statusCode()));
                    }
                    return response.createException();
                })
                .bodyToMono(responseType)
                .retryWhen(Retry.backoff(5, Duration.ofSeconds(2))
                        .filter(throwable -> throwable instanceof RuntimeException)
                        .doBeforeRetry(retrySignal -> System.out.println("Retrying connection to Nginx/Backend. Attempt: " + (retrySignal.totalRetries() + 1)))
                        .onRetryExhaustedThrow((retryBackoffSpec, retrySignal) -> new RuntimeException("Backend service is still unavailable after multiple retries via Nginx.")));
    }

    public Mono<Message> getHelloMessageFromBackend() {
        return makeRequest("/backend-api/hello", Message.class); // Útvonal az Nginx-hez, amit az Nginx proxizni fog
    }

    public Mono<Message> getDataFromBackend() {
        return makeRequest("/backend-api/data", Message.class); // Útvonal az Nginx-hez
    }

    public Mono<Message> getHelloMessageFromBackend2() {
        return makeRequest("/backend2-api/hello", Message.class);
    }

    public Mono<Message> callConfigAPI() {
        return makeRequest("/api/configAPI", Message.class);
    }
}