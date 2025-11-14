/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.UsuarioDAO;
import com.dental.app.clinicadentalapp.UsuarioDAO.EstadoCambioPassword;
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
@WebServlet(name = "UsuarioController", urlPatterns = {"/usuario"})
public class UsuarioController extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);

        // 1. Verificación de seguridad: ¿Hay un usuario en la sesión?
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("../index.jsp"); // Si no hay sesión, fuera
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String docIdentidad = usuario.getDocumentoIdentidad();
        
        // =================================================================
        // ==           CAMBIO: Determinar página de redirección        ==
        // =================================================================
        String rol = usuario.getRol().getNombreRol();
        String redirectPage;
        if ("Paciente".equals(rol)) {
            redirectPage = "paciente-dashboard/dashboard.jsp";
        } else {
            redirectPage = "dashboard/dashboard.jsp";
        }
        // =================================================================
        
        String passActual = request.getParameter("password_actual");
        String passNueva = request.getParameter("password_nueva");
        String passConfirmar = request.getParameter("confirmar_password");
        
        String redirectParams = "";

        // 2. Validación: ¿Las contraseñas nuevas coinciden?
        if (!passNueva.equals(passConfirmar)) {
            redirectParams = "update=error_no_coinciden";
            // CAMBIO: Usar la variable redirectPage
            response.sendRedirect(redirectPage + "?page=configuracion&" + redirectParams);
            return;
        }

        // 3. Llamada al DAO para intentar el cambio
        EstadoCambioPassword resultado = usuarioDAO.actualizarContrasena(docIdentidad, passActual, passNueva);

        // 4. Redirigir según el resultado
        switch (resultado) {
            case EXITO:
                // C(P-019) Éxito
                redirectParams = "update=exito";
                // Opcional: Invalidar la sesión para forzar un nuevo login
                // session.invalidate();
                // response.sendRedirect("index.jsp?registro=pass_exitoso");
                // return;
                break;
            case PASSWORD_ACTUAL_INCORRECTO:
                redirectParams = "update=error_actual";
                break;
            case PASSWORD_NUEVA_INVALIDA:
                // (CP-020) Fallo por formato
                redirectParams = "update=error_formato";
                break;
            case ERROR_BD:
            default:
                redirectParams = "update=error";
                break;
        }
        
        // CAMBIO: Usar la variable redirectPage
        response.sendRedirect(redirectPage + "?page=configuracion&" + redirectParams);
    }
}