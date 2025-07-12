package com.proevolutionit.ticketevolution.entity.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class EventDto {

    private String name;
    private Date eventDateFrom;
    private Date eventDateTo;
}
