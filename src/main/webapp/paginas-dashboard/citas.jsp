<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.ArrayList, java.util.stream.Collectors, java.time.format.DateTimeFormatter, java.time.temporal.ChronoUnit, java.time.LocalDate, java.time.LocalTime"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario, com.dental.app.clinicadentalapp.model.Cita, com.dental.app.clinicadentalapp.model.Paciente, com.dental.app.clinicadentalapp.model.Odontologo"%>
<%@page import="com.dental.app.clinicadentalapp.dao.CitaDAO, com.dental.app.clinicadentalapp.dao.PacienteDAO, com.dental.app.clinicadentalapp.dao.OdontologoDAO"%>

<%
    // Obtener el rol del usuario para decidir qué vista mostrar
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    String rol = (usuario != null && usuario.getRol() != null) ? usuario.getRol().getNombreRol() : "";
%>

<% if ("Paciente".equals(rol)) { %>
<%-- ============================================= --%>
<%-- ==   VISTA PARA EL ROL DE PACIENTE   == --%>
<%-- ============================================= --%>
<%
    // --- LÓGICA DE DATOS PARA LA VISTA DE CITAS DEL PACIENTE ---
    CitaDAO citaDAOPaciente = new CitaDAO();
    List<Cita> todasLasCitas = citaDAOPaciente.listarCitas();
    LocalDate hoy = LocalDate.now();

    // Filtrar citas del paciente logueado
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
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
%>
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
                                    <span>Medicina General</span>
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

<% } else { %>
<%-- =================================================================== --%>
<%-- ==   VISTA PARA ROLES DE ADMINISTRADOR Y RECEPCIONISTA  == --%>
<%-- =================================================================== --%>
<%
    CitaDAO citaDAO = new CitaDAO();
    PacienteDAO pacienteDAO = new PacienteDAO();
    OdontologoDAO odontoDAO = new OdontologoDAO();
    List<Cita> listaCitas = citaDAO.listarCitas();
    List<Paciente> listaPacientes = pacienteDAO.listarPacientes();
    List<Odontologo> listaOdontologos = odontoDAO.listarOdontologos();
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
    String registroStatus = request.getParameter("registro");
    String updateStatus = request.getParameter("update");
    String deleteStatus = request.getParameter("delete");
    LocalDate hoy = LocalDate.now();
%>
<header class="header">
    <h1>Gestión de Citas</h1>
    <div class="header-actions">
        <a href="../logout" title="Cerrar Sesión"><i class="fa-solid fa-right-from-bracket"></i></a>
        <a href="dashboard.jsp?page=configuracion" title="Configuración"><i class="fa-solid fa-cog"></i></a>
        <button id="agendarBtn" class="btn-primary"><i class="fa-solid fa-plus"></i> Agendar Nueva Cita</button>
    </div>
</header>

<% if ("exito".equals(registroStatus)) { %><div class="alert alert-success">¡Cita registrada exitosamente!</div><% } %>
<% if ("error".equals(registroStatus)) { %><div class="alert alert-danger">Error: No se pudo registrar la cita.</div><% } %>
<% if ("error_horario".equals(registroStatus)) { %><div class="alert alert-danger">Error: El horario seleccionado ya está ocupado.</div><% } %>
<% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Cita actualizada exitosamente!</div><% } %>
<% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar la cita.</div><% } %>
<% if ("exito".equals(deleteStatus)) { %><div class="alert alert-success">¡Cita eliminada exitosamente!</div><% } %>
<% if ("error".equals(deleteStatus)) { %><div class="alert alert-danger">Error: No se pudo eliminar la cita.</div><% } %>

<section class="content-card">
    <h3>Lista de Citas Programadas</h3>
    <table>
        <thead>
            <tr>
                <th>Paciente</th>
                <th>Odontólogo</th>
                <th>Fecha y Hora</th>
                <th>Tiempo Restante</th>
                <th>Estado</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <% if (listaCitas.isEmpty()) { %>
                <tr><td colspan="6" style="text-align: center;">No hay citas programadas.</td></tr>
            <% } else { %>
                <% for (Cita c : listaCitas) { 
                    long daysBetween = ChronoUnit.DAYS.between(hoy, c.getFechaCita());
                    String tiempoRestante = "";
                    String badgeColor = "";

                    if (daysBetween < 0) {
                        tiempoRestante = "Finalizada";
                        badgeColor = "gray";
                    } else if (daysBetween == 0) {
                        tiempoRestante = "Hoy";
                        badgeColor = "orange";
                    } else if (daysBetween == 1) {
                        tiempoRestante = "En 1 día";
                        badgeColor = "yellow";
                    } else if (daysBetween <= 7) {
                        tiempoRestante = "En " + daysBetween + " día(s)";
                        badgeColor = "yellow";
                    } else if (daysBetween <= 14){
                        tiempoRestante = "En 1 sem.";
                        badgeColor = "green";
                    } else {
                        long weeks = daysBetween / 7;
                        tiempoRestante = "En " + weeks + " sem.";
                        badgeColor = "green";
                    }
                %>
                    <tr>
                        <td><%= c.getPaciente().getNombreCompleto() %></td>
                        <td><%= c.getOdontologo().getNombreCompleto() %></td>
                        <td><%= c.getFechaCita().format(dateFormatter) %> a las <%= c.getHoraCita().format(timeFormatter) %></td>
                        <td><span class="badge badge-<%= badgeColor %>"><%= tiempoRestante %></span></td>
                        <td><span class="status-dot dot-green"></span><%= c.getEstado() %></td>
                        <td class="action-icons">
                            <a href="#" class="edit-btn" title="Editar" 
                               data-id="<%= c.getCitaId() %>"
                               data-paciente-id="<%= c.getPaciente().getPacienteId() %>"
                               data-odontologo-id="<%= c.getOdontologo().getOdontologoId() %>"
                               data-fecha="<%= c.getFechaCita() %>"
                               data-hora="<%= c.getHoraCita() %>"
                               data-motivo="<%= c.getMotivo() %>"
                               data-estado="<%= c.getEstado() %>">
                                <i class="fa-solid fa-pencil"></i>
                            </a>
                            <a href="#" class="delete-btn" title="Eliminar" data-id="<%= c.getCitaId() %>" data-paciente="<%= c.getPaciente().getNombreCompleto() %>">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                <% } %>
            <% } %>
        </tbody>
    </table>
</section>

<div id="citaModal" class="modal">
    <div class="modal-content">
        <span class="close-btn">&times;</span>
        <h2 id="modalTitle">Agendar Nueva Cita</h2>
        <form id="citaForm" action="../cita" method="post">
            <input type="hidden" name="action" id="formAction" value="agendar">
            <input type="hidden" name="citaId" id="editCitaId">

            <div class="form-grid-modal">
                <div class="form-group">
                    <label for="pacienteId">Paciente</label>
                    <select id="pacienteId" name="pacienteId" required>
                        <option value="" disabled selected>-- Seleccionar Paciente --</option>
                        <% for (Paciente p : listaPacientes) { %>
                            <option value="<%= p.getPacienteId() %>"><%= p.getNombreCompleto() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="odontologoId">Odontólogo</label>
                    <select id="odontologoId" name="odontologoId" required>
                        <option value="" disabled selected>-- Seleccionar Odontólogo --</option>
                        <% for (Odontologo o : listaOdontologos) { %>
                            <option value="<%= o.getOdontologoId() %>"><%= o.getNombreCompleto() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="fecha">Fecha</label>
                    <input type="date" id="fecha" name="fecha" required>
                </div>
                <div class="form-group">
                    <label for="hora">Hora</label>
                    <input type="time" id="hora" name="hora" required>
                </div>
                <div class="form-group full-width">
                    <label for="motivo">Motivo de la Cita</label>
                    <input type="text" id="motivo" name="motivo" placeholder="Ej: Limpieza, Consulta General, etc." required>
                </div>
                 <div class="form-group full-width" id="estadoContainer" style="display:none;">
                    <label for="estado">Estado</label>
                    <select id="estado" name="estado">
                        <option value="Programada">Programada</option>
                        <option value="Confirmada">Confirmada</option>
                        <option value="Cancelada">Cancelada</option>
                        <option value="Completada">Completada</option>
                    </select>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary cancel-btn">Cancelar</button>
                <button type="submit" class="btn-primary" id="modalSubmitBtn">Agendar Cita</button>
            </div>
        </form>
    </div>
</div>

<div id="deleteModal" class="modal">
    <div class="modal-content text-center">
        <span class="close-btn">&times;</span>
        <h2>Confirmar Eliminación</h2>
        <p>¿Estás seguro de que deseas eliminar la cita del paciente <strong id="deletePacienteNombre"></strong>?</p>
        <p>Esta acción no se puede deshacer.</p>
        <div class="modal-actions">
            <button id="cancelDeleteBtn" class="btn-secondary">Cancelar</button>
            <a id="confirmDeleteBtn" href="#" class="btn-danger">Eliminar</a>
        </div>
    </div>
</div>

<style>
    .badge {
        padding: 4px 8px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.75rem;
        color: #333;
    }
    .badge-gray { background-color: #e9ecef; }
    .badge-orange { background-color: #ffe8cc; color: #ff8c00; }
    .badge-yellow { background-color: #fff3cd; color: #ffc107; }
    .badge-green { background-color: #d4edda; color: #155724; }
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const citaModal = document.getElementById('citaModal');
    const deleteModal = document.getElementById('deleteModal');
    const agendarBtn = document.getElementById('agendarBtn');

    // --- Funciones para abrir y cerrar modales ---
    const openModal = (modal) => modal.classList.add('is-visible');
    const closeModal = (modal) => modal.classList.remove('is-visible');

    // --- Lógica para abrir modal de AGENDAR CITA ---
    agendarBtn.addEventListener('click', () => {
        document.getElementById('modalTitle').textContent = 'Agendar Nueva Cita';
        document.getElementById('citaForm').reset();
        document.getElementById('formAction').value = 'agendar';
        document.getElementById('editCitaId').value = '';
        document.getElementById('estadoContainer').style.display = 'none';
        document.getElementById('modalSubmitBtn').textContent = 'Agendar Cita';
        openModal(citaModal);
    });

    // --- Lógica para abrir modal de EDITAR CITA ---
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            document.getElementById('modalTitle').textContent = 'Editar Cita';
            document.getElementById('formAction').value = 'editar';
            document.getElementById('modalSubmitBtn').textContent = 'Guardar Cambios';

            // Poblar el formulario con los datos de la cita
            document.getElementById('editCitaId').value = this.dataset.id;
            document.getElementById('pacienteId').value = this.dataset.pacienteId;
            document.getElementById('odontologoId').value = this.dataset.odontologoId;
            document.getElementById('fecha').value = this.dataset.fecha;
            document.getElementById('hora').value = this.dataset.hora;
            document.getElementById('motivo').value = this.dataset.motivo;
            document.getElementById('estado').value = this.dataset.estado;
            document.getElementById('estadoContainer').style.display = 'block';

            openModal(citaModal);
        });
    });

    // --- Lógica para abrir modal de ELIMINAR CITA ---
    document.querySelectorAll('.delete-btn').forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const citaId = this.dataset.id;
            const pacienteNombre = this.dataset.paciente;
            document.getElementById('deletePacienteNombre').textContent = pacienteNombre;
            document.getElementById('confirmDeleteBtn').href = `../cita?action=eliminar&id=${citaId}`;
            openModal(deleteModal);
        });
    });

    // --- Lógica para cerrar todos los modales ---
    [citaModal, deleteModal].forEach(modal => {
        if (modal) {
            modal.querySelector('.close-btn').addEventListener('click', () => closeModal(modal));
            modal.addEventListener('click', (e) => {
                if (e.target === modal) closeModal(modal);
            });
             modal.querySelectorAll('.cancel-btn').forEach(btn => {
                btn.addEventListener('click', () => closeModal(modal));
            });
        }
    });
});
</script>
<% } %>