package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Customer;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {

    List<Customer> findAllByOrderByNameAsc();

    Optional<Customer> findByPhone(String phone);
}
