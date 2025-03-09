package com.example.taskmanager.taskmanager.service;

import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.stereotype.Component;

@Component
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable() // Desactiva CSRF para pruebas, puede estar bloqueando el POST
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/tasks/**").authenticated()
                .anyRequest().permitAll()
            )
            .httpBasic(); // Habilita autenticación básica
        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        UserDetails user = User.builder()
            .username("david")
            .password("{noop}Pitita_44") // {noop} evita encriptación de contraseña
            .roles("USER")
            .build();
        return new InMemoryUserDetailsManager(user);
    }
}