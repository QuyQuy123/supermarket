package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateCustomerRequest;
import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerDetailResponse;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.entity.Customer;
import com.supermarket.supermarket.repository.CustomerRepository;
import com.supermarket.supermarket.service.CustomerService;
import com.supermarket.supermarket.service.OrderService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;
    private final OrderService orderService;

    @Override
    public List<CustomerListItemResponse> getAllCustomers() {
        return customerRepository.findAllByOrderByNameAsc()
            .stream()
            .map(this::toListItem)
            .toList();
    }

    @Override
    public CustomerDetailResponse getCustomerDetail(Integer id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Customer not found"));
        return toDetail(customer);
    }

    @Override
    public CustomerListItemResponse createCustomer(CreateCustomerRequest request) {
        String phone = request.getPhone().trim();
        if (customerRepository.findByPhone(phone).isPresent()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number already registered");
        }
        LocalDateTime now = LocalDateTime.now();
        Customer customer = Customer.builder()
            .name(request.getName().trim())
            .phone(phone)
            .points(0)
            .totalPurchases(0)
            .totalAmount(request.getTotalAmount() != null ? request.getTotalAmount() : BigDecimal.ZERO)
            .createdAt(now)
            .updatedAt(now)
            .build();
        Customer saved = customerRepository.save(customer);
        return toListItem(saved);
    }

    @Override
    public CustomerListItemResponse updateCustomer(Integer id, UpdateCustomerRequest request) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Customer not found"));
        String phone = request.getPhone().trim();
        customerRepository.findByPhone(phone).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number already used by another customer");
            }
        });
        customer.setName(request.getName().trim());
        customer.setPhone(phone);
        if (request.getTotalAmount() != null) {
            customer.setTotalAmount(request.getTotalAmount());
        }
        customer.setUpdatedAt(LocalDateTime.now());
        Customer saved = customerRepository.save(customer);
        return toListItem(saved);
    }

    @Override
    public List<OrderListItemResponse> getCustomerOrderHistory(Integer customerId) {
        if (!customerRepository.existsById(customerId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Customer not found");
        }
        return orderService.getOrdersByCustomerId(customerId);
    }

    private CustomerListItemResponse toListItem(Customer c) {
        return CustomerListItemResponse.builder()
            .id(c.getId())
            .name(emptyAsDash(c.getName()))
            .phone(emptyAsDash(c.getPhone()))
            .points(c.getPoints() != null ? c.getPoints() : 0)
            .totalPurchases(c.getTotalPurchases() != null ? c.getTotalPurchases() : 0)
            .totalAmount(c.getTotalAmount() != null ? c.getTotalAmount() : BigDecimal.ZERO)
            .build();
    }

    private CustomerDetailResponse toDetail(Customer c) {
        Integer discountId = null;
        String discountName = null;
        if (c.getDiscount() != null) {
            discountId = c.getDiscount().getId();
            discountName = c.getDiscount().getName();
        }
        return CustomerDetailResponse.builder()
            .id(c.getId())
            .name(emptyAsDash(c.getName()))
            .phone(emptyAsDash(c.getPhone()))
            .points(c.getPoints() != null ? c.getPoints() : 0)
            .totalPurchases(c.getTotalPurchases() != null ? c.getTotalPurchases() : 0)
            .totalAmount(c.getTotalAmount() != null ? c.getTotalAmount() : BigDecimal.ZERO)
            .discountId(discountId)
            .discountName(discountName != null ? discountName : "—")
            .createdAt(c.getCreatedAt())
            .updatedAt(c.getUpdatedAt())
            .build();
    }

    private static String emptyAsDash(String value) {
        return value == null || value.isBlank() ? "—" : value;
    }
}
