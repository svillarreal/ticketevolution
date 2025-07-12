package com.proevolutionit.ticketevolution.service;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.entity.dto.EventDto;

import java.util.List;

public interface EventService {
    void createEvent(Event event);

    void sellTickets(Order order);

    List<Event> getEvents(EventDto eventDto);
}
