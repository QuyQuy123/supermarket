package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CreateCustomerRequest;
import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerDetailResponse;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.service.CustomerService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping
    public ResponseEntity<List<CustomerListItemResponse>> getAllCustomers() {
        return ResponseEntity.ok(customerService.getAllCustomers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerDetailResponse> getCustomerDetail(@PathVariable("id") Integer id) {
        return ResponseEntity.ok(customerService.getCustomerDetail(id));
    }

    @PostMapping
    public ResponseEntity<CustomerListItemResponse> createCustomer(@Valid @RequestBody CreateCustomerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(customerService.createCustomer(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CustomerListItemResponse> updateCustomer(
            @PathVariable("id") Integer id,
            @Valid @RequestBody UpdateCustomerRequest request) {
        return ResponseEntity.ok(customerService.updateCustomer(id, request));
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<List<OrderListItemResponse>> getCustomerOrderHistory(@PathVariable("id") Integer id) {
        // Retrieve the customer history
        List<OrderListItemResponse> customerOrderHistory = customerService.getCustomerOrderHistory(id);
        return ResponseEntity.ok(customerOrderHistory);
    }
}
