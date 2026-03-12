package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.LoginRequest;
import com.supermarket.supermarket.dto.response.LoginResponse;
import com.supermarket.supermarket.entity.Role;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.UserRepository;
import com.supermarket.supermarket.service.AuthService;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public LoginResponse login(LoginRequest request) {
        String identifier = request.getEmail().trim();

        return userRepository.findByUsernameIgnoreCaseOrEmailIgnoreCase(identifier, identifier)
            .map(user -> validatePasswordAndBuildResponse(user, request.getPassword()))
            .orElseGet(() -> LoginResponse.builder()
                .success(false)
                .message("Invalid email/username or password")
                .build());
    }

    private LoginResponse validatePasswordAndBuildResponse(User user, String rawPassword) {
        if (user.getStatus() != null && "deactive".equalsIgnoreCase(user.getStatus())) {
            return LoginResponse.builder()
                .success(false)
                .message("Account is deactivated")
                .build();
        }

        if (!isPasswordMatched(rawPassword, user.getPasswordHash())) {
            return LoginResponse.builder()
                .success(false)
                .message("Invalid email/username or password")
                .build();
        }

        user.setLastLogin(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        String roleName = getRoleName(user.getRole());
        return LoginResponse.builder()
            .success(true)
            .message("Login successful")
            .userId(user.getId())
            .username(user.getUsername())
            .fullName(user.getFullname())
            .role(roleName)
            .redirectTo(resolveRouteByRole(roleName))
            .build();
    }

    private boolean isPasswordMatched(String rawPassword, String storedPasswordHash) {
        if (storedPasswordHash == null || storedPasswordHash.isBlank()) {
            return false;
        }

        // Supports both BCrypt hash and plain text seed data.
        if (storedPasswordHash.startsWith("$2a$") || storedPasswordHash.startsWith("$2b$")) {
            try {
                return passwordEncoder.matches(rawPassword, storedPasswordHash);
            } catch (IllegalArgumentException ex) {
                // Handle invalid BCrypt strings in seed/demo data.
                return rawPassword.equals(storedPasswordHash);
            }
        }

        return rawPassword.equals(storedPasswordHash);
    }

    private String getRoleName(Role role) {
        return role == null || role.getName() == null ? "UNKNOWN" : role.getName();
    }

    private String resolveRouteByRole(String roleName) {
        String normalized = roleName.toLowerCase();
        if (normalized.contains("admin")) {
            return "/admin/dashboard";
        }
        if (normalized.contains("manager")) {
            return "/manager/dashboard";
        }
        if (normalized.contains("cashier")) {
            return "/cashier/home";
        }
        return "/home";
    }
}
