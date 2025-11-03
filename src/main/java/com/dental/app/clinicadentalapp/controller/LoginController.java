package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.dao.UsuarioDAO.EstadoValidacion;
import static com.dental.app.clinicadentalapp.dao.UsuarioDAO.EstadoValidacion.*;
import com.dental.app.clinicadentalapp.dao.UsuarioDAO;
import com.dental.app.clinicadentalapp.model.Usuario;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String docIdentidad = request.getParameter("documento_identidad");
        String pass = request.getParameter("password");

        System.out.println("\n==============================================");
        System.out.println("--- INICIO INTENTO DE LOGIN ---");
        System.out.println("LoginController: Recibido documento -> " + docIdentidad);
        System.out.println("LoginController: Recibida password -> " + pass);

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = new Usuario();
        usuarioDAO.validarUsuario(docIdentidad, pass, usuario);

        if (usuario.getEstadoValidacion() == UsuarioDAO.EstadoValidacion.LOGIN_EXITOSO) {
            System.out.println("LoginController: El DAO devolvió un usuario. ¡LOGIN EXITOSO!");
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            
            // =================================================================
            // ==           CAMBIO: Añadimos ?login=success al redirigir      ==
            // =================================================================
            response.sendRedirect("dashboard/dashboard.jsp?login=success");
            
        } else {
            String mensajeError = "";
            switch (usuario.getEstadoValidacion()) {
                case USUARIO_NO_ENCONTRADO:
                    mensajeError = "Usuario no encontrado.";
                    break;
                case PASSWORD_INCORRECTO:
                    mensajeError = "Contraseña incorrecta.";
                    break;
                case CUENTA_BLOQUEADA:
                    mensajeError = "Usuario bloqueado, intente más tarde.";
                    break;
                default:
                    mensajeError = "Documento o contraseña incorrectos.";
                    break;
            }
            System.out.println("LoginController: ¡LOGIN FALLIDO! - " + mensajeError);
            request.setAttribute("mensajeError", mensajeError);
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
        System.out.println("--- FIN INTENTO DE LOGIN ---");
        System.out.println("==============================================\n");
    }
}