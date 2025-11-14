package com.dental.app.clinicadentalapp;

import com.dental.app.clinicadentalapp.model.Rol;
import com.dental.app.clinicadentalapp.model.Usuario;
import com.dental.app.clinicadentalapp.util.ConexionDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp; // Importación necesaria para la fecha
import java.time.Instant; // Importación para manejar tiempo actual
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

public class UsuarioDAO {

    private static final int MAX_INTENTOS_FALLIDOS = 3;
    // (CP-020) Regex de seguridad para la contraseña
    private static final String PASSWORD_REGEX = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@_#$%^&+=!*?])(?=\\S+$).{8,}$";

    public enum EstadoValidacion {
        LOGIN_EXITOSO,
        USUARIO_NO_ENCONTRADO,
        PASSWORD_INCORRECTO,
        CUENTA_BLOQUEADA
    }

    public enum EstadoCambioPassword {
        EXITO,
        PASSWORD_ACTUAL_INCORRECTO,
        PASSWORD_NUEVA_INVALIDA,
        ERROR_BD
    }

    public Usuario validarUsuario(String docIdentidad, String passwordPlano, Usuario usuario) {
        System.out.println("UsuarioDAO: Iniciando validación para documento -> " + docIdentidad);
        String sql = "SELECT u.usuario_id, u.documento_identidad, u.contrasena_hash, u.intentos_fallidos, u.bloqueado, r.rol_id, r.nombre_rol " +
                "FROM Usuarios u " +
                "INNER JOIN Roles r ON u.rol_id = r.rol_id " +
                "WHERE u.documento_identidad = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            System.out.println("UsuarioDAO: [Paso 1 - Conexión] Conexión a la BD exitosa.");
            pstmt.setString(1, docIdentidad);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("UsuarioDAO: [Paso 2 - Búsqueda] Se ENCONTRÓ un usuario en la BD.");

                    // Verificación de bloqueo ANTES de intentar el login
                    if (rs.getBoolean("bloqueado")) {
                        System.out.println("UsuarioDAO: [Paso 3 - Verificación] El usuario está BLOQUEADO.");
                        usuario.setEstadoValidacion(EstadoValidacion.CUENTA_BLOQUEADA);
                        return null;
                    }

                    String passwordGuardado = rs.getString("contrasena_hash");
                    System.out.println("    -> Password de la BD: '" + passwordGuardado + "'");

                    if (BCrypt.checkpw(passwordPlano, passwordGuardado)) {
                        // ÉXITO
                        System.out.println("UsuarioDAO: [Paso 3 - Comparación] ¡Las contraseñas COINCIDEN!");
                        reiniciarIntentosFallidos(docIdentidad);
                        // CP-001: Actualizar la fecha de último login
                        actualizarUltimoLogin(docIdentidad);

                        usuario.setUsuarioId(rs.getInt("usuario_id"));
                        usuario.setDocumentoIdentidad(rs.getString("documento_identidad"));
                        Rol rol = new Rol();
                        rol.setRolId(rs.getInt("rol_id"));
                        rol.setNombreRol(rs.getString("nombre_rol"));
                        usuario.setRol(rol);
                        usuario.setEstadoValidacion(EstadoValidacion.LOGIN_EXITOSO);
                        return usuario;
                    } else {
                        // FALLO DE CONTRASEÑA
                        System.out.println("UsuarioDAO: [Paso 3 - Comparación] ERROR: ¡Las contraseñas NO coinciden!");

                        boolean fueBloqueado = incrementarIntentosFallidos(docIdentidad);

                        if (fueBloqueado) {
                            usuario.setEstadoValidacion(EstadoValidacion.CUENTA_BLOQUEADA);
                        } else {
                            usuario.setEstadoValidacion(EstadoValidacion.PASSWORD_INCORRECTO);
                        }

                        return null;
                    }
                } else {
                    System.out.println("UsuarioDAO: [Paso 2 - Búsqueda] ERROR: NO se encontró ningún usuario con ese documento.");
                    usuario.setEstadoValidacion(EstadoValidacion.USUARIO_NO_ENCONTRADO);
                    return null;
                }
            }
        } catch (SQLException e) {
            System.out.println("UsuarioDAO: ERROR FATAL de SQL al intentar conectar o ejecutar la consulta.");
            e.printStackTrace();
        }
        return null;
    }

    // ====================================================================================
    // NUEVO MÉTODO PARA CP-001: Actualiza la columna fecha_ultimo_login
    // ====================================================================================
    public void actualizarUltimoLogin(String docIdentidad) {
        // Se asume que la columna es tipo TIMESTAMP en la BD
        String sql = "UPDATE Usuarios SET fecha_ultimo_login = ? WHERE documento_identidad = ?";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Usa el tiempo actual para la actualización
            pstmt.setTimestamp(1, Timestamp.from(Instant.now()));
            pstmt.setString(2, docIdentidad);
            pstmt.executeUpdate();
            System.out.println("UsuarioDAO: [Side Effect] Fecha de último login actualizada para DNI: " + docIdentidad);

        } catch (SQLException e) {
            System.err.println("Error al actualizar la fecha de último login: " + e.getMessage());
            e.printStackTrace();
        }
    }
    // ====================================================================================


    public boolean registrarUsuario(String docIdentidad, String password) {
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
        // El rol_id para 'Paciente' es 3.
        String sql = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id) VALUES (?, ?, ?)";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, docIdentidad);
            pstmt.setString(2, hashedPassword);
            pstmt.setInt(3, 3); // Asignar rol de "Paciente" por defecto

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            System.out.println("ERROR AL REGISTRAR USUARIO: Falla en la operación SQL.");
            e.printStackTrace();
            return false;
        }
    }

    public EstadoCambioPassword actualizarContrasena(String docIdentidad, String passwordActual, String passwordNueva) {
        String sqlSelect = "SELECT contrasena_hash FROM Usuarios WHERE documento_identidad = ?";
        String sqlUpdate = "UPDATE Usuarios SET contrasena_hash = ? WHERE documento_identidad = ?";

        try (Connection conn = ConexionDB.getConnection()) {

            // 1. Obtener la contraseña actual hasheada
            String passwordGuardado = "";
            try (PreparedStatement pstmtSelect = conn.prepareStatement(sqlSelect)) {
                pstmtSelect.setString(1, docIdentidad);
                ResultSet rs = pstmtSelect.executeQuery();
                if (rs.next()) {
                    passwordGuardado = rs.getString("contrasena_hash");
                } else {
                    return EstadoCambioPassword.ERROR_BD; // Usuario no encontrado (no debería pasar si está logueado)
                }
            }

            // 2. Verificar que la contraseña actual sea correcta
            if (!BCrypt.checkpw(passwordActual, passwordGuardado)) {
                return EstadoCambioPassword.PASSWORD_ACTUAL_INCORRECTO;
            }

            // 3. (CP-020) Validar que la nueva contraseña cumpla el formato de seguridad
            if (!passwordNueva.matches(PASSWORD_REGEX)) {
                return EstadoCambioPassword.PASSWORD_NUEVA_INVALIDA;
            }

            // 4. (CP-019) Hashear y actualizar la nueva contraseña
            String newHashedPassword = BCrypt.hashpw(passwordNueva, BCrypt.gensalt());
            try (PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdate)) {
                pstmtUpdate.setString(1, newHashedPassword);
                pstmtUpdate.setString(2, docIdentidad);
                int rowsAffected = pstmtUpdate.executeUpdate();

                return (rowsAffected > 0) ? EstadoCambioPassword.EXITO : EstadoCambioPassword.ERROR_BD;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return EstadoCambioPassword.ERROR_BD;
        }
    }

    /**
     * Incrementa los intentos fallidos del usuario y lo bloquea si supera el límite.
     * @param docIdentidad El DNI del usuario.
     * @return true si el usuario fue bloqueado en esta llamada, false en caso contrario.
     */
    private boolean incrementarIntentosFallidos(String docIdentidad) {
        String sqlSelect = "SELECT intentos_fallidos FROM Usuarios WHERE documento_identidad = ?";
        String sqlUpdate = "UPDATE Usuarios SET intentos_fallidos = ?, bloqueado = ? WHERE documento_identidad = ?";

        try (Connection conn = ConexionDB.getConnection()) {
            int intentos = 0;
            try (PreparedStatement pstmtSelect = conn.prepareStatement(sqlSelect)) {
                pstmtSelect.setString(1, docIdentidad);
                ResultSet rs = pstmtSelect.executeQuery();
                if (rs.next()) {
                    intentos = rs.getInt("intentos_fallidos");
                }
            }

            intentos++;
            boolean bloquear = intentos >= MAX_INTENTOS_FALLIDOS;

            try (PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdate)) {
                pstmtUpdate.setInt(1, intentos);
                pstmtUpdate.setBoolean(2, bloquear);
                pstmtUpdate.setString(3, docIdentidad);
                pstmtUpdate.executeUpdate();
                if (bloquear) {
                    System.out.println("UsuarioDAO: El usuario con documento " + docIdentidad + " ha sido BLOQUEADO.");
                }
            }
            // RETORNAR el estado de bloqueo
            return bloquear;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void reiniciarIntentosFallidos(String docIdentidad) {
        // Al reiniciar, también se desbloquea el usuario (bloqueado = false)
        String sql = "UPDATE Usuarios SET intentos_fallidos = 0, bloqueado = ? WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setBoolean(1, false);
            pstmt.setString(2, docIdentidad);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // --- MÉTODOS PARA EL PANEL DE ADMIN DE USUARIOS ---

    public List<Usuario> listarTodosUsuarios() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT u.usuario_id, u.documento_identidad, u.bloqueado, r.rol_id, r.nombre_rol " +
                "FROM Usuarios u " +
                "JOIN Roles r ON u.rol_id = r.rol_id " +
                "ORDER BY u.documento_identidad";

        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Usuario u = new Usuario();
                u.setUsuarioId(rs.getInt("usuario_id"));
                u.setDocumentoIdentidad(rs.getString("documento_identidad"));

                Rol r = new Rol();
                r.setRolId(rs.getInt("rol_id"));
                r.setNombreRol(rs.getString("nombre_rol"));
                u.setRol(r);

                usuarios.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuarios;
    }

    public List<Rol> listarRoles() {
        List<Rol> roles = new ArrayList<>();
        String sql = "SELECT * FROM Roles ORDER BY nombre_rol";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Rol r = new Rol();
                r.setRolId(rs.getInt("rol_id"));
                r.setNombreRol(rs.getString("nombre_rol"));
                roles.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roles;
    }

    public boolean actualizarUsuarioAdmin(int usuarioId, int rolId, boolean bloqueado) {
        String sql = "UPDATE Usuarios SET rol_id = ?, bloqueado = ? WHERE usuario_id = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, rolId);
            pstmt.setBoolean(2, bloqueado);
            pstmt.setInt(3, usuarioId);

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}