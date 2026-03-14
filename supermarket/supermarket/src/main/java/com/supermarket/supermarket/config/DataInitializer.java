package com.supermarket.supermarket.config;

import com.supermarket.supermarket.entity.Role;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.RoleRepository;
import com.supermarket.supermarket.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

@Configuration
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Ensure ADMIN role exists
        Role adminRole = roleRepository.findByNameIgnoreCase("ADMIN")
            .orElseGet(() -> {
                Role role = Role.builder().name("ADMIN").build();
                return roleRepository.save(role);
            });

        // Seed/Update requested access email for all roles
        String targetEmail = "thaoltthe186989@fpt.edu.vn";
        String[] defaultUsernames = {"admin01", "manager01", "cashier01", "thaoltthe186989"};

        for (String uname : defaultUsernames) {
            userRepository.findByUsernameIgnoreCase(uname).ifPresentOrElse(
                user -> {
                    // Update existing users to use the accessible email for testing
                    user.setEmail(targetEmail);
                    userRepository.save(user);
                    System.out.println("Updated email for: " + uname + " to " + targetEmail);
                },
                () -> {
                    // Create if doesn't exist (only for the main one)
                    if (uname.equals("thaoltthe186989")) {
                        User user = User.builder()
                            .username(uname)
                            .email(targetEmail)
                            .passwordHash(passwordEncoder.encode("Thanhthao2004!"))
                            .fullname("Thanh Thao")
                            .role(adminRole)
                            .status("active")
                            .createdAt(LocalDateTime.now())
                            .updatedAt(LocalDateTime.now())
                            .build();
                        userRepository.save(user);
                        System.out.println("Created root user: " + targetEmail);
                    }
                }
            );
        }
    }
}
