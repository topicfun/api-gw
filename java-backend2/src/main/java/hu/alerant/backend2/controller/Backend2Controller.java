package hu.alerant.backend2.controller;


import hu.alerant.backend2.model.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@Slf4j
public class Backend2Controller {

    @GetMapping("/hello")
    public ResponseEntity<Message> getHelloMessage() {
        log.info("backend2 hello call");
        return ResponseEntity.ok()
                .header("X-App-Header", "from-backend")
                .body(new Message("Hello from Java Backend2 API!"));
    }

    @GetMapping("/data")
    public ResponseEntity<Message> getData() {
        log.info("backend2 data call");
        return ResponseEntity.ok()
                .header("X-App-Header", "from-backend")
                .body(new Message("This is some data from the backend2."));
    }
}
