package edu.eci.arsw.spring_sockets_rt_p5.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import edu.eci.arsw.spring_sockets_rt_p5.repositories.TicketRepository;

@RestController
public class DrawingServiceController {
    
    @Autowired
    private TicketRepository ticketRepository;
    
    @RequestMapping(
    value = "/status",
    method = RequestMethod.GET,
    produces = "application/json"
    )
    public String status() {
        return "{\"status\":\"Greetings from Spring Boot. "
        + java.time.LocalDate.now() + ", "
        + java.time.LocalTime.now()
        + ". " + "The server is Running!\"}";
    }

    @GetMapping(value = "/getticket", produces = "application/json")
    public String getTicket() {
        Integer ticket = ticketRepository.getTicket();
        return "{\"ticket\":" + ticket + "}";
    }

    @GetMapping(value = "/health", produces = "application/json")
    public String health() {
        try {
            // Test Redis connectivity by attempting to generate a ticket
            Integer testTicket = ticketRepository.getTicket();
            return "{\"status\":\"UP\",\"redis\":\"CONNECTED\",\"timestamp\":\"" 
                + java.time.LocalDateTime.now() + "\"}";
        } catch (Exception e) {
            return "{\"status\":\"DOWN\",\"redis\":\"DISCONNECTED\",\"error\":\"" 
                + e.getMessage() + "\",\"timestamp\":\"" + java.time.LocalDateTime.now() + "\"}";
        }
    }
}
