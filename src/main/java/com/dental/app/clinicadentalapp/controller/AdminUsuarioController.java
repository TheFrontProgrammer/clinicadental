/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.UsuarioDAO;
import com.dental.app.clinicadentalapp.model.Usuario;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author Matheus
 */
@WebServlet(name = "AdminUsuarioController", urlPatterns = {"/adminUsuario"})
public class AdminUsuarioController extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);

        // 1. Verificación de seguridad: ¿Hay un usuario y es Admin?
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("../index.jsp"); // Si no hay sesión, fuera
            return;
        }

        Usuario usuarioSesion = (Usuario) session.getAttribute("usuario");
        if (!"Administrador".equals(usuarioSesion.getRol().getNombreRol())) {
            response.sendRedirect("dashboard/dashboard.jsp?page=inicio"); // No es admin, fuera
            return;
        }

        // 2. Obtener parámetros del formulario
        try {
            int usuarioId = Integer.parseInt(request.getParameter("usuarioId"));
            int rolId = Integer.parseInt(request.getParameter("rolId"));
            // El valor de 'bloqueado' viene como "true" o "false" (String)
            boolean bloqueado = Boolean.parseBoolean(request.getParameter("bloqueado"));
            
            // 3. Ejecutar la actualización
            boolean exito = usuarioDAO.actualizarUsuarioAdmin(usuarioId, rolId, bloqueado);
            
            if (exito) {
                response.sendRedirect("dashboard/dashboard.jsp?page=usuarios&update=exito");
            } else {
                response.sendRedirect("dashboard/dashboard.jsp?page=usuarios&update=error");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("dashboard/dashboard.jsp?page=usuarios&update=error");
        }
    }
}