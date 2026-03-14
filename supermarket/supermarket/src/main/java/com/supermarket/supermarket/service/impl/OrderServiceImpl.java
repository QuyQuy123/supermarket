package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.OrderDetailItemResponse;
import com.supermarket.supermarket.dto.response.OrderDetailResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.entity.OrderItem;
import com.supermarket.supermarket.entity.SalesOrder;
import com.supermarket.supermarket.repository.OrderItemRepository;
import com.supermarket.supermarket.repository.SalesOrderRepository;
import com.supermarket.supermarket.service.OrderService;
import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final SalesOrderRepository salesOrderRepository;
    private final OrderItemRepository orderItemRepository;

    @Override
    public List<OrderListItemResponse> getAllOrders() {
        return salesOrderRepository.findAllByOrderByCreatedAtDescIdDesc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public OrderDetailResponse getOrderDetail(Integer orderId) {
        SalesOrder order = salesOrderRepository.findById(orderId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));

        List<OrderDetailItemResponse> items = orderItemRepository.findByOrder_IdOrderByIdAsc(orderId)
            .stream()
            .map(this::toDetailItem)
            .toList();

        return OrderDetailResponse.builder()
            .id(order.getId())
            .orderNo(emptyAsDash(order.getOrderNo()))
            .customerPhone(emptyAsDash(order.getCustomerPhone()))
            .cashierName(resolveCashierName(order))
            .subtotal(orZero(order.getSubtotal()))
            .discountPercent(orZero(order.getDiscountPercent()))
            .discountAmount(orZero(order.getDiscountAmount()))
            .totalPayment(orZero(order.getTotalPayable()))
            .items(items)
            .build();
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

    private OrderDetailItemResponse toDetailItem(OrderItem item) {
        Integer qty = Objects.requireNonNullElse(item.getQty(), 0);
        return OrderDetailItemResponse.builder()
            .productName(emptyAsDash(item.getProductName()))
            .unitPrice(orZero(item.getUnitPrice()))
            .qty(qty)
            .amount(orZero(item.getAmount()))
            .build();
    }
}

