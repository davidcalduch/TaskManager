package com.example.taskmanager.taskmanager.Controller;

import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.taskmanager.taskmanager.Model.User;
import com.example.taskmanager.taskmanager.repository.UserRepository;
import com.example.taskmanager.taskmanager.Model.LoginRequest;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        if (userRepository.findByName(user.getName()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Nombre de usuario ya existe");
        }
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email ya registrado");
        }

        userRepository.save(user);
        return ResponseEntity.ok("Usuario registrado exitosamente");
    }
    @PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
    Optional<User> optionalUser = userRepository.findByEmail(loginRequest.getEmail());

    if (optionalUser.isPresent() && optionalUser.get().getPassword().equals(loginRequest.getPassword())) {
        return ResponseEntity.ok(optionalUser.get());
    } else {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }
}  }
    

