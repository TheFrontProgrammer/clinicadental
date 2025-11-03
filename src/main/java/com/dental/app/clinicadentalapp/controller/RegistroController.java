package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.dao.PacienteDAO;
import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegistroController", urlPatterns = {"/registro"})
public class RegistroController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Recopilar datos de credenciales ---
        String docIdentidad = request.getParameter("documento_identidad");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");

        // --- Recopilar datos personales del paciente ---
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String email = request.getParameter("email");
        String fechaNacimientoStr = request.getParameter("fecha_nacimiento");
        String genero = request.getParameter("genero");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        // --- Validaciones del lado del servidor ---
        if (docIdentidad == null || !docIdentidad.matches("\\d{8}")) {
            request.setAttribute("error", "El DNI debe tener 8 dígitos.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (password == null || !password.matches("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@_#$%^&+=!*?])(?=\\S+$).{8,}$")) {
            request.setAttribute("error", "La contraseña no cumple con los requisitos de seguridad.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Las contraseñas no coinciden.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        // --- Crear objetos del modelo ---
        Usuario usuario = new Usuario();
        usuario.setDocumentoIdentidad(docIdentidad);

        Paciente paciente = new Paciente();
        paciente.setUsuario(usuario);
        paciente.setNombre(nombre);
        paciente.setApellido(apellido);
        paciente.setEmail(email);
        paciente.setGenero(genero);
        paciente.setTelefono(telefono);
        paciente.setDireccion(direccion);

        // Convertir String a Date para la fecha de nacimiento
        if (fechaNacimientoStr != null && !fechaNacimientoStr.isEmpty()) {
            try {
                paciente.setFechaNacimiento(new SimpleDateFormat("yyyy-MM-dd").parse(fechaNacimientoStr));
            } catch (ParseException e) {
                // Manejar error de formato de fecha si es necesario
                e.printStackTrace(); 
            }
        }

        // --- Usar PacienteDAO para el registro transaccional ---
        PacienteDAO pacienteDAO = new PacienteDAO();
        
        // ===== CAMBIO CLAVE: Se pasa la variable 'password' al método del DAO =====
        if (pacienteDAO.registrarPaciente(paciente, password)) {
            // Si el registro es exitoso, redirigir al login con un mensaje
            response.sendRedirect("index.jsp?registro=exitoso");
        } else {
            // Si falla, volver a la página de registro con un error
            request.setAttribute("error", "Error al registrar el usuario. El DNI o Email ya podría existir.");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
        }
    }
}