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
//    // Inject the WebClient via the constructor
//    public ApiService(WebClient.Builder webClientBuilder) {
//        // The 'http://java-backend:8080' URI is for communication inside the Docker network
//        // Note: We don't use the /api/ prefix here because the WebClient communicates directly with the backend,
//        // not through Nginx. Nginx only proxies external requests.
//        this.webClient = webClientBuilder.baseUrl("http://java-backend:8080").build();
//    }
//
//    public Mono<Message> getHelloMessageFromBackend() {
//        return webClient.get()
//                .uri("/api/hello") // API endpoint
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
        // The WebClient now calls the 'nginx' container name within the Docker network,
        // using its default HTTP port 80.
        this.webClient = webClientBuilder.baseUrl("http://nginx").build();
    }

    private <T> Mono<T> makeRequest(String path, Class<T> responseType) {
        return webClient.get()
                .uri(path) // Path already includes the proxy prefix, e.g., /backend-api/hello
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
        return makeRequest("/backend-api/hello", Message.class); // Path to Nginx which will be proxied
    }

    public Mono<Message> getDataFromBackend() {
        return makeRequest("/backend-api/hello/1id", Message.class); // Path to Nginx
    }

    public Mono<Message> callConfigAPI() {
        return makeRequest("/api/configAPI", Message.class);
    }
    public Mono<Message> callConfigAPI13() {
        return makeRequest("/api/configAPI/13", Message.class);
    }


}