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
}

