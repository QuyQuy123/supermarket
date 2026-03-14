package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.OrderItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findByOrder_IdOrderByIdAsc(Integer orderId);
}

