package hu.alerant.backend.controller;


import hu.alerant.backend.model.Message;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class BackendController {

    @GetMapping("/hello")
    public Message getHelloMessage() {
        return new Message("Hello from Java Backend API!");
    }

    @GetMapping("/data")
    public Message getData() {
        return new Message("This is some data from the backend.");
    }
}