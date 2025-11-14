package com.dental.app.clinicadentalapp.stepdefinitions;

import com.dental.app.clinicadentalapp.UsuarioDAO;
import com.dental.app.clinicadentalapp.UsuarioDAO.EstadoValidacion;
import com.dental.app.clinicadentalapp.model.Usuario;
import com.dental.app.clinicadentalapp.util.ConexionDB;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.cucumber.java.en.Then;
import static org.junit.jupiter.api.Assertions.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

// ¡¡IMPORTANTE!! ASEGÚRATE DE TENER ESTE IMPORT
import org.mindrot.jbcrypt.BCrypt;

public class LoginSteps {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();
    private Usuario usuarioTest = new Usuario();
    private String dniTest;
    private String passwordTest;
    private int intentosIniciales = 0;
    private Timestamp fechaLoginPrevia;

    // --- Métodos de Verificación de DB (Helper Functions) ---
    private int getIntentosFallidos(String dni) throws SQLException {
        String sql = "SELECT intentos_fallidos FROM Usuarios WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, dni);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt("intentos_fallidos");
                return -1;
            }
        }
    }

    private boolean isUsuarioBloqueado(String dni) throws SQLException {
        String sql = "SELECT bloqueado FROM Usuarios WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, dni);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getBoolean("bloqueado");
                return false;
            }
        }
    }

    // CP-001 y CP-002: Helper para obtener la fecha de último login
    private Timestamp getFechaUltimoLogin(String dni) throws SQLException {
        String sql = "SELECT fecha_ultimo_login FROM Usuarios WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, dni);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getTimestamp("fecha_ultimo_login");
                return null;
            }
        }
    }


    // --- NUEVO MÉTODO HELPER PARA CREAR USUARIOS DE PRUEBA ---
    // Este método creará el usuario que necesitamos en CADA GIVEN
    private void setupUsuario(String dni, String password, int rolId, int intentos, boolean bloqueado) throws SQLException {
        String sqlDelete = "DELETE FROM Usuarios WHERE documento_identidad = ?";
        String sqlInsert = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id, intentos_fallidos, bloqueado) VALUES (?, ?, ?, ?, ?)";

        // Usamos try-with-resources para asegurar que la conexión se cierre
        try (Connection conn = ConexionDB.getConnection()) {

            // 1. Borra el usuario por si existe de un test anterior
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDelete)) {
                pstmt.setString(1, dni);
                pstmt.executeUpdate();
            }

            // 2. Inserta el usuario con los datos correctos y contraseña hasheada
            try (PreparedStatement pstmt = conn.prepareStatement(sqlInsert)) {
                pstmt.setString(1, dni);
                pstmt.setString(2, BCrypt.hashpw(password, BCrypt.gensalt())); // Hashea la contraseña
                pstmt.setInt(3, rolId); // 4: Paciente, 1: Admin
                pstmt.setInt(4, intentos);
                pstmt.setBoolean(5, bloqueado);
                pstmt.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("Error fatal en el setupUsuario para " + dni + ": " + e.getMessage());
            throw e; // Lanza la excepción para que el test falle si el setup no funciona
        }
    }


    /*=======================================================
     * GIVEN Steps (¡¡MODIFICADOS!!)
     *=======================================================*/

    /**
     * Define el paso genérico para cualquier usuario con credenciales,
     * solucionando el UndefinedStepException.
     * (Usado por CP-002 - Usuario no encontrado)
     */
    @Given("un usuario con DNI {string} y contraseña {string}")
    public void un_usuario_con_dni_y_contrasena(String dni, String password) {
        // Para CP-002 (Usuario no encontrado), NO creamos ningún usuario.
        // Así nos aseguramos de que no exista y falle como se espera.
        this.dniTest = dni;
        this.passwordTest = password;
    }


    @Given("un usuario registrado con DNI {string} y contraseña {string}")
    public void un_usuario_registrado_con_dni_y_contrasena(String dni, String password) throws SQLException {
        // ¡¡CAMBIO!!
        // CP-001: Creamos el usuario (rol 4=Paciente, 0 intentos, no bloqueado)
        setupUsuario(dni, password, 4, 0, false);

        this.dniTest = dni;
        this.passwordTest = password;
        // CP-001: Guarda la fecha de login previa para verificar la actualización
        this.fechaLoginPrevia = getFechaUltimoLogin(dni);
    }

    @Given("un usuario con DNI {string} que tiene el estado 'bloqueado' en TRUE")
    public void un_usuario_con_dni_bloqueado(String dni) throws SQLException {
        // ¡¡CAMBIO!!
        // CP-005: Creamos al usuario bloqueado (rol 4=Paciente, 3 intentos, bloqueado)
        // La contraseña está definida en el feature (Bloq.2025!)
        setupUsuario(dni, "Bloq.2025!", 4, 3, true);

        this.dniTest = dni;
    }

    @Given("un usuario registrado con DNI {string}")
    public void un_usuario_registrado_con_dni(String dni) throws SQLException {

        setupUsuario(dni, "Rujel#2025r92!", 4, 0, false);

        this.dniTest = dni;
        this.intentosIniciales = getIntentosFallidos(dni);
    }

    @Given("un usuario registrado con DNI {string} con {int} intentos fallidos")
    public void un_usuario_registrado_con_intentos_fallidos(String dni, int intentos) throws SQLException {

        setupUsuario(dni, "Admin.2025?", 1, intentos, false);

        this.dniTest = dni;
        this.intentosIniciales = getIntentosFallidos(dni);
    }


    @Given("un usuario con DNI {string} que no está registrado")
    public void un_usuario_con_dni_que_no_esta_registrado(String dni) {
        this.dniTest = dni;
        this.passwordTest = "AnyPassword123!";
    }

    @When("el usuario intenta iniciar sesión con contraseña incorrecta {string}")
    public void el_usuario_intenta_iniciar_sesion_con_contrasena_incorrecta(String badPassword) {
        usuarioDAO.validarUsuario(dniTest, badPassword, usuarioTest);
    }

    @When("el usuario intenta iniciar sesión con contraseña {string}")
    public void el_usuario_intenta_iniciar_sesion_con_contrasena(String password) {
        usuarioDAO.validarUsuario(dniTest, password, usuarioTest);
    }

    @When("el usuario intenta iniciar sesión")
    public void el_usuario_intenta_iniciar_sesion() {
        usuarioDAO.validarUsuario(dniTest, passwordTest, usuarioTest);
    }

    @When("el usuario intenta iniciar sesión por tercera vez con contraseña incorrecta {string}")
    public void el_usuario_intenta_iniciar_sesion_por_tercera_vez(String password) {
        usuarioDAO.validarUsuario(dniTest, password, usuarioTest);
    }

    @Then("el estado de validación del login es {word}")
    public void el_estado_de_validacion_del_login_es(String estadoEsperado) {
        EstadoValidacion expected = EstadoValidacion.valueOf(estadoEsperado);

        assertEquals(expected, usuarioTest.getEstadoValidacion(), "El estado de validación no coincide.");
    }

    @Then("la sesión contiene al usuario {string} con rol {string}")
    public void la_sesion_contiene_al_usuario_con_rol(String dni, String rol) {
        assertEquals(dni, usuarioTest.getDocumentoIdentidad(), "El DNI del usuario logueado no coincide.");
        assertEquals(rol, usuarioTest.getRol().getNombreRol(), "El rol del usuario logueado no coincide.");
        System.out.println("✅ CP-001 / CP-005: Login exitoso y Rol de acceso verificado.");
    }

    @Then("los intentos fallidos para el DNI {string} aumentan en la base de datos")
    public void los_intentos_fallidos_aumentan_en_la_base_de_datos(String dni) throws SQLException {
        int intentosActuales = getIntentosFallidos(dni);
        // Verificación: Los intentos deben ser mayores que el estado inicial (normalmente 0).
        assertTrue(intentosActuales > intentosIniciales, "Los intentos fallidos no se incrementaron correctamente.");
        System.out.println("✅ CP-003: Intentos fallidos incrementados correctamente.");
    }

    @Then("el campo 'bloqueado' es TRUE para el DNI {string}")
    public void el_campo_bloqueado_es_true(String dni) throws SQLException {
        assertTrue(isUsuarioBloqueado(dni), "El campo 'bloqueado' debe ser TRUE después del tercer intento.");
        System.out.println("✅ CP-004: Bloqueo de cuenta verificado tras 3 intentos.");
    }

    // CP-001: Verificación de que la fecha de último login se actualizó
    @Then("la fecha de ultimo login para el DNI {string} ha sido actualizada")
    public void la_fecha_de_ultimo_login_ha_sido_actualizada(String dni) throws SQLException {
        Timestamp fechaActual = getFechaUltimoLogin(dni);

        // Asume que la fecha actual es más reciente que la fecha previa
        assertNotNull(fechaActual, "La fecha de último login no debe ser nula.");

        // Verifica que la nueva fecha es *después* de la fecha previa (si existía)
        if (fechaLoginPrevia != null) {
            assertTrue(fechaActual.after(fechaLoginPrevia), "La fecha de último login no se actualizó.");
        }

        // Verificación de tiempo extra: Asegura que se actualizó en los últimos 5 segundos
        long diff = Timestamp.from(Instant.now()).getTime() - fechaActual.getTime();
        assertTrue(diff < 5000, "La fecha de login se actualizó pero no fue reciente (< 5s).");

        System.out.println("✅ CP-001: Fecha de último login actualizada correctamente.");
    }
}