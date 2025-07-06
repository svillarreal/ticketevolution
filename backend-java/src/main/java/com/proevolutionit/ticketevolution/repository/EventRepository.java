package com.proevolutionit.ticketevolution.repository;

import com.proevolutionit.ticketevolution.entity.Event;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface EventRepository extends CrudRepository<Event, UUID> {
}
