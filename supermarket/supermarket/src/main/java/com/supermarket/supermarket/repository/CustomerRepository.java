package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Customer;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
    List<Customer> findAllByOrderByIdAsc();

    boolean existsByPhoneAndIdNot(String phone, Integer id);
}

