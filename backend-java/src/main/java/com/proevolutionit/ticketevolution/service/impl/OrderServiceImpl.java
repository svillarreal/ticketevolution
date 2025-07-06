package com.proevolutionit.ticketevolution.service.impl;

import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.repository.OrderRepository;
import com.proevolutionit.ticketevolution.service.EventService;
import com.proevolutionit.ticketevolution.service.OrderService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

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
}
