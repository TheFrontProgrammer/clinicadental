/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp;

import com.dental.app.clinicadentalapp.model.Odontologo;
import com.dental.app.clinicadentalapp.model.Usuario;
import com.dental.app.clinicadentalapp.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author Matheus
 */
public class OdontologoDAO {

    /**
     * Obtiene una lista de todos los odontólogos.
     */
    public List<Odontologo> listarOdontologos() {
        List<Odontologo> odontologos = new ArrayList<>();
        String sql = "SELECT o.*, u.documento_identidad FROM Odontologos o " +
                     "JOIN Usuarios u ON o.usuario_id = u.usuario_id ORDER BY o.apellido, o.nombre";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Odontologo o = new Odontologo();
                o.setOdontologoId(rs.getInt("odontologo_id"));
                o.setNombre(rs.getString("nombre"));
                o.setApellido(rs.getString("apellido"));
                o.setEmail(rs.getString("email"));
                o.setEspecialidad(rs.getString("especialidad"));
                
                Usuario u = new Usuario();
                u.setUsuarioId(rs.getInt("usuario_id"));
                u.setDocumentoIdentidad(rs.getString("documento_identidad"));
                o.setUsuario(u);
                
                odontologos.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return odontologos;
    }

    /**
     * Registra un nuevo odontólogo en la base de datos (transaccional).
     */
    public boolean registrarOdontologo(Odontologo odonto) {
        String defaultPassword = odonto.getUsuario().getDocumentoIdentidad();
        String hashedPassword = BCrypt.hashpw(defaultPassword, BCrypt.gensalt());
        int rolOdontologo = 2; // Según tu script de BD

        String sqlUsuario = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id) VALUES (?, ?, ?) RETURNING usuario_id";
        String sqlOdontologo = "INSERT INTO Odontologos (usuario_id, nombre, apellido, especialidad, telefono, email) VALUES (?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false); // Iniciar transacción
            
            int nuevoUsuarioId = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(sqlUsuario)) {
                pstmt.setString(1, odonto.getUsuario().getDocumentoIdentidad());
                pstmt.setString(2, hashedPassword);
                pstmt.setInt(3, rolOdontologo);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) nuevoUsuarioId = rs.getInt(1);
                else throw new SQLException("No se pudo crear el usuario.");
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sqlOdontologo)) {
                pstmt.setInt(1, nuevoUsuarioId);
                pstmt.setString(2, odonto.getNombre());
                pstmt.setString(3, odonto.getApellido());
                pstmt.setString(4, odonto.getEspecialidad());
                pstmt.setString(5, odonto.getTelefono());
                pstmt.setString(6, odonto.getEmail());
                pstmt.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    /**
     * Obtiene todos los datos de un odontólogo por su ID.
     */
    public Odontologo obtenerOdontologoPorId(int id) {
        Odontologo o = null;
        String sql = "SELECT * FROM Odontologos WHERE odontologo_id = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                o = new Odontologo();
                o.setOdontologoId(rs.getInt("odontologo_id"));
                o.setNombre(rs.getString("nombre"));
                o.setApellido(rs.getString("apellido"));
                o.setEspecialidad(rs.getString("especialidad"));
                o.setTelefono(rs.getString("telefono"));
                o.setEmail(rs.getString("email"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return o;
    }

    /**
     * Actualiza los datos de un odontólogo.
     */
    public boolean actualizarOdontologo(Odontologo odonto) {
        String sql = "UPDATE Odontologos SET nombre = ?, apellido = ?, especialidad = ?, telefono = ?, email = ? WHERE odontologo_id = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, odonto.getNombre());
            pstmt.setString(2, odonto.getApellido());
            pstmt.setString(3, odonto.getEspecialidad());
            pstmt.setString(4, odonto.getTelefono());
            pstmt.setString(5, odonto.getEmail());
            pstmt.setInt(6, odonto.getOdontologoId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Elimina un odontólogo de la base de datos (transaccional).
     */
    public boolean eliminarOdontologo(int id) {
        String sqlSelectUsuarioId = "SELECT usuario_id FROM Odontologos WHERE odontologo_id = ?";
        String sqlDeleteOdontologo = "DELETE FROM Odontologos WHERE odontologo_id = ?";
        String sqlDeleteUsuario = "DELETE FROM Usuarios WHERE usuario_id = ?";
        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false);
            
            int usuarioId = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(sqlSelectUsuarioId)) {
                pstmt.setInt(1, id);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) usuarioId = rs.getInt("usuario_id");
                else throw new SQLException("Odontólogo no encontrado.");
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteOdontologo)) {
                pstmt.setInt(1, id);
                pstmt.executeUpdate();
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteUsuario)) {
                pstmt.setInt(1, usuarioId);
                pstmt.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ==============================================================================================
// MÉTODOS AUXILIARES AÑADIDOS PARA PRUEBAS (GestionCitasSteps)
// ==============================================================================================

    /**
     * Busca y devuelve un objeto Usuario basado en su documento de identidad (DNI).
     * Nota: Este método se recomienda mover a una clase UsuarioDAO si existe.
     */
    public Usuario obtenerUsuarioPorDNI(String docIdentidad) {
        String sql = "SELECT usuario_id, documento_identidad FROM Usuarios WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, docIdentidad);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    return usuario;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Busca y devuelve un Odontologo basado en su ID de Usuario.
     * Necesario para obtener el objeto Odontologo (y su odontologo_id) despues de insertar el Usuario.
     */
    public Odontologo buscarOdontologoPorUsuarioId(int usuarioId) {
        Odontologo o = null;
        String sql = "SELECT o.* FROM Odontologos o WHERE o.usuario_id = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    o = new Odontologo();
                    o.setOdontologoId(rs.getInt("odontologo_id"));
                    o.setNombre(rs.getString("nombre"));
                    o.setApellido(rs.getString("apellido"));
                    o.setEspecialidad(rs.getString("especialidad"));
                    o.setTelefono(rs.getString("telefono"));
                    o.setEmail(rs.getString("email"));

                    Usuario u = new Usuario();
                    u.setUsuarioId(usuarioId);
                    // No tenemos el DNI aquí, pero el ID es suficiente para el test.
                    o.setUsuario(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return o;
    }


}