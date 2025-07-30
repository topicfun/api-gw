package hu.alerant.backend.controller;


import hu.alerant.backend.model.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@Slf4j
public class BackendController {

    @GetMapping("/hello")
    public ResponseEntity<Message> getHelloMessage() {
        log.info("backend hello call");
        return ResponseEntity.ok()
                .header("X-App-Header", "from-backend")
                .body(new Message("Hello from Java Backend API!"));
    }

    @GetMapping("/data")
    public ResponseEntity<Message> getData() {
        log.info("backend data call");
        return ResponseEntity.ok()
                .header("X-App-Header", "from-backend")
                .body(new Message("This is some data from the backend."));
    }

    @GetMapping("/configAPI/13")
    public ResponseEntity<Message> getConfig() {
        log.info("backend configAPI 13 call");
        return ResponseEntity.ok()
                .header("X-App-Header", "from-backend")
                .body(new Message("Config13 from Backend"));
    }

}