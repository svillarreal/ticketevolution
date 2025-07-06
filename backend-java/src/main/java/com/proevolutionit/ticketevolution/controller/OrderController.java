package com.proevolutionit.ticketevolution.controller;

import com.proevolutionit.ticketevolution.entity.Event;
import com.proevolutionit.ticketevolution.entity.Order;
import com.proevolutionit.ticketevolution.service.EventService;
import com.proevolutionit.ticketevolution.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping
    public String createOrder(@RequestBody Order order){
        orderService.createOrder(order);
        return "success";
    }
}
