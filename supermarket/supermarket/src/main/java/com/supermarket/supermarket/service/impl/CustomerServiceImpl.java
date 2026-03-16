package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import com.supermarket.supermarket.entity.Customer;
import com.supermarket.supermarket.repository.CustomerRepository;
import com.supermarket.supermarket.service.CustomerService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;

    @Override
    public List<CustomerListItemResponse> getAllCustomers() {
        return customerRepository.findAllByOrderByIdAsc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public CustomerListItemResponse updateCustomer(Integer customerId, UpdateCustomerRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Customer not found"));

        String phone = request.getPhone().trim();
        if (customerRepository.existsByPhoneAndIdNot(phone, customerId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone already exists");
        }

        customer.setPhone(phone);
        customer.setTotalAmount(orZero(request.getTotalAmount()));
        customer.setUpdatedAt(LocalDateTime.now());
        customer = customerRepository.save(customer);
        return toResponse(customer);
    }

    private CustomerListItemResponse toResponse(Customer customer) {
        return CustomerListItemResponse.builder()
            .id(customer.getId())
            .name(emptyAsDash(customer.getName()))
            .phone(emptyAsDash(customer.getPhone()))
            .points(Objects.requireNonNullElse(customer.getPoints(), 0))
            .totalPurchases(Objects.requireNonNullElse(customer.getTotalPurchases(), 0))
            .totalAmount(orZero(customer.getTotalAmount()))
            .discountPercent(customer.getDiscount() == null ? BigDecimal.ZERO : orZero(customer.getDiscount().getPercent()))
            .build();
    }

    private BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private String emptyAsDash(String value) {
        return value == null || value.isBlank() ? "—" : value;
    }
}

