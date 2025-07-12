package com.proevolutionit.ticketevolution.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "event")
@Getter
@Setter
public class Event {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    @JsonFormat(pattern="dd/MM/yyyy")
    private Date eventDate;
    private Integer price;
    private Integer totalTickets;
    private Integer soldTickets;
}
