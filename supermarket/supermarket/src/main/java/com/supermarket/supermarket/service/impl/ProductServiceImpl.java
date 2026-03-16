package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateProductRequest;
import com.supermarket.supermarket.dto.response.ProductDetailResponse;
import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import com.supermarket.supermarket.entity.Category;
import com.supermarket.supermarket.entity.Product;
import com.supermarket.supermarket.entity.Supplier;
import com.supermarket.supermarket.repository.CategoryRepository;
import com.supermarket.supermarket.repository.ProductRepository;
import com.supermarket.supermarket.repository.SupplierRepository;
import com.supermarket.supermarket.service.ProductService;
import java.time.LocalDateTime;
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
    private final SupplierRepository supplierRepository;
    private final CategoryRepository categoryRepository;

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

    @Override
    @Transactional
    public ProductDetailResponse createProduct(CreateProductRequest request) {
        // Check if barcode already exists
        if (productRepository.existsByBarcode(request.getBarcode())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Barcode already exists");
        }

        Supplier supplier = null;
        if (request.getSupplierId() != null) {
            supplier = supplierRepository.findById(request.getSupplierId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found"));
        }

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
        }

        // Calculate initial stock from qtyCartons (assuming 1 carton = some units, or just use qtyCartons as stock)
        Integer initialStock = request.getQtyCartons() != null ? request.getQtyCartons() : 0;

        LocalDateTime now = LocalDateTime.now();
        Product product = Product.builder()
            .barcode(request.getBarcode().trim())
            .productBatch(trimOrNull(request.getProductBatch()))
            .productName(request.getProductName().trim())
            .description(trimOrNull(request.getDescription()))
            .costPrice(request.getCostPrice())
            .sellingPrice(request.getSellingPrice())
            .qtyCartons(request.getQtyCartons())
            .inStock(initialStock)
            .supplier(supplier)
            .category(category)
            .mftDate(request.getMftDate())
            .expiryDate(request.getExpiryDate())
            .status(initialStock > 0 ? "In Stock" : "Out of Stock")
            .imageUrl(trimOrNull(request.getImageUrl()))
            .createdAt(now)
            .updatedAt(now)
            .build();

        product = productRepository.save(product);
        return toDetail(product);
    }

    private static String trimOrNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}

