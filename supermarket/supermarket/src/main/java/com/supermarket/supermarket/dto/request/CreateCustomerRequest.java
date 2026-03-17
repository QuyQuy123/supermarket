package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateCustomerRequest {

    @NotBlank(message = "Customer name is required")
    @Size(max = 100, message = "Name must be <= 100 characters")
    private String name;

    @NotBlank(message = "Phone is required")
    @Size(max = 20, message = "Phone must be <= 20 characters")
    private String phone;

    private java.math.BigDecimal totalAmount;
}
