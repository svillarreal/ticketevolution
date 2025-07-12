package com.proevolutionit.ticketevolution.entity.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.UUID;

@Getter
@Setter
public class OrderDto {
    private UUID eventId;
    private UUID userId;
    private Date createdAtFrom;
    private Date createdAtTo;
}
