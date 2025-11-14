<%-- 
    Document   : citas
    Created on : 5 nov. 2025, 11:55:00
    Author     : Matheus
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.stream.Collectors, java.time.format.DateTimeFormatter, java.time.LocalDate"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario, com.dental.app.clinicadentalapp.model.Cita"%>
<%@page import="com.dental.app.clinicadentalapp.CitaDAO"%>

<%
    // ==========================================================
    // ==     ESTA ES LA LÓGICA DE JAVA QUE FALTABA            ==
    // ==========================================================
    
    // 1. Obtener el usuario de la sesión
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"Paciente".equals(usuario.getRol().getNombreRol())) {
        response.sendRedirect("../index.jsp");
        return;
    }

    // 2. --- LÓGICA DE DATOS PARA LA VISTA DE CITAS DEL PACIENTE ---
    CitaDAO citaDAOPaciente = new CitaDAO();
    List<Cita> todasLasCitas = citaDAOPaciente.listarCitas();
    LocalDate hoy = LocalDate.now();

    // 3. Filtrar citas del paciente logueado
    List<Cita> misCitas = todasLasCitas.stream()
        .filter(c -> c.getPaciente().getUsuario().getDocumentoIdentidad().equals(usuario.getDocumentoIdentidad()))
        .collect(Collectors.toList());

    List<Cita> proximasCitas = misCitas.stream()
        .filter(c -> !c.getFechaCita().isBefore(hoy))
        .sorted((c1, c2) -> c1.getFechaCita().compareTo(c2.getFechaCita())) // Ordenar por fecha
        .collect(Collectors.toList());

    List<Cita> historialCitas = misCitas.stream()
        .filter(c -> c.getFechaCita().isBefore(hoy))
        .sorted((c1, c2) -> c2.getFechaCita().compareTo(c1.getFechaCita())) // Ordenar descendente
        .collect(Collectors.toList());

    // 4. Formateadores para la fecha y hora
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
%>

<%-- ============================================= --%>
<%-- ==   VISTA "TIMELINE" PARA EL PACIENTE       == --%>
<%-- ============================================= --%>
<div class="mis-citas-container">
    <div class="citas-header">
        <h1>Mis Citas</h1>
        <a href="#" class="btn-primary-citas">+ Agendar Nueva Cita</a>
    </div>

    <section class="citas-section">
        <h2>Próximas Citas</h2>
        <div class="timeline">
            <% if (proximasCitas.isEmpty()) { %>
                <p class="no-citas-msg">No tienes ninguna cita programada.</p>
            <% } else { %>
                <% for (Cita c : proximasCitas) { %>
                    <div class="timeline-item active">
                        <div class="timeline-point"></div>
                        <div class="timeline-card">
                            <div class="timeline-card-header">
                                <div class="fecha-box">
                                    <span class="dia"><%= c.getFechaCita().getDayOfMonth() %></span>
                                    <span class="mes-ano"><%= c.getFechaCita().format(DateTimeFormatter.ofPattern("MMM yyyy")).toUpperCase() %></span>
                                </div>
                                <div class="info-doctor">
                                    <strong>Dr(a). <%= c.getOdontologo().getNombreCompleto() %></strong>
                                    <span>Medicina General</span> <%-- O puedes usar c.getMotivo() --%>
                                </div>
                                <i class="fa-solid fa-chevron-down"></i>
                            </div>
                            <div class="timeline-card-body">
                                <span><i class="fa-regular fa-clock"></i> <%= c.getHoraCita().format(timeFormatter) %></span>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </section>

    <section class="citas-section">
        <h2>Historial</h2>
        <div class="timeline">
            <% if (historialCitas.isEmpty()) { %>
                 <p class="no-citas-msg">Aún no tienes un historial de citas.</p>
            <% } else { %>
                  <% for (Cita c : historialCitas) { %>
                    <div class="timeline-item">
                        <div class="timeline-point"></div>
                        <div class="timeline-card">
                             <div class="timeline-card-header">
                                <div class="fecha-box">
                                     <span class="dia"><%= c.getFechaCita().getDayOfMonth() %></span>
                                     <span class="mes-ano"><%= c.getFechaCita().format(DateTimeFormatter.ofPattern("MMM yyyy")).toUpperCase() %></span>
                                </div>
                                <div class="info-doctor">
                                     <strong>Dr(a). <%= c.getOdontologo().getNombreCompleto() %></strong>
                                    <span>Medicina General</span>
                                </div>
                            </div>
                        </div>
                    </div>
                 <% } %>
            <% } %>
        </div>
    </section>
</div>