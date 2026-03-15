package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.SupplierListItemResponse;
import com.supermarket.supermarket.entity.Supplier;
import com.supermarket.supermarket.repository.SupplierRepository;
import com.supermarket.supermarket.service.SupplierService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepository supplierRepository;

    @Override
    public List<SupplierListItemResponse> getAllSuppliers() {
        return supplierRepository.findAllByOrderByIdAsc()
            .stream()
            .map(this::toListItemResponse)
            .toList();
    }

    private SupplierListItemResponse toListItemResponse(Supplier s) {
        return SupplierListItemResponse.builder()
            .id(s.getId())
            .supplierName(s.getSupplierName())
            .companyName(s.getCompanyName())
            .email(s.getEmail())
            .phone(s.getPhone())
            .address(s.getAddress())
            .status(s.getStatus())
            .createdAt(s.getCreatedAt())
            .build();
    }
}
