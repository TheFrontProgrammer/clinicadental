package com.dental.app.clinicadentalapp.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LogoutController", urlPatterns = {"/logout"})
public class LogoutController extends HttpServlet {

    /**
     * Handles the HTTP <code>GET</code> method.
     * Se activa cuando el usuario hace clic en un enlace (como el de "Cerrar Sesión").
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Obtenemos la sesión actual, sin crear una nueva si no existe
        HttpSession session = request.getSession(false);
        
        // 2. Verificamos si la sesión realmente existe
        if (session != null) {
            // 3. Invalidamos la sesión (la destruimos)
            session.invalidate();
        }
        
        // 4. Redirigimos al usuario de vuelta a la página de login
        response.sendRedirect("index.jsp");
    }
}