package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.service.OrderService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<List<OrderListItemResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }
}

