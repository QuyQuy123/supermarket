package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import java.util.List;

public interface OrderService {
    List<OrderListItemResponse> getAllOrders();
}

