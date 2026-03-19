package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.CategoryOptionResponse;
import com.supermarket.supermarket.repository.CategoryRepository;
import com.supermarket.supermarket.service.CategoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryOptionResponse> getAllCategoryOptions() {
        return categoryRepository.findAll().stream()
            .map(c -> CategoryOptionResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .build())
            .toList();
    }
}
