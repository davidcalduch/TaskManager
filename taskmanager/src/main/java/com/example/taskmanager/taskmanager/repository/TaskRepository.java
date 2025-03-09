package com.example.taskmanager.taskmanager.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.example.taskmanager.taskmanager.Model.Task1;
import com.example.taskmanager.taskmanager.repository.TaskRepository;


@Repository
public interface TaskRepository extends JpaRepository<Task1, Long> {
}
