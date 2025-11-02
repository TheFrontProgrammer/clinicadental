/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dental.app.clinicadentalapp.dao;

import com.dental.app.clinicadentalapp.model.Cita;
import com.dental.app.clinicadentalapp.model.Odontologo;
import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario; // Importación añadida
import com.dental.app.clinicadentalapp.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Matheus
 */
public class CitaDAO {

    /**
     * CAMBIO 1: Enum para manejar los posibles resultados del registro.
     * Esto nos permite diferenciar entre un error de BD y un horario ocupado.
     */
    public enum EstadoRegistroCita {
        EXITO,
        ERROR_HORARIO_OCUPADO,
        ERROR_BD
    }

    /**
     * Lista todas las citas uniendo los datos de pacientes y odontólogos.
     */
    public List<Cita> listarCitas() {
        List<Cita> citas = new ArrayList<>();
        // CONSULTA SQL ACTUALIZADA
        String sql = "SELECT c.cita_id, c.fecha_cita, c.hora_cita, c.motivo, c.estado, " +
                     "p.paciente_id, p.nombre AS paciente_nombre, p.apellido AS paciente_apellido, " +
                     "o.odontologo_id, o.nombre AS odonto_nombre, o.apellido AS odonto_apellido, " +
                     "u.documento_identidad " + // Se añadió esta línea
                     "FROM Citas c " +
                     "JOIN Pacientes p ON c.paciente_id = p.paciente_id " +
                     "JOIN Odontologos o ON c.odontologo_id = o.odontologo_id " +
                     "JOIN Usuarios u ON p.usuario_id = u.usuario_id " + // Se añadió esta línea
                     "ORDER BY c.fecha_cita, c.hora_cita";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Cita cita = new Cita();
                cita.setCitaId(rs.getInt("cita_id"));
                cita.setFechaCita(rs.getDate("fecha_cita").toLocalDate());
                cita.setHoraCita(rs.getTime("hora_cita").toLocalTime());
                cita.setMotivo(rs.getString("motivo"));
                cita.setEstado(rs.getString("estado"));

                Paciente paciente = new Paciente();
                paciente.setPacienteId(rs.getInt("paciente_id"));
                paciente.setNombre(rs.getString("paciente_nombre"));
                paciente.setApellido(rs.getString("paciente_apellido"));

                // Crear y establecer el objeto Usuario para el Paciente
                Usuario usuario = new Usuario();
                usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                paciente.setUsuario(usuario); // Esta es la corrección crucial

                cita.setPaciente(paciente);

                Odontologo odonto = new Odontologo();
                odonto.setOdontologoId(rs.getInt("odontologo_id"));
                odonto.setNombre(rs.getString("odonto_nombre"));
                odonto.setApellido(rs.getString("odonto_apellido"));
                cita.setOdontologo(odonto);

                citas.add(cita);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    /**
     * CAMBIO 2: Nuevo método para verificar la disponibilidad (CP-014).
     * Comprueba si ya existe una cita para el odontólogo en esa fecha y hora.
     *
     * @return true si el horario está OCUPADO, false si está LIBRE.
     */
    public boolean isHorarioOcupado(int odontologoId, LocalDate fecha, LocalTime hora) {
        String sql = "SELECT COUNT(*) FROM Citas WHERE odontologo_id = ? AND fecha_cita = ? AND hora_cita = ?";
        try (Connection conn = ConexionDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, odontologoId);
            pstmt.setDate(2, Date.valueOf(fecha));
            pstmt.setTime(3, Time.valueOf(hora));

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0; // Si count > 0, está ocupado (true)
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // En caso de error de BD, es más seguro asumir que está ocupado
            return true;
        }
        return false; // Si count es 0, no está ocupado
    }

    /**
     * CAMBIO 3: Modificado para usar el enum y la verificación de horario.
     * Registra una nueva cita en la base de datos.
     */
    public EstadoRegistroCita registrarCita(Cita cita) {

        // 1. (CP-014) Verificar si el horario está ocupado ANTES de insertar
        if (isHorarioOcupado(cita.getOdontologo().getOdontologoId(), cita.getFechaCita(), cita.getHoraCita())) {
            return EstadoRegistroCita.ERROR_HORARIO_OCUPADO;
        }

        // 2. Si está libre, proceder con la inserción
        String sql = "INSERT INTO Citas (paciente_id, odontologo_id, fecha_cita, hora_cita, motivo, estado) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConexionDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, cita.getPaciente().getPacienteId());
            pstmt.setInt(2, cita.getOdontologo().getOdontologoId());
            pstmt.setDate(3, Date.valueOf(cita.getFechaCita()));
            pstmt.setTime(4, Time.valueOf(cita.getHoraCita()));
            pstmt.setString(5, cita.getMotivo());
            pstmt.setString(6, cita.getEstado());

            boolean exito = pstmt.executeUpdate() > 0;
            return exito ? EstadoRegistroCita.EXITO : EstadoRegistroCita.ERROR_BD;

        } catch (SQLException e) {
            e.printStackTrace();
            return EstadoRegistroCita.ERROR_BD;
        }
    }

    /**
     * Actualiza una cita existente.
     */
    public boolean actualizarCita(Cita cita) {
        String sql = "UPDATE Citas SET paciente_id = ?, odontologo_id = ?, fecha_cita = ?, hora_cita = ?, motivo = ?, estado = ? WHERE cita_id = ?";
        try (Connection conn = ConexionDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, cita.getPaciente().getPacienteId());
            pstmt.setInt(2, cita.getOdontologo().getOdontologoId());
            pstmt.setDate(3, Date.valueOf(cita.getFechaCita()));
            pstmt.setTime(4, Time.valueOf(cita.getHoraCita()));
            pstmt.setString(5, cita.getMotivo());
            pstmt.setString(6, cita.getEstado());
            pstmt.setInt(7, cita.getCitaId());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Elimina una cita de la base de datos por su ID.
     */
    public boolean eliminarCita(int id) {
        String sql = "DELETE FROM Citas WHERE cita_id = ?";
        try (Connection conn = ConexionDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}