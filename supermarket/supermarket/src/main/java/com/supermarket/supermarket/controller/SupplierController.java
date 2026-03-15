package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CreateSupplierRequest;
import com.supermarket.supermarket.dto.request.UpdateSupplierRequest;
import com.supermarket.supermarket.dto.response.SupplierListItemResponse;
import com.supermarket.supermarket.service.SupplierService;
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
@RequestMapping("/api/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @GetMapping
    public ResponseEntity<List<SupplierListItemResponse>> getAllSuppliers() {
        return ResponseEntity.ok(supplierService.getAllSuppliers());
    }

    @PostMapping
    public ResponseEntity<SupplierListItemResponse> createSupplier(
        @Valid @RequestBody CreateSupplierRequest request
    ) {
        SupplierListItemResponse created = supplierService.createSupplier(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SupplierListItemResponse> updateSupplier(
        @PathVariable("id") Integer id,
        @Valid @RequestBody UpdateSupplierRequest request
    ) {
        SupplierListItemResponse updated = supplierService.updateSupplier(id, request);
        return ResponseEntity.ok(updated);
    }
}
