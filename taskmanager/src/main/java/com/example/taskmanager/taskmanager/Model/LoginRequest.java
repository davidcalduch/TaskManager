package com.example.taskmanager.taskmanager.Model;
import jakarta.persistence.Column;

public class LoginRequest {
    private String email;
    private String password;

    // Constructor vacío (necesario para deserialización JSON)
    public LoginRequest() {
    }

    // Getters y setters
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}