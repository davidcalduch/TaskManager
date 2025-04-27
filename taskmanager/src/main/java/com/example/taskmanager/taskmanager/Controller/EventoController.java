package com.example.taskmanager.taskmanager.Controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;

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
    public Map<String, List<Evento>> getEventos() {
        List<Evento> eventos = eventoRepository.findAll();
        return Collections.singletonMap("data", eventos);
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
    @GetMapping("/user_id/{id}")
    public List<Evento> getEventosPorUsuario(@PathVariable("id") Long usuarioId) {
        // Verifica si el usuario existe
        if (!userRepository.existsById(usuarioId)) {
            throw new IllegalArgumentException("User not found with ID: " + usuarioId);
        }

        // Si el usuario existe, obtener sus eventos
        return eventoRepository.findByUsuarioId(usuarioId);
    }
    @PutMapping("/{id}")
    public ResponseEntity<Evento> updateEvento(@PathVariable Long id, @RequestBody Evento evento) {
        Evento existingEvento = eventoRepository.findById(id).orElseThrow(() -> new RuntimeException("Evento no encontrado"));
        existingEvento.setNombre(evento.getNombre());
        existingEvento.setDescripcion(evento.getDescripcion());
        existingEvento.setFecha(evento.getFecha());
        existingEvento.setHora(evento.getHora());
        existingEvento.setColor(evento.getColor());
        
        // Guardamos el evento actualizado
        Evento updatedEvento = eventoRepository.save(existingEvento);
        
        return ResponseEntity.ok(updatedEvento);
    }
    

}