package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.dto.response.OrderDetailResponse;
import java.util.List;

public interface OrderService {
    List<OrderListItemResponse> getAllOrders();

    OrderDetailResponse getOrderDetail(Integer orderId);
}

