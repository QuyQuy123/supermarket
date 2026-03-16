package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import com.supermarket.supermarket.service.ProductService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<List<ProductListItemResponse>> getAllProducts() {
        return ResponseEntity.ok(productService.getAllProducts());
    }
}

