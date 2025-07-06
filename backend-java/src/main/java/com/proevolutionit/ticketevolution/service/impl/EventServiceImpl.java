package com.proevolutionit.ticketevolution.service.impl;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.repository.EventRepository;
import com.proevolutionit.ticketevolution.service.EventService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class EventServiceImpl implements EventService {

    @Autowired
    private EventRepository eventRepository;

    @Transactional
    @Override
    public void createEvent(Event event) {
        event.setSoldTickets(0);
        eventRepository.save(event);
    }

    @Transactional
    @Override
    public void sellTickets(Order order) {
        Optional<Event> event = eventRepository.findById(order.getEventId());
        event.ifPresent(value ->  {
            value.setSoldTickets(value.getSoldTickets() + order.getTotalTickets());
            eventRepository.save(value);
        });
    }
}
