package com.proevolutionit.ticketevolution.service.impl;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.entity.dto.EventDto;
import com.proevolutionit.ticketevolution.repository.EventRepository;
import com.proevolutionit.ticketevolution.service.EventService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
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
        event.ifPresent(value -> {
            value.setSoldTickets(value.getSoldTickets() + order.getTotalTickets());
            eventRepository.save(value);
        });
    }

    @Override
    public List<Event> getEvents(EventDto eventDto) {
        Calendar calendar = Calendar.getInstance();
        Date eventDateTo = eventDto.getEventDateTo();
        if (eventDateTo != null) {
            calendar.setTime(eventDateTo);
            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 999);
            eventDateTo = calendar.getTime();
        }

        Date eventDateFrom = eventDto.getEventDateTo();
        if (eventDateFrom != null) {
            calendar.setTime(eventDateFrom);
            calendar.set(Calendar.HOUR_OF_DAY, 0);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
            eventDateFrom = calendar.getTime();
        }

        return eventRepository.findEventByNameContainingIgnoreCaseAndEventDate(eventDto.getName(),
                eventDateFrom,
                eventDateTo);
    }
}
