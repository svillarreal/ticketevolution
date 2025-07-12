package com.proevolutionit.ticketevolution.service;

import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.entity.dto.OrderDto;

import java.util.List;

public interface OrderService {
    void createOrder(Order order);

    List<Order> findOrdersByEventAndUserAndCreatedAtfindOrdersByEventAndUserAndCreatedAt(OrderDto orderDto);
}
