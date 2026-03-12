package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateUserRequest {

    @NotBlank(message = "Fullname is required")
    @Size(max = 100, message = "Fullname must be <= 100 characters")
    private String fullname;

    @NotBlank(message = "Username is required")
    @Size(max = 50, message = "Username must be <= 50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Email is invalid")
    @Size(max = 100, message = "Email must be <= 100 characters")
    private String email;

    @Size(min = 6, max = 100, message = "Password must be between 6 and 100 characters")
    private String password;

    @Size(max = 20, message = "ID card must be <= 20 characters")
    private String idCard;

    @NotBlank(message = "User role is required")
    private String userRole;
}
