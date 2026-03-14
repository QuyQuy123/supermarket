package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.entity.SalesOrder;
import com.supermarket.supermarket.repository.SalesOrderRepository;
import com.supermarket.supermarket.service.OrderService;
import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final SalesOrderRepository salesOrderRepository;

    @Override
    public List<OrderListItemResponse> getAllOrders() {
        return salesOrderRepository.findAllByOrderByCreatedAtDescIdDesc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    private OrderListItemResponse toResponse(SalesOrder order) {
        return OrderListItemResponse.builder()
            .id(order.getId())
            .orderNo(emptyAsDash(order.getOrderNo()))
            .customerName(resolveCustomerName(order))
            .customerPhone(emptyAsDash(order.getCustomerPhone()))
            .total(orZero(order.getSubtotal()))
            .discountPercent(orZero(order.getDiscountPercent()))
            .payable(orZero(order.getTotalPayable()))
            .paid(order.getPaid())
            .paymentMethod(emptyAsDash(order.getPaymentMethod()))
            .status(emptyAsDash(order.getStatus()))
            .cashierName(resolveCashierName(order))
            .build();
    }

    private String resolveCustomerName(SalesOrder order) {
        if (order.getCustomerName() != null && !order.getCustomerName().isBlank()) {
            return order.getCustomerName();
        }
        if (order.getCustomer() != null && order.getCustomer().getName() != null && !order.getCustomer().getName().isBlank()) {
            return order.getCustomer().getName();
        }
        return "—";
    }

    private String resolveCashierName(SalesOrder order) {
        if (order.getCashier() == null) {
            return "—";
        }
        if (order.getCashier().getFullname() != null && !order.getCashier().getFullname().isBlank()) {
            return order.getCashier().getFullname();
        }
        if (order.getCashier().getUsername() != null && !order.getCashier().getUsername().isBlank()) {
            return order.getCashier().getUsername();
        }
        return "—";
    }

    private String emptyAsDash(String value) {
        return value == null || value.isBlank() ? "—" : value;
    }

    private BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}

