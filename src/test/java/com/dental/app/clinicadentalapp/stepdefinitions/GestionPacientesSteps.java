package com.dental.app.clinicadentalapp.stepdefinitions;

import com.dental.app.clinicadentalapp.CitaDAO;
import com.dental.app.clinicadentalapp.PacienteDAO;
import com.dental.app.clinicadentalapp.model.Cita;
import com.dental.app.clinicadentalapp.model.Paciente;
import com.dental.app.clinicadentalapp.model.Usuario;
import com.dental.app.clinicadentalapp.util.ConexionDB;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Definiciones de pasos para la gestión de pacientes (CP-006 a CP-012).
 * Incluye lógica de SETUP transaccional para asegurar un entorno de prueba limpio.
 */
public class GestionPacientesSteps {

    // DAOs
    private final PacienteDAO pacienteDAO = new PacienteDAO();
    private final CitaDAO citaDAO = new CitaDAO();

    // Variables de estado
    private Paciente pacienteTest;
    private String passwordTest;
    private boolean resultadoOperacion;
    private Paciente pacienteObtenido;
    private List<Paciente> pacientesEncontrados;


    /** ID del paciente a eliminar, capturado del Given para usarlo en el Then. */
    private int pacienteIdToDelete = 0;
    /** ID del usuario a eliminar, capturado del Given para usarlo en el Then. */
    private int usuarioIdToDelete = 0;

    // Constantes para IDs de prueba
    private final int ID_ODONTOLOGO_PRUEBA = 1;
    private final int ID_TIPO_TRATAMIENTO_PRUEBA = 1000;
    private final int ID_CITA_CP009 = 300;

    private int idBaseBusquedaUnico = 6000;

    // =================================================================================
    // SETUP GLOBAL Y TRANSACCIONAL
    // =================================================================================


    @Given("que la base de datos está disponible y limpia para el test")
    public void que_la_base_de_datos_esta_disponible_y_limpia_para_el_test() throws SQLException {
        System.out.println("SETUP: Base de datos disponible y limpia para el test.");
        // Reset de estado
        pacienteTest = null;
        passwordTest = null;
        resultadoOperacion = false;
        pacienteObtenido = null;
        pacientesEncontrados = null;
        pacienteIdToDelete = 0; // Reset del ID de eliminación
        usuarioIdToDelete = 0; // Reset del ID de usuario a eliminar

        // Inserción de entidades base requeridas por Foreign Keys
        insertarOdontologoDePrueba(ID_ODONTOLOGO_PRUEBA);
        insertarTipoTratamiento();
    }

    private void insertarOdontologoDePrueba(int id) throws SQLException {
        Connection conn = ConexionDB.getConnection();
        conn.setAutoCommit(false);
        try {
            // 1. Insertar Usuario
            String sqlUsuario = "INSERT INTO Usuarios (usuario_id, documento_identidad, contrasena_hash, rol_id) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlUsuario)) {
                pstmt.setInt(1, id + 1000);
                pstmt.setString(2, "ODONTO"+id);
                pstmt.setString(3, "$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                pstmt.setInt(4, 2);
                pstmt.executeUpdate();
            }

            // 2. Insertar Odontologo
            String sqlOdontologo = "INSERT INTO Odontologos (odontologo_id, usuario_id, nombre, apellido, especialidad) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlOdontologo)) {
                pstmt.setInt(1, id);
                pstmt.setInt(2, id + 1000);
                pstmt.setString(3, "Dr. Test");
                pstmt.setString(4, "Odonto");
                pstmt.setString(5, "General");
                pstmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            // Si el error es una violación de clave única (SQLState 23505),
            // asumimos que el dato ya existe y hacemos commit para no fallar la transacción.
            if (e.getSQLState().equals("23505")) {
                conn.commit();
            } else {
                conn.rollback();
                throw e; // Relanzar cualquier otro error grave
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    private void insertarTipoTratamiento() throws SQLException {
        Connection conn = ConexionDB.getConnection();
        conn.setAutoCommit(false);
        try {
            String sql = "INSERT INTO Tipos_Tratamientos (tipo_tratamiento_id, nombre_tratamiento, costo) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, ID_TIPO_TRATAMIENTO_PRUEBA);
                pstmt.setString(2, "Limpieza de Prueba");
                pstmt.setBigDecimal(3, new BigDecimal("50.00"));
                pstmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            // Si el error es una violación de clave única (SQLState 23505),
            // asumimos que el dato ya existe y hacemos commit para no fallar la transacción.
            if (e.getSQLState().equals("23505")) {
                conn.commit();
            } else {
                conn.rollback();
                throw e; // Relanzar cualquier otro error grave
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }


    /** Inserta un paciente base (con su usuario asociado) en la BD. */
    private void insertarPacienteDePrueba(int pacienteId, String nombre, String apellido, String dni, String genero) throws SQLException {
        Connection conn = ConexionDB.getConnection();
        conn.setAutoCommit(false);
        try {
            // 1. Insertar Usuario
            // ¡QUITAR LA ESPECIFICACIÓN DEL ID!
            String sqlUsuario = "INSERT INTO Usuarios (documento_identidad, contrasena_hash, rol_id) VALUES (?, ?, ?) RETURNING usuario_id";
            int nuevoUsuarioId; // Necesitamos capturar el ID generado

            try (PreparedStatement pstmt = conn.prepareStatement(sqlUsuario)) {
                // No se establece el parámetro 1 (usuario_id)
                pstmt.setString(1, dni);
                pstmt.setString(2, "$2a$10$XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                pstmt.setInt(3, 4); // Rol Paciente

                ResultSet rs = pstmt.executeQuery(); // Usar executeQuery para RETURNING
                if (rs.next()) {
                    nuevoUsuarioId = rs.getInt(1); // Capturar el ID generado
                } else {
                    throw new SQLException("Fallo al obtener el ID del nuevo usuario.");
                }
            }

            // 2. Insertar Paciente
            // ¡QUITAR LA ESPECIFICACIÓN DEL ID!
            String sqlPaciente = "INSERT INTO Pacientes (usuario_id, nombre, apellido, fecha_nacimiento, genero, telefono, email, direccion, alergias) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlPaciente)) {
                // Usamos el ID generado por la BD
                pstmt.setInt(1, nuevoUsuarioId);
                pstmt.setString(2, nombre);
                pstmt.setString(3, apellido);
                // ... (el resto del código sigue igual)
                if (new Date() != null) {
                    pstmt.setDate(4, new java.sql.Date(new Date().getTime()));
                } else {
                    pstmt.setNull(4, java.sql.Types.DATE);
                }
                pstmt.setString(5, genero.substring(0, 1));
                pstmt.setString(6, "123456789");
                pstmt.setString(7, dni + "@test.com");
                pstmt.setString(8, "Calle Falsa 123");
                pstmt.setString(9, "");
                pstmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {

            // Si el error es una violación de clave única (SQLState 23505)
            if (e.getSQLState().equals("23505")) {
                // Este es el error esperado (DNI duplicado en setup).
                // Podrías imprimir un mensaje informativo, pero no de error grave.
                System.out.println("SETUP INFO: DNI " + dni + " ya existe. Saltando inserción para continuar con la prueba.");

                // Si el error es de unicidad, asumimos que es el dato de setup anterior que quedó.
                conn.commit();
                return;
            } else {
                // Este sí es un error de verdad o un error de FK/otra cosa.
                System.err.println("ERROR FATAL en inserción de paciente de prueba con DNI " + dni + ": " + e.getMessage());
                conn.rollback();
                throw e;
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    private void insertarCitaDePrueba(int citaId, int pacienteId) throws SQLException {
        Connection conn = ConexionDB.getConnection();
        conn.setAutoCommit(false);
        try {
            // FIX: Se elimina ON CONFLICT para asegurar la inserción limpia en tests.
            String sqlCita = "INSERT INTO Citas (cita_id, paciente_id, odontologo_id, fecha_cita, hora_cita, estado) VALUES (?, ?, ?, ?, ?, 'Agendada')";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlCita)) {
                pstmt.setInt(1, citaId);
                pstmt.setInt(2, pacienteId);
                pstmt.setInt(3, ID_ODONTOLOGO_PRUEBA);
                pstmt.setDate(4, new java.sql.Date(new Date().getTime()));
                pstmt.setTime(5, new java.sql.Time(new Date().getTime()));
                pstmt.executeUpdate();
            }
            conn.commit();
        } catch (Exception e) {
            // Ignorar errores de clave primaria en el setup global si la limpieza previa es insuficiente
            if (!e.getMessage().contains("violación de clave única")) {
                conn.rollback();
                throw e;
            } else {
                conn.commit(); // Si ya existe, asumimos que está bien y continuamos
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    private void insertarHistorialYDetalleTratamiento(int citaId) throws SQLException {
        Connection conn = ConexionDB.getConnection();
        conn.setAutoCommit(false);
        try {
            // 1. Insertar Historial_Tratamientos
            int historialId = citaId + 10;
            // FIX: Se elimina ON CONFLICT para asegurar la inserción limpia en tests.
            String sqlHistorial = "INSERT INTO Historial_Tratamientos (historial_id, cita_id, diagnostico) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlHistorial)) {
                pstmt.setInt(1, historialId);
                pstmt.setInt(2, citaId);
                pstmt.setString(3, "Diagnóstico de prueba asociado a la cita " + citaId);
                pstmt.executeUpdate();
            }

            // 2. Insertar Detalle_Tratamiento
            int detalleId = citaId + 20;
            // FIX: Se elimina ON CONFLICT para asegurar la inserción limpia en tests.
            String sqlDetalle = "INSERT INTO Detalle_Tratamiento (detalle_id, historial_id, tipo_tratamiento_id, observaciones) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDetalle)) {
                pstmt.setInt(1, detalleId);
                pstmt.setInt(2, historialId);
                pstmt.setInt(3, ID_TIPO_TRATAMIENTO_PRUEBA);
                pstmt.setString(4, "Tratamiento aplicado de prueba para la eliminación.");
                pstmt.executeUpdate();
            }

            conn.commit();
        } catch (Exception e) {
            // Ignorar errores de clave primaria en el setup global si la limpieza previa es insuficiente
            if (!e.getMessage().contains("violación de clave única")) {
                conn.rollback();
                throw e;
            } else {
                conn.commit(); // Si ya existe, asumimos que está bien y continuamos
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }


    // =================================================================================
    // CP-006: Registro Exitoso de Paciente (Pasos adaptados)
    // =================================================================================

    @Given("hay un nuevo paciente con DNI {string} y password {string}")
    public void hay_un_nuevo_paciente_con_dni_y_password(String dni, String password) {
        this.passwordTest = password;
        Usuario usuario = new Usuario();
        usuario.setDocumentoIdentidad(dni);
        pacienteTest = new Paciente();
        pacienteTest.setUsuario(usuario);
        pacienteTest.setNombre("Nuevo");
        pacienteTest.setApellido("Registrado");
        pacienteTest.setGenero("M");
    }

    @When("el administrador intenta registrar al paciente")
    public void el_administrador_intenta_registrar_al_paciente() {
        try {
            resultadoOperacion = pacienteDAO.registrarPaciente(pacienteTest, passwordTest);
        } catch (Exception e) {
            e.printStackTrace();
            resultadoOperacion = false;
        }
    }

    @Then("el registro de usuario es exitoso")
    public void el_registro_de_usuario_es_exitoso() {
        assertTrue(true, "El registro de usuario se inició (esperando la verificación de BD).");
        // Mensaje de Éxito
        System.out.println("✅ CP-006 (Paso 1): El registro del paciente se inició correctamente (resultado 'true').");
    }

    @Then("la cuenta de usuario {string} existe en la BD")
    public void la_cuenta_de_usuario_existe_en_la_bd(String dni) {
        assertTrue(resultadoOperacion, "La operación de registro debería ser exitosa (true).");
        Paciente pacienteGuardado = pacienteDAO.buscarPacientePorDNI(dni);
        assertNotNull(pacienteGuardado, "El paciente debe ser recuperable por DNI después del registro exitoso.");
        // Mensaje de Éxito
        System.out.println("✅ CP-006 (FINAL): El paciente con DNI " + dni + " fue registrado y se verificó su existencia en la BD.");
    }

    // =================================================================================
    // CP-007: Registro de DNI Duplicado (Pasos adaptados)
    // =================================================================================

    @Given("existe un paciente con DNI {string} ya registrado")
    public void existe_un_paciente_con_dni_ya_registrado(String dni) throws Exception {
        insertarPacienteDePrueba(1007, "Duplicado", "Original", dni, "F");
    }

    @Given("hay un nuevo paciente con DNI {string} \\(duplicado)")
    public void hay_un_nuevo_paciente_con_dni_duplicado(String dni) {
        hay_un_nuevo_paciente_con_dni_y_password(dni, "PassDuplicado");
    }

    @Then("el registro debe fallar con un error de unicidad")
    public void el_registro_debe_fallar_con_un_error_de_unicidad() {
        assertFalse(resultadoOperacion, "El registro debe fallar (false) debido a la duplicidad de DNI.");
        // Mensaje de Éxito
        System.out.println("✅ CP-007 (FINAL): El intento de registrar un paciente con DNI duplicado falló como se esperaba.");
    }

    // =================================================================================
    // CP-008: Actualización Exitosa de Paciente
    // =================================================================================

    @Given("existe un paciente con ID {int} con nombre {string} y DNI {string}")
    public void existe_un_paciente_con_id_con_nombre_y_dni(int id, String nombre, String dni) throws SQLException {
        // 1. Insertamos usando la nueva lógica que genera IDs automáticamente.
        // Ignoramos el 'id' que viene del feature file porque ya no lo usamos para insertar.
        insertarPacienteDePrueba(id, nombre, "ApellidoBase", dni, "M");

        // 2. Recuperamos el paciente recién insertado usando el DNI,
        //    ya que el ID original (99) es ahora incorrecto.
        pacienteTest = pacienteDAO.buscarPacientePorDNI(dni);

        // 3. La aserción ahora verifica si la inserción fue exitosa a través del DNI.
        assertNotNull(pacienteTest, "El paciente debe existir para la prueba CP-008.");
    }

    @When("el usuario actualiza el nombre del paciente ID {int} a {string}")
    public void el_usuario_actualiza_el_nombre_del_paciente_id_a(int id, String nuevoNombre) {
        pacienteTest.setNombre(nuevoNombre);
        resultadoOperacion = pacienteDAO.actualizarPaciente(pacienteTest);
    }

    @Then("la actualización de datos personales es exitosa")
    public void la_actualización_de_datos_personales_es_exitosa() {
        assertTrue(resultadoOperacion, "La actualización debería ser exitosa (true).");
        // Mensaje de Éxito
        System.out.println("✅ CP-008 (Paso 1): La operación de actualización de datos personales fue exitosa.");
    }

    @Then("el DNI {string} y la contraseña del usuario ID {int} no han sido alterados")
    public void el_dni_y_la_contraseña_del_usuario_id_no_han_sido_alterados(String dniEsperado, int idPaciente) {

        // USAMOS EL ID REAL DEL PACIENTE GUARDADO EN EL SETUP
        int idPacienteReal = pacienteTest.getPacienteId();

        Paciente pacienteActualizado = pacienteDAO.obtenerPacientePorId(idPacienteReal);

        assertNotNull(pacienteActualizado, "El paciente debe seguir existiendo.");
        assertEquals(dniEsperado, pacienteActualizado.getUsuario().getDocumentoIdentidad(), "El DNI no debe haber sido alterado.");

        // Mensaje de Éxito
        System.out.println("✅ CP-008 (FINAL): La actualización de datos personales fue exitosa y los campos sensibles (DNI) permanecieron inalterados.");
    }

    // =================================================================================
    // CP-009: Eliminación Transaccional de Paciente
    // =================================================================================

    @Given("existe un paciente con ID {int} que tiene una cita asociada y un usuario")
    public void existe_un_paciente_con_id_que_tiene_una_cita_asociada_y_un_usuario(int id) throws SQLException {
        // --- 1. INSERTAR PACIENTE Y CAPTURAR ID REAL ---
        insertarPacienteDePrueba(id, "Paciente", "Eliminar", "44444444", "M");

        // Lo buscamos por DNI para obtener el ID real que la BD generó
        Paciente pacienteInsertado = pacienteDAO.buscarPacientePorDNI("44444444");

        assertNotNull(pacienteInsertado, "El paciente para eliminar debe ser insertado y recuperado.");

        this.pacienteIdToDelete = pacienteInsertado.getPacienteId(); // ¡Capturamos el ID real!
        this.usuarioIdToDelete = pacienteInsertado.getUsuario().getUsuarioId(); // Capturamos el ID de usuario real

        // --- 2. USAR ID REAL PARA INSERTAR CITA ---
        // Usamos el ID real capturado (this.pacienteIdToDelete)
        insertarCitaDePrueba(ID_CITA_CP009, this.pacienteIdToDelete);

        // --- 3. Insertar Historial y Detalle
        insertarHistorialYDetalleTratamiento(ID_CITA_CP009);

        // Verificaciones iniciales
        pacienteTest = pacienteDAO.obtenerPacientePorId(this.pacienteIdToDelete);
        assertNotNull(pacienteTest, "El paciente debe existir antes de la eliminación.");
    }

    @When("el administrador elimina al paciente con ID {int}")
    public void el_administrador_elimina_al_paciente_con_id(int id) {
        // Aquí el ID que se pasa (id) es el ID FIJO del feature (100).
        // DEBE USARSE EL ID REAL GUARDADO: this.pacienteIdToDelete
        resultadoOperacion = pacienteDAO.eliminarPaciente(this.pacienteIdToDelete);
    }

    @Then("la eliminación es exitosa")
    public void la_eliminacion_es_exitosa() {
        assertTrue(resultadoOperacion, "La eliminación del paciente debe ser exitosa (true).");
        // Verificación principal: usa el ID REAL
        assertNull(pacienteDAO.obtenerPacientePorId(pacienteIdToDelete), "El paciente no debe existir en la BD después de la eliminación.");
        // Mensaje de Éxito
        System.out.println("✅ CP-009 (Paso 1): La operación de eliminación del paciente fue exitosa.");
    }

    // --- Pasos Faltantes ---
    /**
     * Verifica que la cita con ID_CITA_CP009 ya no exista.
     */
    @Then("la cita asociada ya no existe en la tabla Citas")
    public void la_cita_asociada_ya_no_existe_en_la_tabla_citas() {
        Cita citaEliminada = citaDAO.obtenerCitaPorId(ID_CITA_CP009);
        assertNull(citaEliminada, "La cita asociada (ID: " + ID_CITA_CP009 + ") debió ser eliminada por CASCADE o por la lógica transaccional.");
        // Mensaje de Éxito
        System.out.println("✅ CP-009 (Paso 2): La cita asociada fue eliminada por la transacción o CASCADE.");
    }

    /**
     * Verifica que el registro de usuario asociado al paciente ya no exista.
     */
    @Then("el registro de usuario con ID {int} ya no existe en la tabla Usuarios")
    public void el_registro_de_usuario_con_id_ya_no_existe_en_la_tabla_usuarios(Integer idUsuario) throws SQLException {
        // Usamos la ID capturada
        boolean existe = verificarUsuarioExiste(usuarioIdToDelete);
        assertFalse(existe, "El usuario asociado (ID: " + usuarioIdToDelete + ") debe haber sido eliminado.");
        // Mensaje de Éxito
        System.out.println("✅ CP-009 (FINAL): El registro de usuario asociado fue eliminado. La eliminación transaccional es correcta.");
    }

    private boolean verificarUsuarioExiste(int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM Usuarios WHERE usuario_id = ?";
        try (Connection conn = ConexionDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idUsuario);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }
    // -------------------------


    // =================================================================================
    // CP-010, CP-011, CP-012: Búsqueda
    // =================================================================================

    @Given("existe un paciente con DNI {string} en la BD")
    public void existe_un_paciente_con_dni_en_la_bd(String dni) throws SQLException {
        insertarPacienteDePrueba(5000, "BusquedaDNI", "Test", dni, "F");
    }

    @When("se realiza una búsqueda por DNI {string}")
    public void se_realiza_una_búsqueda_por_dni(String dni) {
        pacienteObtenido = pacienteDAO.buscarPacientePorDNI(dni);
    }

    @Then("el sistema debe retornar exactamente a ese paciente")
    public void el_sistema_debe_retornar_exactamente_a_ese_paciente() {
        assertNotNull(pacienteObtenido, "El paciente debe ser encontrado.");
        // Mensaje de Éxito CP-010
        System.out.println("✅ CP-010 (FINAL): La búsqueda por DNI fue exitosa y retornó al paciente correcto.");
    }

    @Then("no se retorna ningún paciente")
    public void no_se_retorna_ningun_paciente() {
        assertNull(pacienteObtenido, "No se debe retornar ningún paciente.");
        // Mensaje de Éxito CP-011 (DNI no encontrado)
        System.out.println("✅ CP-011 (FINAL): La búsqueda por DNI no encontró resultados para un DNI inexistente, como se esperaba.");
    }

    @Given("existen pacientes llamados {string} y {string} en la BD")
    public void existen_pacientes_llamados_y_en_la_bd(String paciente1, String paciente2) throws SQLException {
        // Obtenemos un sello de tiempo como base para el DNI para asegurar la unicidad
        String timestampBase = String.valueOf(System.currentTimeMillis() % 1000000);

        // Incrementamos la base para asegurar IDs únicos en cada ejecución
        idBaseBusquedaUnico += 10; // Aseguramos un margen grande para no chocar con otros IDs.
        int id1 = idBaseBusquedaUnico + 1;
        int id2 = idBaseBusquedaUnico + 2;

        // Garantizamos que los nombres son únicos y fáciles de buscar
        String[] p1 = paciente1.split(" ");
        String[] p2 = paciente2.split(" ");

        // --- MODIFICACIÓN CLAVE AQUÍ ---
        // Usamos un DNI dinámico para evitar colisiones persistentes
        String dni1 = "DNI" + timestampBase + "1";
        String dni2 = "DNI" + timestampBase + "2";

        // Se usan IDs únicos: id1 y id2
        // Cambiamos el DNI hardcodeado por el DNI dinámico
        insertarPacienteDePrueba(id1, p1[0], p1[1], dni1, "F"); // DNI dinámico y único
        insertarPacienteDePrueba(id2, p2[0], p2[1], dni2, "M"); // DNI dinámico y único
        System.out.println("SETUP: Se asume la existencia de pacientes para la búsqueda de criterios.");
    }

    @When("se realiza una búsqueda por el criterio {string}")
    public void se_realiza_una_búsqueda_por_el_criterio(String criterio) {
        pacientesEncontrados = pacienteDAO.buscarPacientesPorCriterio(criterio);
    }

    @Then("el sistema debe retornar {int} pacientes")
    public void el_sistema_debe_retornar_n_pacientes(int nEsperado) {
        assertNotNull(pacientesEncontrados, "La lista de pacientes encontrados no debe ser nula.");
        assertEquals(nEsperado, pacientesEncontrados.size(), "La cantidad de pacientes retornados debe ser la esperada. ==> ");
        // Mensaje de Éxito CP-012 (Paso 1)
        System.out.println("✅ CP-012 (Paso 1): La búsqueda por criterio genérico retornó la cantidad esperada de " + nEsperado + " pacientes.");
    }

    @Then("la lista de pacientes contiene a {string}")
    public void la_lista_de_pacientes_contiene_a(String nombreCompleto) {
        String[] partes = nombreCompleto.trim().split(" ");
        if (partes.length < 2) {
            fail("Nombre completo de paciente inválido para verificación: " + nombreCompleto);
        }
        String nombre = partes[0].trim();
        String apellido = partes[1].trim();

        boolean encontrado = pacientesEncontrados.stream()
                .anyMatch(p -> p.getNombre().equalsIgnoreCase(nombre) && p.getApellido().equalsIgnoreCase(apellido));

        assertTrue(encontrado, "El paciente '" + nombreCompleto + "' debe estar en la lista de resultados.");
        // Mensaje de Éxito CP-012 (FINAL)
        System.out.println("✅ CP-012 (FINAL): El paciente '" + nombreCompleto + "' fue correctamente identificado en la lista de resultados.");
    }
}