package com.example.taskmanager.taskmanager.Controller;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.taskmanager.taskmanager.Model.Task1;
import com.example.taskmanager.taskmanager.Model.User;
import com.example.taskmanager.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.taskmanager.repository.TaskRepository;
import com.example.taskmanager.taskmanager.repository.UserRepository;

@CrossOrigin(origins= "*")
@RestController
@RequestMapping("/tasks")

public class TaskController {
    @Autowired
    private TaskRepository taskRepository;
     @Autowired
    private UserRepository userRepository;

    @GetMapping("/user/{userId}")
    public List<Task1> getTasksByUser(@PathVariable Long userId) {
    return taskRepository.findByUserId(userId);  // Asegúrate de que tienes este método en tu repositorio
    }
    @PostMapping
    public Task1 createTask(@RequestBody Task1 task) {
        if (task.getUser() == null || task.getUser().getId() == null) {
            throw new IllegalArgumentException("User ID must be provided in the task payload.");
        }

        User user = userRepository.findById(task.getUser().getId())
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + task.getUser().getId()));

        task.setUser(user);

        System.out.println("📩 Recibiendo tarea con dueDate: " + task.getDueDate());
        Task1 savedTask = taskRepository.save(task); 
        System.out.println("📝 Tarea guardada: ID: " + savedTask.getId());
        return savedTask; 
    }
 
   @PutMapping("/{id}")
public ResponseEntity<Task1> updateTask(@PathVariable Long id, @RequestBody Task1 task) {
    // Comprobamos si la tarea existe
    Task1 taskToUpdate = taskRepository.findById(id)
        .orElseThrow(() -> new TaskNotFoundException(id));
    
    // Si el task tiene un usuario válido
    if (task.getUser() != null && task.getUser().getId() != null) {
        User user = userRepository.findById(task.getUser().getId())
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + task.getUser().getId()));
        taskToUpdate.setUser(user); // Asignar el usuario correcto a la tarea
    }

    // Actualizamos la tarea con los nuevos valores
    taskToUpdate.setTitle(task.getTitle());
    taskToUpdate.setDescription(task.getDescription());
    taskToUpdate.setPriority(task.getPriority());
    taskToUpdate.setCompleted(task.isCompleted());
    
    // Si tienes un campo 'dueDate' en el futuro, descomenta esta línea y actualízala:
    // taskToUpdate.setDueDate(task.getDueDate());
    
    // Guardamos la tarea actualizada
    Task1 updatedTask = taskRepository.save(taskToUpdate);
    
    // Retornamos el resultado en un ResponseEntity
    return ResponseEntity.ok(updatedTask);
}
}