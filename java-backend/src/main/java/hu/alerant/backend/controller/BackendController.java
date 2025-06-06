package hu.alerant.backend.controller;


import hu.alerant.backend.model.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@Slf4j
public class BackendController {

    @GetMapping("/hello")
    public Message getHelloMessage() {
        log.info("backend hello call");
        return new Message("Hello from Java Backend API!");
    }

    @GetMapping("/data")
    public Message getData() {
        log.info("backend data call");
        return new Message("This is some data from the backend.");
    }
}