package com.proevolutionit.ticketevolution.controller;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.dto.EventDto;
import com.proevolutionit.ticketevolution.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/event")
public class EventController {

    @Autowired
    private EventService eventService;

    @PostMapping
    public String createEvent(@RequestBody Event event){
        eventService.createEvent(event);
        return "success";
    }

    @PostMapping("/find")
    public List<Event> getEvents(@RequestBody EventDto eventDto) {
        return eventService.getEvents(eventDto);
    }
}
