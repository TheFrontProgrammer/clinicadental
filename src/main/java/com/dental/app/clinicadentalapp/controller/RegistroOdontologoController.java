/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.OdontologoDAO;
import com.dental.app.clinicadentalapp.model.Odontologo;
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
@WebServlet(name = "RegistroOdontologoController", urlPatterns = {"/registroOdontologo"})
public class RegistroOdontologoController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String dni = request.getParameter("dni");
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String especialidad = request.getParameter("especialidad");
        String telefono = request.getParameter("telefono");
        String email = request.getParameter("email");
        
        Usuario usuario = new Usuario();
        usuario.setDocumentoIdentidad(dni);
        
        Odontologo odonto = new Odontologo();
        odonto.setUsuario(usuario);
        odonto.setNombre(nombre);
        odonto.setApellido(apellido);
        odonto.setEspecialidad(especialidad);
        odonto.setTelefono(telefono);
        odonto.setEmail(email);
        
        OdontologoDAO dao = new OdontologoDAO();
        boolean exito = dao.registrarOdontologo(odonto);
        
        if (exito) {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&registro=exito");
        } else {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&registro=error");
        }
    }
}
