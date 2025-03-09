package com.example.taskmanager.taskmanager.Controller;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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
import com.example.taskmanager.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.taskmanager.repository.TaskRepository;

@CrossOrigin(origins= "*")
@RestController
@RequestMapping("/tasks")

public class TaskController {
    @Autowired
    private TaskRepository taskRepository;

    @GetMapping
    public List<Task1> getTasks() {
        return taskRepository.findAll();
    }
    @PostMapping
    public Task1 createTask(@RequestBody Task1 task) {
        System.out.println("📩 Recibiendo tarea con dueDate: " + task.getDueDate());
        System.out.println(task);
        
        Task1 savedTask = taskRepository.save(task); 
        
        System.out.println("📝 Tarea guardada: ID: " + savedTask.getId());
        System.out.println(savedTask); 
        
        return savedTask; 
    }
 
    @PutMapping("/{id}")
    public Task1 updateTask(@PathVariable Long id, @RequestBody Task1 task) 
    {
    Task1 taskToUpdate = taskRepository.findById(id)
        .orElseThrow(() -> new TaskNotFoundException(id));
    taskToUpdate.setTitle(task.getTitle());
    taskToUpdate.setDescription(task.getDescription());
    /*taskToUpdate.setDueDate(task.getDueDate());*/
    taskToUpdate.setPriority(task.getPriority());
    taskToUpdate.setCompleted(task.isCompleted());
    return taskRepository.save(taskToUpdate);
    }

    @DeleteMapping("/{id}")
    public void deleteTask(@PathVariable Long id) {
        taskRepository.deleteById(id);
    }
}