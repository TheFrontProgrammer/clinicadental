/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.model;
import com.dental.app.clinicadentalapp.UsuarioDAO;

public class Usuario {
    private int usuarioId;
    private String documentoIdentidad;
    private Rol rol;
    
    // Para almacenar el resultado de la validación del login
    private UsuarioDAO.EstadoValidacion estadoValidacion;
    
    // Getters y Setters
    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getDocumentoIdentidad() {
        return documentoIdentidad;
    }

    public void setDocumentoIdentidad(String documentoIdentidad) {
        this.documentoIdentidad = documentoIdentidad;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }
    
    public UsuarioDAO.EstadoValidacion getEstadoValidacion() {
        return estadoValidacion;
    }

    public void setEstadoValidacion(UsuarioDAO.EstadoValidacion estadoValidacion) {
        this.estadoValidacion = estadoValidacion;
    }
}