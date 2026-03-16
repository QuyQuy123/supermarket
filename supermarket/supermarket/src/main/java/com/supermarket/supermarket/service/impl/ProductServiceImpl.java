package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import com.supermarket.supermarket.entity.Product;
import com.supermarket.supermarket.repository.ProductRepository;
import com.supermarket.supermarket.service.ProductService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    @Override
    public List<ProductListItemResponse> getAllProducts() {
        return productRepository.findAllByOrderByIdAsc().stream()
            .map(this::toListItem)
            .toList();
    }

    private ProductListItemResponse toListItem(Product p) {
        final Integer inStock = p.getInStock() == null ? 0 : p.getInStock();
        final String status =
            p.getStatus() != null && !p.getStatus().isBlank()
                ? p.getStatus()
                : (inStock > 0 ? "In Stock" : "Out of Stock");

        return ProductListItemResponse.builder()
            .id(p.getId())
            .barcode(p.getBarcode())
            .productName(p.getProductName())
            .categoryName(p.getCategory() != null ? p.getCategory().getName() : null)
            .expiryDate(p.getExpiryDate())
            .sellingPrice(p.getSellingPrice())
            .inStock(inStock)
            .status(status)
            .build();
    }
}

