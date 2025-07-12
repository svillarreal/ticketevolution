package com.proevolutionit.ticketevolution.service.impl;

import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.entity.dto.OrderDto;
import com.proevolutionit.ticketevolution.repository.OrderRepository;
import com.proevolutionit.ticketevolution.service.EventService;
import com.proevolutionit.ticketevolution.service.OrderService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private EventService eventService;

    @Transactional
    @Override
    public void createOrder(Order order) {
        order.setCreatedAt(new Date());
        eventService.sellTickets(order);
        orderRepository.save(order);
    }

    @Override
    public List<Order> findOrdersByEventAndUserAndCreatedAtfindOrdersByEventAndUserAndCreatedAt(OrderDto orderDto) {
        UUID eventId = orderDto.getEventId();
        UUID userId = orderDto.getUserId();
        Date createdAtFrom = orderDto.getCreatedAtFrom();
        Date createdAtTo = orderDto.getCreatedAtTo();
        Calendar calendar = Calendar.getInstance();
        if (createdAtFrom != null) {
            calendar.setTime(createdAtFrom);
            calendar.set(Calendar.HOUR_OF_DAY, 0);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
            createdAtFrom = calendar.getTime();
        }

        if (createdAtTo != null) {
            calendar.setTime(createdAtTo);
            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 999);
            createdAtTo = calendar.getTime();
        }
        return orderRepository.findOrdersByEventAndUserAndCreatedAt(userId, eventId, createdAtFrom, createdAtTo);
    }
}
