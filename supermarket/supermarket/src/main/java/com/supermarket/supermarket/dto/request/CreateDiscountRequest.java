package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateDiscountRequest {
    @NotBlank(message = "Discount name is required")
    private String name;

    @NotNull(message = "Discount percent is required")
    @Positive(message = "Discount percent must be positive")
    private BigDecimal percent;

    @NotNull(message = "Min order amount is required")
    @Positive(message = "Min order amount must be positive")
    private BigDecimal minOrderAmount;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    @NotNull(message = "End date is required")
    private LocalDate endDate;
}
