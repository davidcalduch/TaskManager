package com.example.taskmanager.taskmanager.exception;
import com.example.taskmanager.taskmanager.exception.TaskNotFoundException;



public class TaskNotFoundException extends RuntimeException {
    public TaskNotFoundException(Long id) {
        super("Task with ID " + id + " not found");
    }
}