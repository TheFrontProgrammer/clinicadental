package com.dental.app.clinicadentalapp.stepdefinitions;

import com.dental.app.clinicadentalapp.util.ConexionDB;
import io.cucumber.java.Before;
import io.cucumber.java.BeforeAll;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet; // Se agregó import por si es necesario en métodos internos
import org.mindrot.jbcrypt.BCrypt;

/**
 * Clase que maneja las precondiciones (Setup) y postcondiciones (Teardown)
 * de los escenarios de Cucumber, asegurando que la DB esté lista.
 */
public class Hooks {

    private static final String PASS_PACIENTE = "Rujel#2025r92!";
    private static final String PASS_ADMIN = "Admin.2025?";
    private static final String PASS_BLOQUEADO = "Bloq.2025!";

    /**
     * 1. Prepara la DB con los usuarios de prueba.
     */
    @BeforeAll
    public static void setupDatabase() {
        System.out.println("--- Ejecutando @BeforeAll: Preparando Usuarios de Prueba ---");
        Connection conn = null;
        try {
            conn = ConexionDB.getConnection();
            conn.setAutoCommit(false);

            // PASO 1: Limpieza completa (TRUNCATE)
            limpiarTablasCompletamente(conn);

            // PASO 2: Re-crear los Roles
            insertarRolesIniciales(conn);

            // **********************************************
            // FIX CRÍTICO: Commit intermedio para liberar los bloqueos
            conn.commit();
            conn.setAutoCommit(false); // Volver a iniciar la transacción para los usuarios
            // **********************************************


            // PASO 3: Asegurar que la columna 'fecha_ultimo_login' exista
            // Ya no hay conflicto de bloqueo, se ejecuta en su conexión aislada (como antes)
            asegurarColumnaLogin();

            // PASO 4: Re-crear Usuarios de Prueba (DML)
            deleteAndCreateUser(conn, "12345678", PASS_PACIENTE, 4, "Paciente", 0, false);
            deleteAndCreateUser(conn, "99999999", PASS_ADMIN, 1, "Administrador", 2, false);
            deleteAndCreateUser(conn, "87654321", PASS_BLOQUEADO, 4, "Paciente", 3, true);

            conn.commit(); // Commit final de la inserción de usuarios

        } catch (SQLException e) {
            // ... (resto del catch y finally es igual) ...
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            System.err.println("ERROR CRÍTICO EN SETUP DE DB: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Fallo en la conexión o setup de la Base de Datos.", e);
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    /**
     * Aísla el ALTER TABLE en su propia conexión para evitar abortar
     * la transacción principal del setup (solución al error PostgreSQL).
     */
    private static void asegurarColumnaLogin() { // ¡SIN argumento de conexión!
        System.out.println("Asegurando la existencia de la columna fecha_ultimo_login...");
        String sql = "ALTER TABLE Usuarios ADD COLUMN fecha_ultimo_login TIMESTAMP";

        // Abre su propia conexión para ejecutar el DDL de forma independiente
        try (Connection connDDL = ConexionDB.getConnection();
             PreparedStatement pstmt = connDDL.prepareStatement(sql)) {

            pstmt.executeUpdate();
            System.out.println("Columna 'fecha_ultimo_login' creada con éxito.");

        } catch (SQLException e) {
            // El SQLState '42701' en PostgreSQL significa "duplicate_column" (columna ya existe).
            if (e.getSQLState().equals("42701")) {
                System.out.println("Columna 'fecha_ultimo_login' ya existe. Continuando.");
            } else {
                // Si es un error real, se lanza
                System.err.println("Error DDL inesperado al asegurar la columna: " + e.getMessage());
                throw new RuntimeException("Error crítico en el setup de la columna de login.", e);
            }
        }
    }

    /**
     * 2. Limpia los intentos fallidos antes de CADA escenario.
     */
    @Before
    public void resetearIntentos() {
        System.out.println("--- Ejecutando @Before: Reseteando intentos fallidos ---");
        // Nota: Asegúrate de que este resetIntentos no intente poner una fecha de login
        resetIntentos("12345678", 0, false);
        resetIntentos("99999999", 2, false);
        resetIntentos("87654321", 3, true);
    }

    /*=======================================================
     * MÉTODOS DE MANIPULACIÓN DE DB (resto del código original)
     *=======================================================*/

    private static void limpiarTablasCompletamente(Connection conn) throws SQLException {
        System.out.println("Limpiando tablas de prueba (Usando TRUNCATE ... RESTART IDENTITY CASCADE)...");
        try {
            // 1. Hijos de Nivel más Profundo (Inventario, Pagos, Tratamiento)
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Detalle_Solicitud RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Detalle_Tratamiento RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Pagos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            // 2. Padres de Nivel Medio
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Historial_Tratamientos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Facturas RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Horarios_Disponibles RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            // 3. Entidades con alto nivel de dependencia
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Citas RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Solicitudes_Insumos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            // 4. Entidades de Catálogo (No tienen hijos, pero se usa CASCADE por seguridad)
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Insumos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Tipos_Tratamientos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            // 5. Entidades Principales (Hijos directos de Usuarios)
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Pacientes RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Odontologos RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Recepcionistas RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            // 6. Tablas Core (Usuarios antes que Roles)
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Usuarios RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }
            try (PreparedStatement stmt = conn.prepareStatement("TRUNCATE TABLE Roles RESTART IDENTITY CASCADE")) { stmt.executeUpdate(); }

            System.out.println("Limpieza completa y secuencias reiniciadas con éxito.");

        } catch (SQLException e) {
            throw new SQLException("Fallo en la limpieza de la tabla (Verificar la existencia de las tablas).", e);
        }
    }

    private static void insertarRolesIniciales(Connection conn) throws SQLException {
        System.out.println("Insertando roles iniciales...");
        String sqlInsertRoles = "INSERT INTO Roles (nombre_rol) VALUES (?), (?), (?), (?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertRoles)) {
            pstmt.setString(1, "Administrador");
            pstmt.setString(2, "Odontologo");
            pstmt.setString(3, "Recepcionista");
            pstmt.setString(4, "Paciente");
            pstmt.executeUpdate();
        }
        System.out.println("Roles insertados: 1=Administrador, 2=Odontologo, 3=Recepcionista, 4=Paciente.");
    }

    private static void deleteAndCreateUser(Connection conn, String dni, String password, int rolId, String rolNombre, int intentos, boolean bloqueado) throws SQLException {
        String sqlDelete = "DELETE FROM Usuarios WHERE documento_identidad = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlDelete)) {
            pstmt.setString(1, dni);
            pstmt.executeUpdate();
        }

        String sqlInsert = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id, intentos_fallidos, bloqueado) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlInsert)) {
            pstmt.setString(1, dni);
            pstmt.setString(2, BCrypt.hashpw(password, BCrypt.gensalt()));
            pstmt.setInt(3, rolId); // 1: Admin, 4: Paciente
            pstmt.setInt(4, intentos);
            pstmt.setBoolean(5, bloqueado);
            pstmt.executeUpdate();
        }
    }

    private void resetIntentos(String dni, int intentos, boolean bloqueado) {
        String sql = "UPDATE Usuarios SET intentos_fallidos = ?, bloqueado = ? WHERE documento_identidad = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, intentos);
            pstmt.setBoolean(2, bloqueado);
            pstmt.setString(3, dni);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("ERROR al resetear intentos para " + dni + ": " + e.getMessage());
        }
    }
}