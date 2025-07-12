package com.proevolutionit.ticketevolution.repository;

import com.proevolutionit.ticketevolution.entity.Order;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends CrudRepository<Order, UUID> {

    @Query("""
              SELECT o
                FROM Order o
               WHERE o.userId      = COALESCE(:userId,       o.userId)
                 AND o.eventId     = COALESCE(:eventId,      o.eventId)
                 AND o.createdAt   >= COALESCE(:createdAtFrom, o.createdAt)
                 AND o.createdAt   <= COALESCE(:createdAtTo,   o.createdAt)
            """)
    List<Order> findOrdersByEventAndUserAndCreatedAt(
            @Param("userId")          UUID   userId,
            @Param("eventId")         UUID   eventId,
            @Param("createdAtFrom")   Date   createdAtFrom,
            @Param("createdAtTo")     Date   createdAtTo
    );
}

