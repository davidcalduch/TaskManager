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

import com.example.taskmanager.taskmanager.Model.Evento;
import com.example.taskmanager.taskmanager.Model.Task1;
import com.example.taskmanager.taskmanager.Model.User;
import com.example.taskmanager.taskmanager.exception.TaskNotFoundException;
import com.example.taskmanager.taskmanager.repository.EventoRepository;
import com.example.taskmanager.taskmanager.repository.TaskRepository;
import com.example.taskmanager.taskmanager.repository.UserRepository;

@CrossOrigin(origins= "*")
@RestController
@RequestMapping("/eventos")
public class EventoController {

   @Autowired
   private UserRepository userRepository;
   @Autowired
   private EventoRepository eventoRepository;

   @GetMapping
    public List<Evento> getEventos() {
         return eventoRepository.findAll();
    }
    @PostMapping
    public Evento createEvento(@RequestBody Evento evento) {
        System.out.println("Recibiendo informacion: " + evento.getNombre());
        System.out.println("Recibiendo informacion: " + evento.getDescripcion());
        if (evento.getUsuario() == null || evento.getUsuario().getId() == null) {
            throw new IllegalArgumentException("User ID must be provided in the task payload.");
        }
        System.out.println("Recibiendo informacion: " + evento.getNombre());
        System.out.println("Recibiendo informacion: " + evento.getDescripcion());

        User user = userRepository.findById(evento.getUsuario().getId())
            .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + evento.getUsuario().getId()));

        evento.setUser(user);

        System.out.println("📩 Recibiendo tarea con dueDate: " + evento.getFecha());
        System.out.println("Recibiendo informacion: " + evento.getNombre());
        System.out.println("Recibiendo informacion: " + evento.getDescripcion());
        Evento savedEvento = eventoRepository.save(evento); 
        System.out.println("📝 Tarea guardada: ID: " + savedEvento.getId());
        return savedEvento; 
    }

}