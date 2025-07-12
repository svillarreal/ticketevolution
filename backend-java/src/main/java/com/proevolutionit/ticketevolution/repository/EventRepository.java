package com.proevolutionit.ticketevolution.repository;

import com.proevolutionit.ticketevolution.entity.Event;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Repository
public interface EventRepository extends CrudRepository<Event, UUID> {

    @Query("""
    SELECT e
      FROM Event e
     WHERE LOWER(e.name) LIKE LOWER(CONCAT('%', COALESCE(:name, e.name), '%'))
       AND e.eventDate >= COALESCE(:eventDateFrom, e.eventDate)
       AND e.eventDate <= COALESCE(:eventDateTo,   e.eventDate)
  """)
    List<Event> findEventByNameContainingIgnoreCaseAndEventDate(
            @Param("name")            String name,
            @Param("eventDateFrom")   Date   eventDateFrom,
            @Param("eventDateTo")     Date   eventDateTo
    );
}
