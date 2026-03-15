package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.SupplierListItemResponse;
import java.util.List;

public interface SupplierService {

    List<SupplierListItemResponse> getAllSuppliers();
}
