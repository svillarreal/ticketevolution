package com.proevolutionit.ticketevolution.service;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.Order;
import jakarta.transaction.Transactional;

public interface EventService {
    void createEvent(Event event);

    @Transactional
    void sellTickets(Order order);
}
