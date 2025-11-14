package com.dental.app.clinicadentalapp;

import com.dental.app.clinicadentalapp.model.Cita;
import com.dental.app.clinicadentalapp.model.Odontologo;
import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario;
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
 * Data Access Object para la entidad Cita.
 * Maneja todas las interacciones con la tabla 'Citas' y sus dependencias.
 */
public class CitaDAO {

    /**
     * Enum para manejar los posibles resultados del registro de una cita.
     */
    public enum EstadoRegistroCita {
        EXITO,
        ERROR_HORARIO_OCUPADO,
        ERROR_BD
    }

    /**
     * Helper para construir un objeto Cita a partir de un ResultSet.
     */
    private Cita buildCitaFromResultSet(ResultSet rs) throws SQLException {
        Cita cita = new Cita();
        cita.setCitaId(rs.getInt("cita_id"));
        // Se asume que las columnas son 'fecha_cita' y 'hora_cita'
        cita.setFechaCita(rs.getDate("fecha_cita").toLocalDate());
        cita.setHoraCita(rs.getTime("hora_cita").toLocalTime());
        cita.setMotivo(rs.getString("motivo"));
        cita.setEstado(rs.getString("estado"));

        // Cargar datos de Paciente
        Paciente paciente = new Paciente();
        paciente.setPacienteId(rs.getInt("paciente_id"));
        paciente.setNombre(rs.getString("paciente_nombre"));
        paciente.setApellido(rs.getString("paciente_apellido"));
        // Cargar DNI del paciente (asumiendo que se une con Usuarios 'u')
        Usuario usuario = new Usuario();
        usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
        paciente.setUsuario(usuario);
        cita.setPaciente(paciente);

        // Cargar datos de Odontologo
        Odontologo odonto = new Odontologo();
        odonto.setOdontologoId(rs.getInt("odontologo_id"));
        odonto.setNombre(rs.getString("odonto_nombre"));
        odonto.setApellido(rs.getString("odonto_apellido"));
        cita.setOdontologo(odonto);

        return cita;
    }

    /**
     * Lista todas las citas uniendo los datos de pacientes y odontólogos.
     */
    public List<Cita> listarCitas() {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT c.cita_id, c.fecha_cita, c.hora_cita, c.motivo, c.estado, " +
                "p.paciente_id, p.nombre AS paciente_nombre, p.apellido AS paciente_apellido, " +
                "o.odontologo_id, o.nombre AS odonto_nombre, o.apellido AS odonto_apellido, " +
                "u.documento_identidad " +
                "FROM Citas c " +
                "JOIN Pacientes p ON c.paciente_id = p.paciente_id " +
                "JOIN Odontologos o ON c.odontologo_id = o.odontologo_id " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id " +
                "ORDER BY c.fecha_cita, c.hora_cita";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                citas.add(buildCitaFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }

    /**
     * Obtiene una cita específica por su ID.
     * @param citaId El ID de la cita a buscar.
     * @return El objeto Cita si se encuentra, o null.
     */
    public Cita obtenerCitaPorId(int citaId) {
        Cita cita = null;
        String sql = "SELECT c.cita_id, c.fecha_cita, c.hora_cita, c.motivo, c.estado, " +
                "p.paciente_id, p.nombre AS paciente_nombre, p.apellido AS paciente_apellido, " +
                "o.odontologo_id, o.nombre AS odonto_nombre, o.apellido AS odonto_apellido, " +
                "u.documento_identidad " +
                "FROM Citas c " +
                "JOIN Pacientes p ON c.paciente_id = p.paciente_id " +
                "JOIN Odontologos o ON c.odontologo_id = o.odontologo_id " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id " +
                "WHERE c.cita_id = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, citaId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    cita = buildCitaFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cita;
    }

    // =================================================================
    // NUEVO: Obtener Cita por Odontologo, Fecha y Hora (Necesario para CP-013/014)
    // =================================================================
    /**
     * Obtiene una cita específica por los campos de unicidad de disponibilidad.
     * @return El objeto Cita si se encuentra, o null.
     */
    public Cita obtenerCitaPorOdontologoFechaHora(int odontoId, LocalDate fecha, LocalTime hora) {
        Cita cita = null;
        String sql = "SELECT c.cita_id, c.fecha_cita, c.hora_cita, c.motivo, c.estado, " +
                "p.paciente_id, p.nombre AS paciente_nombre, p.apellido AS paciente_apellido, " +
                "o.odontologo_id, o.nombre AS odonto_nombre, o.apellido AS odonto_apellido, " +
                "u.documento_identidad " +
                "FROM Citas c " +
                "JOIN Pacientes p ON c.paciente_id = p.paciente_id " +
                "JOIN Odontologos o ON c.odontologo_id = o.odontologo_id " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id " +
                "WHERE c.odontologo_id = ? AND c.fecha_cita = ? AND c.hora_cita = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, odontoId);
            pstmt.setDate(2, Date.valueOf(fecha));
            pstmt.setTime(3, Time.valueOf(hora));

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    cita = buildCitaFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cita;
    }

    // =================================================================
    // NUEVO: Buscar Citas por Paciente ID (Necesario para CP-017)
    // =================================================================
    /**
     * Busca todas las citas asociadas a un paciente específico por su ID.
     */
    public List<Cita> buscarCitasPorPacienteId(int pacienteId) {
        List<Cita> citas = new ArrayList<>();
        String sql = "SELECT c.cita_id, c.fecha_cita, c.hora_cita, c.motivo, c.estado, " +
                "p.paciente_id, p.nombre AS paciente_nombre, p.apellido AS paciente_apellido, " +
                "o.odontologo_id, o.nombre AS odonto_nombre, o.apellido AS odonto_apellido, " +
                "u.documento_identidad " +
                "FROM Citas c " +
                "JOIN Pacientes p ON c.paciente_id = p.paciente_id " +
                "JOIN Odontologos o ON c.odontologo_id = o.odontologo_id " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id " +
                "WHERE c.paciente_id = ? " +
                "ORDER BY c.fecha_cita, c.hora_cita";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, pacienteId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    citas.add(buildCitaFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return citas;
    }


    /**
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
     * Registra una nueva cita en la base de datos, verificando la disponibilidad.
     */
    public EstadoRegistroCita registrarCita(Cita cita) {

        // 1. (CP-014) Verificar si el horario está ocupado ANTES de insertar
        if (isHorarioOcupado(cita.getOdontologo().getOdontologoId(), cita.getFechaCita(), cita.getHoraCita())) {
            return EstadoRegistroCita.ERROR_HORARIO_OCUPADO;
        }

        // 2. Si está libre, proceder con la inserción
        // Se añade RETURNING cita_id para poder obtener el ID de la cita recien creada (util para debugging)
        String sql = "INSERT INTO Citas (paciente_id, odontologo_id, fecha_cita, hora_cita, motivo, estado) VALUES (?, ?, ?, ?, ?, ?) RETURNING cita_id";
        try (Connection conn = ConexionDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, cita.getPaciente().getPacienteId());
            pstmt.setInt(2, cita.getOdontologo().getOdontologoId());
            pstmt.setDate(3, Date.valueOf(cita.getFechaCita()));
            pstmt.setTime(4, Time.valueOf(cita.getHoraCita()));
            pstmt.setString(5, cita.getMotivo());
            pstmt.setString(6, cita.getEstado());

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Opcional: Si necesitas el ID de vuelta en el objeto Cita
                    cita.setCitaId(rs.getInt(1));
                    return EstadoRegistroCita.EXITO;
                }
            }
            return EstadoRegistroCita.ERROR_BD;

        } catch (SQLException e) {
            e.printStackTrace();
            return EstadoRegistroCita.ERROR_BD;
        }
    }

    /**
     * Actualiza una cita existente (usado para Reprogramar y Cancelar).
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
        // Asumimos que la tabla hija se llama 'Tratamientos'
        String sqlDeleteHijos = "DELETE FROM Tratamientos WHERE cita_id = ?";
        String sqlDeleteCita = "DELETE FROM Citas WHERE cita_id = ?";

        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false); // Iniciar transacción

            // 1. Eliminar registros "hijos"
            try (PreparedStatement pstmtHijos = conn.prepareStatement(sqlDeleteHijos)) {
                pstmtHijos.setInt(1, id);
                pstmtHijos.executeUpdate();
            }

            // 2. Eliminar registro "padre" (la Cita)
            int filasAfectadas;
            try (PreparedStatement pstmtCita = conn.prepareStatement(sqlDeleteCita)) {
                pstmtCita.setInt(1, id);
                filasAfectadas = pstmtCita.executeUpdate();
            }

            conn.commit(); // Confirmar transacción
            return filasAfectadas > 0; // Devuelve true solo si la Cita fue borrada

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Revertir en caso de error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}