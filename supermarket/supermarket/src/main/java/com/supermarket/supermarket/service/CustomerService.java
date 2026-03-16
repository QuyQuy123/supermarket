package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import java.util.List;

public interface CustomerService {
    List<CustomerListItemResponse> getAllCustomers();

    CustomerListItemResponse updateCustomer(Integer customerId, UpdateCustomerRequest request);
}

