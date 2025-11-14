/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.PacienteDAO;
import com.dental.app.clinicadentalapp.model.Paciente;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Matheus
 */
@WebServlet(name = "PacienteController", urlPatterns = {"/paciente"})
public class PacienteController extends HttpServlet {

    private PacienteDAO pacienteDAO = new PacienteDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("update".equals(action)) {
            actualizarPaciente(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            eliminarPaciente(request, response);
        }
    }

    private void actualizarPaciente(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // === CAMBIO 1: Identificar de dónde viene la solicitud ===
        // (El formulario de "miperfil.jsp" deberá enviar este parámetro)
        String source = request.getParameter("source");

        try {
            int pacienteId = Integer.parseInt(request.getParameter("pacienteId"));
            
            Paciente paciente = new Paciente();
            paciente.setPacienteId(pacienteId);
            paciente.setNombre(request.getParameter("nombre"));
            paciente.setApellido(request.getParameter("apellido"));
            paciente.setEmail(request.getParameter("email"));
            paciente.setTelefono(request.getParameter("telefono"));
            paciente.setDireccion(request.getParameter("direccion"));
            paciente.setAlergias(request.getParameter("alergias"));
            paciente.setGenero(request.getParameter("genero"));

            // Convertir String a Date
            String fechaNacStr = request.getParameter("fechaNacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                paciente.setFechaNacimiento(sdf.parse(fechaNacStr));
            }

            // === CAMBIO 2: Redirección inteligente ===
            if (pacienteDAO.actualizarPaciente(paciente)) {
                if ("miperfil".equals(source)) {
                    // Si actualiza el Paciente desde "Mi Perfil"
                    response.sendRedirect("paciente-dashboard/dashboard.jsp?page=miperfil&update=exito");
                } else {
                    // Si actualiza el Admin desde la lista de pacientes
                    response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&update=exito");
                }
            } else {
                // Error
                if ("miperfil".equals(source)) {
                    response.sendRedirect("paciente-dashboard/dashboard.jsp?page=miperfil&update=error");
                } else {
                    response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&update=error");
                }
            }
        } catch (NumberFormatException | ParseException e) {
            e.printStackTrace();
            // Error genérico
            if ("miperfil".equals(source)) {
                response.sendRedirect("paciente-dashboard/dashboard.jsp?page=miperfil&update=error");
            } else {
                response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&update=error");
            }
        }
    }

    private void eliminarPaciente(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // --- SIN CAMBIOS AQUÍ ---
        // (Solo un Admin/Staff puede eliminar, así que la redirección al dashboard de admin es correcta)
        try {
            int pacienteId = Integer.parseInt(request.getParameter("id"));
            if (pacienteDAO.eliminarPaciente(pacienteId)) {
                response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&delete=exito");
            } else {
                response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&delete=error");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("dashboard/dashboard.jsp?page=pacientes&delete=error");
        }
    }
}