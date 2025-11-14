package com.dental.app.clinicadentalapp.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    
    // CAMBIO 1: La URL ahora apunta a tu base de datos PostgreSQL.
    private static final String URL = "jdbc:postgresql://dpg-d3rb1s3uibrs73fqhr5g-a.virginia-postgres.render.com:5432/clinicadental_w71y";
    
    // CAMBIO 2: El usuario y contraseña de TU PostgreSQL (los que usas en DBeaver).
    private static final String USER = "clinic_user"; // Este es el usuario por defecto, cámbialo si usas otro.
    private static final String PASSWORD = "yrVkdRxr7U9kWjcxfWwJ9g9ztMWxdBKL"; // ¡IMPORTANTE! PON AQUÍ TU CONTRASEÑA REAL.

    public static Connection getConnection() throws SQLException {
        try {
            // CAMBIO 3: Le decimos a Java que cargue el driver de PostgreSQL.
            Class.forName("org.postgresql.Driver");
            
            // Esta línea usa los nuevos datos de arriba para conectarse.
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            // Mensaje de error actualizado para PostgreSQL.
            throw new SQLException("Error: Driver JDBC de PostgreSQL no encontrado.", e);
        }
    }
    /**
     * Limpia un conjunto de tablas en la base de datos de forma transaccional,
     * desactivando las restricciones de FK temporalmente para permitir el borrado.
     * * @param tables Las tablas a limpiar, listadas del "hijo" al "padre" para PostgreSQL.
     * @throws SQLException Si ocurre un error de base de datos.
     */
    // Nuevo método en ConexionDB.java:
    public static void limpiarTablasDePrueba(String... tables) throws SQLException {
        if (tables == null || tables.length == 0) return;

        // ORDEN CORRECTO DE BORRADO (hijo a padre):
        // 1. Detalle_Tratamiento (Hijo de Historial_Tratamientos)
        // 2. Historial_Tratamientos (Hijo de Citas)
        // 3. Citas
        // 4. Pacientes / Odontologos / Recepcionistas / Administradores (Dependen de Usuarios)
        // 5. Usuarios

        // NOTA: Para este setup, el array debe ser:
        // {"Detalle_Tratamiento", "Historial_Tratamientos", "Citas", "Pacientes", "Odontologos", "Usuarios"}

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Iniciar transacción

            for (String tableName : tables) {
                String sqlDelete = "DELETE FROM " + tableName; // Simple DELETE sin permisos especiales
                try (java.sql.Statement stmt = conn.createStatement()) {
                    stmt.execute(sqlDelete);
                    System.out.println("DEBUG: Tabla " + tableName + " limpiada con DELETE.");
                }
            }

            conn.commit(); // Confirmar

        } catch (SQLException e) {
            System.err.println("ERROR DURANTE LA LIMPIEZA DE TABLAS (DELETE): " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
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

