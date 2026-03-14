package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.SalesOrder;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SalesOrderRepository extends JpaRepository<SalesOrder, Integer> {
    List<SalesOrder> findAllByOrderByCreatedAtDescIdDesc();
}

