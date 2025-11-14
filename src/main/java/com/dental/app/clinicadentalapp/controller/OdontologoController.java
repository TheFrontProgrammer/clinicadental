/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.controller;

import com.dental.app.clinicadentalapp.OdontologoDAO;
import com.dental.app.clinicadentalapp.model.Odontologo;
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
@WebServlet(name = "OdontologoController", urlPatterns = {"/odontologo"})
public class OdontologoController extends HttpServlet {

    private OdontologoDAO dao = new OdontologoDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String especialidad = request.getParameter("especialidad");
        String telefono = request.getParameter("telefono");
        String email = request.getParameter("email");
        
        Odontologo odonto = new Odontologo();
        odonto.setOdontologoId(id);
        odonto.setNombre(nombre);
        odonto.setApellido(apellido);
        odonto.setEspecialidad(especialidad);
        odonto.setTelefono(telefono);
        odonto.setEmail(email);
        
        if (dao.actualizarOdontologo(odonto)) {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&update=exito");
        } else {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&update=error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        if (dao.eliminarOdontologo(id)) {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&delete=exito");
        } else {
            response.sendRedirect("dashboard/dashboard.jsp?page=odontologos&delete=error");
        }
    }
}
