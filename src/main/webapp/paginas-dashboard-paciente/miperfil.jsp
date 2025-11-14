<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.dental.app.clinicadentalapp.model.Paciente"%>
<%@page import="com.dental.app.clinicadentalapp.dao.PacienteDAO"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Obtener el usuario de la sesión
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"Paciente".equals(usuario.getRol().getNombreRol())) {
        // Seguridad: Si no es paciente, no puede estar aquí
        response.sendRedirect("../index.jsp");
        return;
    }

    // 2. Cargar los datos completos del paciente
    PacienteDAO pDao = new PacienteDAO();
    String dniLogueado = usuario.getDocumentoIdentidad();
    List<Paciente> listaPacientes = pDao.listarPacientes();
    Paciente p = null; // El objeto Paciente completo

    for (Paciente pac : listaPacientes) {
        if (pac.getUsuario() != null && pac.getUsuario().getDocumentoIdentidad().equals(dniLogueado)) {
            // Obtenemos el objeto completo con todos los campos
            p = pDao.obtenerPacientePorId(pac.getPacienteId());
            break;
        }
    }
    
    if (p == null) {
        // Si por alguna razón no se encuentra (no debería pasar)
        out.println("Error al cargar los datos del paciente. Por favor, intente de nuevo.");
        return;
    }
    
    // 3. Formatear la fecha para el input (yyyy-MM-dd)
    String fechaNacStr = "";
    if (p.getFechaNacimiento() != null) {
        fechaNacStr = new SimpleDateFormat("yyyy-MM-dd").format(p.getFechaNacimiento());
    }
    
    // 4. Mensaje de éxito/error de la actualización
    String updateStatus = request.getParameter("update");
%>

<%-- Estilos CSS específicos para esta página, basados en tu imagen --%>
<style>
    .miperfil-container {
        display: grid;
        /* Columna izquierda más pequeña, derecha más grande */
        grid-template-columns: 1fr 2.5fr; 
        gap: 24px;
        max-width: 1100px;
    }
    
    /* Estilos para las tarjetas (izquierda y derecha) */
    .profile-card, .form-card {
        background-color: var(--patient-card-bg, #FFFFFF);
        border-radius: 16px;
        padding: 24px;
        box-shadow: var(--patient-shadow, 0 4px 12px rgba(0,0,0,0.05));
    }
    
    /* --- Columna Izquierda (Tarjeta de Perfil) --- */
    .profile-card {
        text-align: center;
        padding-top: 40px;
    }
    
    /* Requisito 3: Sin foto, solo icono */
    .profile-card .profile-icon {
        font-size: 80px;
        color: var(--patient-primary-blue, #4F63D7);
        line-height: 1;
        margin-bottom: 16px;
    }
    .profile-card h3 {
        font-size: 1.25rem;
        font-weight: 600;
        color: var(--patient-dark-text, #2D3748);
        margin: 0;
    }
    /* Requisito 3: Email más pequeño */
    .profile-card .email-text {
        font-size: 0.9rem;
        color: var(--patient-light-text, #A0AEC0);
        margin-bottom: 24px;
    }
    .profile-card hr {
        border: 0;
        height: 1px;
        background-color: var(--patient-border-color, #E2E8F0);
        margin: 24px 0;
    }
    /* Botón de cambiar contraseña */
    .btn-secondary { 
        display: inline-block;
        width: 100%;
        text-align: center;
        padding: 12px;
        border-radius: 8px;
        border: 1px solid var(--patient-border-color, #E2E8F0);
        background-color: var(--patient-bg, #F5F7FA);
        color: var(--patient-dark-text, #2D3748);
        text-decoration: none;
        font-weight: 500;
        transition: background-color 0.2s;
    }
    .btn-secondary:hover {
        background-color: #e9eef5;
    }

    /* --- Columna Derecha (Formulario) --- */
    .form-card h3 {
        font-size: 1.5rem;
        font-weight: 600;
        color: var(--patient-dark-text, #2D3748);
        margin-top: 0;
    }
    .form-card h4 {
        font-size: 0.95rem;
        color: var(--patient-light-text, #A0AEC0);
        font-weight: 400;
        margin-top: -8px;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--patient-border-color, #E2E8F0);
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }
    .form-group {
        display: flex;
        flex-direction: column;
    }
    .form-group.full-width {
        grid-column: 1 / -1;
    }
    .form-group label {
        font-size: 0.85rem;
        font-weight: 500;
        color: var(--patient-light-text, #A0AEC0);
        margin-bottom: 6px;
    }
    .form-group input[type="text"],
    .form-group input[type="email"],
    .form-group input[type="tel"],
    .form-group input[type="date"],
    .form-group select {
        width: 100%;
        padding: 12px;
        border: 1px solid var(--patient-border-color, #E2E8F0);
        border-radius: 8px;
        font-size: 0.95rem;
        font-family: 'Poppins', sans-serif;
    }
    
    /* Requisito 2: DNI no editable */
    .form-group input[readonly] {
        background-color: #f8f9fa;
        cursor: not-allowed;
    }
    
    .form-actions {
        display: flex;
        justify-content: flex-end;
        margin-top: 24px;
    }
    .btn-primary {
        background-color: var(--patient-primary-blue, #4F63D7);
        color: white;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .btn-primary:hover {
        background-color: #3C50B2;
    }
    
    /* Alertas de éxito/error */
    .alert { padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 8px; font-weight: 500; font-size: 0.9rem; }
    .alert-success { color: #0f5132; background-color: #d1e7dd; border-color: #badbcc; }
    .alert-danger { color: #842029; background-color: #f8d7da; border-color: #f5c2c7; }
</style>

<div class="miperfil-container">

    <div class="profile-card">
        <%-- Requisito 3: Cumplido (Icono, Nombre, Email) --%>
        <div class="profile-icon">
            <i class="fa-solid fa-user-circle"></i>
        </div>
        <h3><%= p.getNombreCompleto() %></h3>
        <p class="email-text"><%= p.getEmail() %></p>
        
        <hr>
        
        <%-- Requisito: Botón a configuracion.jsp --%>
        <a href="dashboard.jsp?page=configuracion" class="btn-secondary">
            <i class="fa-solid fa-lock"></i> Cambiar Contraseña
        </a>
    </div>

    <div class="form-card">
        <h3>Información Personal</h3>
        <h4>Mantén tus datos actualizados para una mejor atención.</h4>

        <%-- Mensajes de éxito/error (para cuando se presione "Guardar Cambios") --%>
        <% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Perfil actualizado exitosamente!</div><% } %>
        <% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar tu perfil.</div><% } %>

        <%-- El 'action' apunta al PacienteController --%>
        <form action="../paciente" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="pacienteId" value="<%= p.getPacienteId() %>">
            <input type="hidden" name="source" value="miperfil">
            
            <div class="form-grid">
                <%-- Requisito 1: Nombre (Editable) --%>
                <div class="form-group">
                    <label for="nombre">Nombres</label>
                    <input type="text" id="nombre" name="nombre" value="<%= p.getNombre() %>" required>
                </div>
                
                <%-- Requisito 1: Apellido (Editable) --%>
                <div class="form-group">
                    <label for="apellido">Apellidos</label>
                    <input type="text" id="apellido" name="apellido" value="<%= p.getApellido() %>" required>
                </div>

                <%-- Requisito 2: DNI (No editable) --%>
                <div class="form-group">
                    <label for="dni">DNI*</label>
                    <input type="text" id="dni" name="dni" value="<%= usuario.getDocumentoIdentidad() %>" readonly>
                </div>

                <div class="form-group">
                    <label for="telefono">Teléfono*</label>
                    <input type="tel" id="telefono" name="telefono" value="<%= p.getTelefono() != null ? p.getTelefono() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="fechaNacimiento">Fecha de Nacimiento*</label>
                    <input type="date" id="fechaNacimiento" name="fechaNacimiento" value="<%= fechaNacStr %>" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Correo Electrónico*</label>
                    <input type="email" id="email" name="email" value="<%= p.getEmail() != null ? p.getEmail() : "" %>" required>
                </div>

                <div class="form-group full-width">
                    <label for="direccion">Dirección</label>
                    <input type="text" id="direccion" name="direccion" value="<%= p.getDireccion() != null ? p.getDireccion() : "" %>">
                </div>
                
                <%-- Campos adicionales del modelo Paciente (opcionales pero recomendados) --%>
                <div class="form-group">
                    <label for="genero">Género</label>
                    <select id="genero" name="genero">
                        <option value="M" <%= "M".equals(p.getGenero()) ? "selected" : "" %>>Masculino</option>
                        <option value="F" <%= "F".equals(p.getGenero()) ? "selected" : "" %>>Femenino</option>
                        <option value="O" <%= "O".equals(p.getGenero()) ? "selected" : "" %>>Otro</option>
                        <option value="" <%= (p.getGenero() == null || p.getGenero().isEmpty()) ? "selected" : "" %>>No especificar</option>
                    </select>
                </div>
                 <div class="form-group">
                    <label for="alergias">Alergias (Opcional)</label>
                    <input type="text" id="alergias" name="alergias" value="<%= p.getAlergias() != null ? p.getAlergias() : "" %>">
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn-primary">Guardar Cambios</button>
            </div>
        </form>
    </div>

</div>