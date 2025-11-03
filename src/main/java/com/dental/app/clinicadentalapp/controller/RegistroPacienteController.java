/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.dao.PacienteDAO;
import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Matheus
 */
@WebServlet(name = "RegistroPacienteController", urlPatterns = {"/registroPaciente"})
public class RegistroPacienteController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Obtener los nuevos datos del formulario
        String documento = request.getParameter("documento");
        String nombre = request.getParameter("nombre"); // Nuevo
        String apellido = request.getParameter("apellido"); // Nuevo
        String email = request.getParameter("email");
        String genero = request.getParameter("genero"); // Nuevo
        
        // 2. Crear los objetos del modelo
        Usuario usuario = new Usuario();
        usuario.setDocumentoIdentidad(documento);

        Paciente paciente = new Paciente();
        paciente.setNombre(nombre);
        paciente.setApellido(apellido);
        paciente.setEmail(email);
        paciente.setGenero(genero);
        paciente.setUsuario(usuario);
        
        // 3. Usar el DAO para registrar
        PacienteDAO pacienteDAO = new PacienteDAO();
        
        // ===== CAMBIO AQUÍ: Se pasa 'documento' (DNI) como password por defecto =====
        boolean exito = pacienteDAO.registrarPaciente(paciente, documento);
        
        // 4. Redirigir a la página de pacientes con un mensaje
        if (exito) {
            response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&registro=exito");
        } else {
            response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&registro=error");
        }
    }
}