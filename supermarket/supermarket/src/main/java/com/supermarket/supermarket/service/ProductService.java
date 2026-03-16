package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import java.util.List;

public interface ProductService {

    List<ProductListItemResponse> getAllProducts();
}

