package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.CategoryOptionResponse;
import java.util.List;

public interface CategoryService {

    List<CategoryOptionResponse> getAllCategoryOptions();
}
