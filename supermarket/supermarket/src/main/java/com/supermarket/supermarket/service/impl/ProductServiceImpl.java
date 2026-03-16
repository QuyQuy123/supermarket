package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.ProductDetailResponse;
import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import com.supermarket.supermarket.entity.Product;
import com.supermarket.supermarket.repository.ProductRepository;
import com.supermarket.supermarket.service.ProductService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ProductListItemResponse> getAllProducts() {
        return productRepository.findAllByOrderByIdAsc().stream()
            .map(this::toListItem)
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ProductDetailResponse getProductDetail(Integer id) {
        return productRepository.findById(id)
            .map(this::toDetail)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found with id: " + id));
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

    private ProductDetailResponse toDetail(Product p) {
        final Integer inStock = p.getInStock() == null ? 0 : p.getInStock();
        final String status =
            p.getStatus() != null && !p.getStatus().isBlank()
                ? p.getStatus()
                : (inStock > 0 ? "In Stock" : "Out of Stock");

        return ProductDetailResponse.builder()
            .id(p.getId())
            .barcode(p.getBarcode())
            .productName(p.getProductName())
            .productBatch(p.getProductBatch())
            .description(p.getDescription())
            .costPrice(p.getCostPrice())
            .sellingPrice(p.getSellingPrice())
            .qtyCartons(p.getQtyCartons())
            .inStock(inStock)
            .supplierName(p.getSupplier() != null ? p.getSupplier().getSupplierName() : null)
            .categoryName(p.getCategory() != null ? p.getCategory().getName() : null)
            .mftDate(p.getMftDate())
            .expiryDate(p.getExpiryDate())
            .status(status)
            .imageUrl(p.getImageUrl())
            .build();
    }
}

