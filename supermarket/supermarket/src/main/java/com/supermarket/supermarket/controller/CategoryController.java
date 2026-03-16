package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.response.CategoryOptionResponse;
import com.supermarket.supermarket.service.CategoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping("/options")
    public ResponseEntity<List<CategoryOptionResponse>> getCategoryOptions() {
        return ResponseEntity.ok(categoryService.getAllCategoryOptions());
    }
}
