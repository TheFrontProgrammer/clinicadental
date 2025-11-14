package com.dental.app.clinicadentalapp;

import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario;
import com.dental.app.clinicadentalapp.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

public class PacienteDAO {

    // Código de error de PostgreSQL para Violación de Unicidad
    private static final String PSQL_DUPLICATE_KEY_CODE = "23505";

    /**
     * Obtiene una lista de todos los pacientes de la base de datos.
     * @return Una lista de objetos Paciente.
     */
    public List<Paciente> listarPacientes() {
        List<Paciente> pacientes = new ArrayList<>();
        String sql = "SELECT p.*, u.documento_identidad, u.usuario_id FROM Pacientes p " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id ORDER BY p.nombre, p.apellido";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Paciente paciente = new Paciente();
                paciente.setPacienteId(rs.getInt("paciente_id"));
                paciente.setNombre(rs.getString("nombre"));
                paciente.setApellido(rs.getString("apellido"));
                paciente.setEmail(rs.getString("email"));
                paciente.setAlergias(rs.getString("alergias"));
                // Mapeo completo de otros campos
                paciente.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
                paciente.setGenero(rs.getString("genero"));
                paciente.setTelefono(rs.getString("telefono"));
                paciente.setDireccion(rs.getString("direccion"));

                Usuario usuario = new Usuario();
                usuario.setUsuarioId(rs.getInt("usuario_id"));
                usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));

                paciente.setUsuario(usuario);
                pacientes.add(paciente);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return pacientes;
    }

    /**
     * Registra un nuevo paciente con todos sus detalles (CP-006 y CP-007).
     */
    public boolean registrarPaciente(Paciente paciente, String password) {
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
        int rolPaciente = 4; // Rol 4 para Paciente
        String sqlUsuario = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id) VALUES (?, ?, ?) RETURNING usuario_id";
        String sqlPaciente = "INSERT INTO Pacientes (usuario_id, nombre, apellido, fecha_nacimiento, genero, telefono, email, direccion, alergias) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false);
            int nuevoUsuarioId = 0;

            // 1. Insertar en Usuarios
            try (PreparedStatement pstmtUsuario = conn.prepareStatement(sqlUsuario)) {
                pstmtUsuario.setString(1, paciente.getUsuario().getDocumentoIdentidad());
                pstmtUsuario.setString(2, hashedPassword);
                pstmtUsuario.setInt(3, rolPaciente);

                ResultSet rs = pstmtUsuario.executeQuery();
                if (rs.next()) {
                    nuevoUsuarioId = rs.getInt(1);
                } else {
                    throw new SQLException("No se pudo obtener el ID del nuevo usuario.");
                }
            }
            // 2. Insertar en Pacientes
            try (PreparedStatement pstmtPaciente = conn.prepareStatement(sqlPaciente)) {
                pstmtPaciente.setInt(1, nuevoUsuarioId);
                pstmtPaciente.setString(2, paciente.getNombre());
                pstmtPaciente.setString(3, paciente.getApellido());
                if (paciente.getFechaNacimiento() != null) {
                    pstmtPaciente.setDate(4, new java.sql.Date(paciente.getFechaNacimiento().getTime()));
                } else {
                    pstmtPaciente.setNull(4, java.sql.Types.DATE);
                }
                pstmtPaciente.setString(5, paciente.getGenero());
                pstmtPaciente.setString(6, paciente.getTelefono());
                pstmtPaciente.setString(7, paciente.getEmail());
                pstmtPaciente.setString(8, paciente.getDireccion());
                pstmtPaciente.setString(9, paciente.getAlergias());

                pstmtPaciente.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            // Manejo de errores de unicidad (CP-007)
            if (e.getSQLState().equals(PSQL_DUPLICATE_KEY_CODE)) {
                System.err.println("Error: Violación de unicidad de DNI. El registro falló.");
                return false;
            }
            System.err.println("Error SQL General en registro de paciente: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
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

    /**
     * Busca y devuelve un único paciente basado en su ID.
     */
    public Paciente obtenerPacientePorId(int pacienteId) {
        Paciente paciente = null;
        String sql = "SELECT p.*, u.documento_identidad, u.usuario_id FROM Pacientes p " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id WHERE p.paciente_id = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, pacienteId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    paciente = new Paciente();
                    paciente.setPacienteId(rs.getInt("paciente_id"));
                    paciente.setNombre(rs.getString("nombre"));
                    paciente.setApellido(rs.getString("apellido"));
                    paciente.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
                    paciente.setGenero(rs.getString("genero"));
                    paciente.setTelefono(rs.getString("telefono"));
                    paciente.setEmail(rs.getString("email"));
                    paciente.setDireccion(rs.getString("direccion"));
                    paciente.setAlergias(rs.getString("alergias"));

                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    paciente.setUsuario(usuario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return paciente;
    }

    /**
     * Busca y devuelve un paciente basado en su documento de identidad (DNI). (CP-010)
     */
    public Paciente buscarPacientePorDNI(String docIdentidad) {
        String sql = "SELECT p.*, u.documento_identidad, u.usuario_id FROM Pacientes p "
                + "JOIN Usuarios u ON p.usuario_id = u.usuario_id "
                + "WHERE u.documento_identidad = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, docIdentidad);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Mapeo completo (similar a obtenerPacientePorId)
                    Paciente paciente = new Paciente();
                    paciente.setPacienteId(rs.getInt("paciente_id"));
                    paciente.setNombre(rs.getString("nombre"));
                    paciente.setApellido(rs.getString("apellido"));
                    paciente.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
                    paciente.setGenero(rs.getString("genero"));
                    paciente.setTelefono(rs.getString("telefono"));
                    paciente.setEmail(rs.getString("email"));
                    paciente.setDireccion(rs.getString("direccion"));
                    paciente.setAlergias(rs.getString("alergias"));

                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    paciente.setUsuario(usuario);

                    return paciente;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Busca pacientes por coincidencia parcial en nombre, apellido o DNI. (CP-011, CP-012)
     */
    /**
     * Busca pacientes por coincidencia parcial en nombre, apellido, DNI, o nombre completo. (CP-011, CP-012)
     */
    public List<Paciente> buscarPacientesPorCriterio(String criterio) {
        List<Paciente> pacientes = new ArrayList<>();

        // --- MODIFICACIÓN CLAVE AQUÍ ---
        // Se añade una cuarta condición para buscar por la concatenación de nombre y apellido
        String sql = "SELECT p.*, u.documento_identidad, u.usuario_id FROM Pacientes p "
                + "JOIN Usuarios u ON p.usuario_id = u.usuario_id "
                + "WHERE LOWER(p.nombre) LIKE ? "
                + "OR LOWER(p.apellido) LIKE ? "
                + "OR LOWER(u.documento_identidad) LIKE ? "
                // NUEVA CONDICIÓN: Nombre completo (PostgreSQL usa || para concatenar)
                + "OR LOWER(p.nombre || ' ' || p.apellido) LIKE ?"
                + " ORDER BY p.apellido, p.nombre";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            String likeCriterio = "%" + criterio.toLowerCase() + "%";
            pstmt.setString(1, likeCriterio); // Búsqueda por Nombre (Marta)
            pstmt.setString(2, likeCriterio); // Búsqueda por Apellido (García)
            pstmt.setString(3, likeCriterio); // Búsqueda por DNI (20000...)
            pstmt.setString(4, likeCriterio); // NUEVO: Búsqueda por Nombre Completo (Marta García)

            try (ResultSet rs = pstmt.executeQuery()) {
                // ... (El resto del código de mapeo es correcto)
                while (rs.next()) {
                    // Mapeo completo
                    Paciente paciente = new Paciente();
                    paciente.setPacienteId(rs.getInt("paciente_id"));
                    paciente.setNombre(rs.getString("nombre"));
                    paciente.setApellido(rs.getString("apellido"));
                    paciente.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
                    paciente.setGenero(rs.getString("genero"));
                    paciente.setTelefono(rs.getString("telefono"));
                    paciente.setEmail(rs.getString("email"));
                    paciente.setDireccion(rs.getString("direccion"));
                    paciente.setAlergias(rs.getString("alergias"));

                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    paciente.setUsuario(usuario);

                    pacientes.add(paciente);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return pacientes;
    }
    /**
     * Actualiza los datos de un paciente en la base de datos (CP-008).
     * Nota: No se actualiza el DNI ni la contraseña.
     */
    public boolean actualizarPaciente(Paciente paciente) {
        String sql = "UPDATE Pacientes SET nombre = ?, apellido = ?, fecha_nacimiento = ?, " +
                "genero = ?, telefono = ?, email = ?, direccion = ?, alergias = ? " +
                "WHERE paciente_id = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, paciente.getNombre());
            pstmt.setString(2, paciente.getApellido());
            // java.util.Date a java.sql.Date
            if (paciente.getFechaNacimiento() != null) {
                pstmt.setDate(3, new java.sql.Date(paciente.getFechaNacimiento().getTime()));
            } else {
                pstmt.setNull(3, java.sql.Types.DATE);
            }
            pstmt.setString(4, paciente.getGenero());
            pstmt.setString(5, paciente.getTelefono());
            pstmt.setString(6, paciente.getEmail());
            pstmt.setString(7, paciente.getDireccion());
            pstmt.setString(8, paciente.getAlergias());
            pstmt.setInt(9, paciente.getPacienteId());

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Elimina un paciente de la base de datos con transaccionalidad (CP-009).
     */
    public boolean eliminarPaciente(int pacienteId) {
        // --- SQLs CORREGIDOS para la transacción ---
        String sqlSelectUsuarioId = "SELECT usuario_id FROM Pacientes WHERE paciente_id = ?";

        // 1. Eliminar de Detalle_Tratamiento (Hijo de Historial_Tratamientos)
        String sqlDeleteDetalleTratamientos = "DELETE FROM Detalle_Tratamiento WHERE historial_id IN (SELECT historial_id FROM Historial_Tratamientos ht JOIN Citas c ON ht.cita_id = c.cita_id WHERE c.paciente_id = ?)";

        // 2. Eliminar de Historial_Tratamientos (Hijo de Citas)
        String sqlDeleteHistorialTratamientos = "DELETE FROM Historial_Tratamientos WHERE cita_id IN (SELECT cita_id FROM Citas WHERE paciente_id = ?)";

        // 3. Eliminar de Citas
        String sqlDeleteCitas = "DELETE FROM Citas WHERE paciente_id = ?";

        // 4. Eliminar de la tabla Pacientes
        String sqlDeletePaciente = "DELETE FROM Pacientes WHERE paciente_id = ?";

        // 5. Eliminar de la tabla Usuarios
        String sqlDeleteUsuario = "DELETE FROM Usuarios WHERE usuario_id = ?";

        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false);

            int usuarioId = -1;

            // A. Obtener el usuario_id asociado al paciente
            try (PreparedStatement pstmt = conn.prepareStatement(sqlSelectUsuarioId)) {
                pstmt.setInt(1, pacienteId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    usuarioId = rs.getInt("usuario_id");
                } else {
                    // Si no existe, la operación se considera exitosa si no hay nada que borrar
                    conn.commit();
                    return true;
                }
            }

            // B. Eliminar de Tablas Hijas de Citas (Orden de borrado por FK)
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteDetalleTratamientos)) {
                pstmt.setInt(1, pacienteId);
                pstmt.executeUpdate();
            }

            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteHistorialTratamientos)) {
                pstmt.setInt(1, pacienteId);
                pstmt.executeUpdate();
            }

            // C. Eliminar de Citas
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteCitas)) {
                pstmt.setInt(1, pacienteId);
                pstmt.executeUpdate();
            }

            // D. Eliminar de la tabla Pacientes
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDeletePaciente)) {
                pstmt.setInt(1, pacienteId);
                pstmt.executeUpdate();
            }

            // E. Eliminar de la tabla Usuarios
            if (usuarioId != -1) {
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDeleteUsuario)) {
                    pstmt.setInt(1, usuarioId);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("Error en la eliminación transaccional del paciente: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
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

    // ==============================================================================================
// MÉTODOS AUXILIARES AÑADIDOS PARA PRUEBAS (GestionCitasSteps)
// ==============================================================================================

    /**
     * Busca y devuelve un objeto Usuario basado en su documento de identidad (DNI).
     * Necesario para obtener el ID de usuario cuando hay colision en el setup de pruebas.
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
     * Busca y devuelve un paciente basado en su ID de Usuario.
     * Necesario para obtener el objeto Paciente (y su paciente_id) despues de insertar el Usuario.
     */
    public Paciente obtenerPacientePorUsuarioId(int usuarioId) {
        Paciente paciente = null;
        String sql = "SELECT p.*, u.documento_identidad FROM Pacientes p " +
                "JOIN Usuarios u ON p.usuario_id = u.usuario_id WHERE u.usuario_id = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    paciente = new Paciente();
                    paciente.setPacienteId(rs.getInt("paciente_id"));
                    paciente.setNombre(rs.getString("nombre"));
                    paciente.setApellido(rs.getString("apellido"));
                    // ... (Mapear el resto de campos si es necesario, por brevedad se omite)
                    paciente.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
                    paciente.setGenero(rs.getString("genero"));
                    paciente.setTelefono(rs.getString("telefono"));
                    paciente.setEmail(rs.getString("email"));
                    paciente.setDireccion(rs.getString("direccion"));
                    paciente.setAlergias(rs.getString("alergias"));

                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    paciente.setUsuario(usuario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return paciente;
    }

    /**
     * Busca y devuelve un paciente basado en su nombre y apellido exactos.
     * Necesario para el WHEN de consulta de citas (CP-017).
     */
    public Paciente buscarPacientePorNombreApellido(String nombre, String apellido) {
        String sql = "SELECT p.*, u.documento_identidad, u.usuario_id FROM Pacientes p "
                + "JOIN Usuarios u ON p.usuario_id = u.usuario_id "
                + "WHERE p.nombre = ? AND p.apellido = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombre);
            pstmt.setString(2, apellido);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Paciente paciente = new Paciente();
                    paciente.setPacienteId(rs.getInt("paciente_id"));
                    paciente.setNombre(rs.getString("nombre"));
                    paciente.setApellido(rs.getString("apellido"));
                    // ... (Mapeo completo)

                    Usuario usuario = new Usuario();
                    usuario.setUsuarioId(rs.getInt("usuario_id"));
                    usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                    paciente.setUsuario(usuario);
                    return paciente;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


}
