package com.doctorappointment.config;

import com.doctorappointment.entity.Role;
import com.doctorappointment.entity.User;
import com.doctorappointment.repository.UserRepository;
import com.doctorappointment.service.AuthService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class AdminAccountInitializer implements ApplicationRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String password;

    public AdminAccountInitializer(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            @Value("${app.admin.email:}") String email,
            @Value("${app.admin.password:}") String password) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.email = email;
        this.password = password;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (email.isBlank() && password.isBlank()) {
            return;
        }
        if (email.isBlank() || password.length() < 12) {
            throw new IllegalStateException(
                    "Set ADMIN_EMAIL and an ADMIN_PASSWORD with at least 12 characters together");
        }

        String normalizedEmail = AuthService.normalizeEmail(email);
        userRepository.findByEmail(normalizedEmail).ifPresentOrElse(
                existing -> {
                    if (existing.getRole() != Role.ADMIN) {
                        throw new IllegalStateException(
                                "Configured administrator email belongs to a non-admin account");
                    }
                },
                () -> userRepository.save(new User(
                        "Administrator",
                        normalizedEmail,
                        passwordEncoder.encode(password),
                        Role.ADMIN)));
    }
}
