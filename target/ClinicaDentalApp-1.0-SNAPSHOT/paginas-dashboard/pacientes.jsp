<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dental.app.clinicadentalapp.dao.PacienteDAO"%>
<%@page import="com.dental.app.clinicadentalapp.model.Paciente"%>
<%@page import="java.text.SimpleDateFormat"%>

<%
    PacienteDAO pacienteDAO = new PacienteDAO();
    List<Paciente> listaPacientes = pacienteDAO.listarPacientes();
    String registroStatus = request.getParameter("registro");
    String updateStatus = request.getParameter("update");
    String deleteStatus = request.getParameter("delete");
%>

<header class="header">
    <div class="search-bar">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" id="searchInput" placeholder="Buscar pacientes por cédula, nombre o apellido">
    </div>
    <div class="header-actions">
        <a href="../logout" title="Cerrar Sesión" style="margin-right: 15px; color: var(--danger-red);"><i class="fa-solid fa-right-from-bracket"></i></a>
        <a href="dashboard.jsp?page=configuracion" title="Configuración"><i class="fa-solid fa-cog"></i></a>
    </div>
</header>

<% if ("exito".equals(registroStatus)) { %><div class="alert alert-success">¡Paciente registrado exitosamente!</div><% } %>
<% if ("error".equals(registroStatus)) { %><div class="alert alert-danger">Error: No se pudo registrar al paciente.</div><% } %>
<% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Paciente actualizado exitosamente!</div><% } %>
<% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar al paciente.</div><% } %>
<% if ("exito".equals(deleteStatus)) { %><div class="alert alert-success">¡Paciente eliminado exitosamente!</div><% } %>
<% if ("error".equals(deleteStatus)) { %><div class="alert alert-danger">Error: No se pudo eliminar al paciente.</div><% } %>

<section class="content-card">
    <h3>Lista de Pacientes Activos</h3>
    <table>
        <thead>
             <tr>
                <th>Nombre completo</th>
                <th>Documento</th>
                <th>Email</th>
                <th>Teléfono</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody id="pacientesTableBody"> 
            <% if (listaPacientes.isEmpty()) { %>
                <tr><td colspan="5" style="text-align: center;">No hay pacientes registrados.</td></tr>
            <% } else { %>
                <% for (Paciente p : listaPacientes) { 
                    Paciente pCompleto = pacienteDAO.obtenerPacientePorId(p.getPacienteId());
                    String fechaNacStr = (pCompleto.getFechaNacimiento() != null) ? new SimpleDateFormat("yyyy-MM-dd").format(pCompleto.getFechaNacimiento()) : "";
                %>
                    <tr>
                        <td><%= p.getNombreCompleto() %></td>
                        <td><%= p.getUsuario().getDocumentoIdentidad() %></td>
                        <td><%= p.getEmail() %></td>
                        <td><%= (pCompleto.getTelefono() != null ? pCompleto.getTelefono() : "N/A") %></td>
                        <td class="action-icons">
                            <a href="#" class="view-btn" title="Ver Detalles" data-nombre="<%= pCompleto.getNombreCompleto() %>" data-documento="<%= pCompleto.getUsuario().getDocumentoIdentidad() %>" data-email="<%= pCompleto.getEmail() %>" data-telefono="<%= (pCompleto.getTelefono() != null ? pCompleto.getTelefono() : "") %>" data-direccion="<%= (pCompleto.getDireccion() != null ? pCompleto.getDireccion() : "") %>" data-alergias="<%= (pCompleto.getAlergias() != null ? pCompleto.getAlergias() : "") %>" data-genero="<%= (pCompleto.getGenero() != null ? pCompleto.getGenero() : "") %>" data-nacimiento="<%= fechaNacStr %>"><i class="fa-solid fa-eye"></i></a>
                            <a href="#" class="edit-btn" title="Editar" data-id="<%= pCompleto.getPacienteId() %>" data-nombre="<%= pCompleto.getNombre() %>" data-apellido="<%= pCompleto.getApellido() %>" data-email="<%= pCompleto.getEmail() %>" data-telefono="<%= (pCompleto.getTelefono() != null ? pCompleto.getTelefono() : "") %>" data-direccion="<%= (pCompleto.getDireccion() != null ? pCompleto.getDireccion() : "") %>" data-alergias="<%= (pCompleto.getAlergias() != null ? pCompleto.getAlergias() : "") %>" data-genero="<%= (pCompleto.getGenero() != null ? pCompleto.getGenero() : "") %>" data-nacimiento="<%= fechaNacStr %>"><i class="fa-solid fa-pencil"></i></a>
                            <a href="#" class="delete-btn" title="Eliminar" data-id="<%= p.getPacienteId() %>" data-nombre="<%= p.getNombreCompleto() %>"><i class="fa-solid fa-trash"></i></a>
                        </td>
                   </tr>
                <% } %>
            <% } %>
        </tbody>
    </table>
</section>

<section class="content-card">
    <h3>Registro de Paciente</h3>
    <form action="../registroPaciente" method="post" class="quick-register-form">
        <div class="form-grid-register" style="grid-template-columns: 1fr 1fr 1fr; gap: 20px;">
            <div class="form-group">
               <label for="doc">Número de Documento *</label>
                <input type="text" id="doc" name="documento" placeholder="Ej: 70022045" required maxlength="8" pattern="\d{8}" title="El DNI debe contener 8 dígitos.">
            </div>
            <div class="form-group">
                <label for="nombre">Nombre(s) *</label>
               <input type="text" id="nombre" name="nombre" placeholder="Ej: Juan" required>
            </div>
            <div class="form-group">
                <label for="apellido">Apellido(s) *</label>
                <input type="text" id="apellido" name="apellido" placeholder="Ej: Perez" required>
            </div>
            <div class="form-group">
                <label for="fechaNacimiento">Fecha de Nacimiento</label>
                <input type="date" id="fechaNacimiento" name="fechaNacimiento">
            </div>
            <div class="form-group">
                <label for="genero">Género *</label>
                 <select id="genero" name="genero" required>
                    <option value="" disabled selected>-- Seleccionar --</option>
                    <option value="M">Masculino</option>
                    <option value="F">Femenino</option>
                    <option value="O">Otro</option>
               </select>
            </div>
            <div class="form-group">
                <label for="telefono">Teléfono</label>
                <input type="text" id="telefono" name="telefono" placeholder="Ej: 987654321">
            </div>
             <div class="form-group">
                <label for="email">Correo Electrónico *</label>
                <input type="email" id="email" name="email" placeholder="Ej: juan.perez@example.com" required>
            </div>
            <div class="form-group" style="grid-column: 2 / 4;">
                <label for="direccion">Dirección</label>
                <input type="text" id="direccion" name="direccion" placeholder="Ej: Av. Principal 123, Lima">
            </div>
            <div class="form-actions-register" style="grid-column: 3; justify-content: flex-end;">
                <button type="submit" class="btn-primary">Registrar Paciente</button>
            </div>
        </div>
    </form>
</section>

<div id="viewModal" class="modal">
    <div class="modal-content">
        <span class="close-btn">&times;</span>
        <h2>Detalles del Paciente</h2>
        <table class="modal-table">
            
 <tr><td><strong>Nombre Completo:</strong></td><td id="viewNombre"></td></tr>
            <tr><td><strong>Documento:</strong></td><td id="viewDocumento"></td></tr>
            <tr><td><strong>Email:</strong></td><td id="viewEmail"></td></tr>
            <tr><td><strong>Teléfono:</strong></td><td id="viewTelefono"></td></tr>
            <tr><td><strong>Fecha de Nacimiento:</strong></td><td id="viewNacimiento"></td></tr>
            <tr><td><strong>Género:</strong></td><td id="viewGenero"></td></tr>
            <tr><td><strong>Dirección:</strong></td><td id="viewDireccion"></td></tr>
            <tr><td><strong>Alergias:</strong></td><td id="viewAlergias"></td></tr>
     
        </table>
    </div>
</div>

<div id="editModal" class="modal">
    <div class="modal-content">
        <span class="close-btn">&times;</span>
        <h2>Editar Paciente</h2>
        <form id="editForm" action="../paciente" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="editPacienteId" name="pacienteId">
            <div class="form-grid-modal">
              
               <div class="form-group"><label>Nombre:</label><input type="text" id="editNombre" name="nombre"></div>
                <div class="form-group"><label>Apellido:</label><input type="text" id="editApellido" name="apellido"></div>
                <div class="form-group"><label>Email:</label><input type="email" id="editEmail" name="email"></div>
                <div class="form-group">
                    <label for="telefono">Teléfono</label>
                    <input type="text" id="telefono" name="telefono" placeholder="Ej: 987654321" 
                           pattern="\d{9}" maxlength="9" title="El teléfono debe contener 9 dígitos.">
                </div>  
                <div class="form-group"><label>Fecha Nacimiento:</label><input type="date" id="editNacimiento" name="fechaNacimiento"></div>
             
               <div class="form-group">
                    <label>Género:</label>
                    <select id="editGenero" name="genero">
                        <option value="">-- Seleccionar --</option>
                        <option value="M">Masculino</option>
  
                       <option value="F">Femenino</option>
                        <option value="O">Otro</option>
                    </select>
                </div>
                
 <div class="form-group full-width"><label>Dirección:</label><input type="text" id="editDireccion" name="direccion"></div>
                <div class="form-group full-width"><label>Alergias:</label><textarea id="editAlergias" name="alergias"></textarea></div>
            </div>
            <button type="button" id="saveChangesBtn" class="btn-primary">Guardar Cambios</button>
        </form>
    </div>
</div>

<div id="deleteModal" class="modal">
    <div class="modal-content text-center">
        <span class="close-btn">&times;</span>
        <h2>Confirmar Eliminación</h2>
        <p>¿Estás 
 seguro de que deseas eliminar al paciente <strong id="deleteNombre"></strong>?</p>
        <p>Esta acción no se puede deshacer.</p>
        <div class="modal-actions">
            <button id="cancelDeleteBtn" class="btn-secondary">Cancelar</button>
            <a id="confirmDeleteBtn" href="#" class="btn-danger">Eliminar</a>
        </div>
    </div>
</div>

<style>
    .alert {
        padding: 15px;
 margin-bottom: 20px;
        border: 1px solid transparent;
        border-radius: 4px;
        animation: fadeInOut 5s ease-in-out forwards;
 }
    @keyframes fadeInOut {
        0% { opacity: 0; transform: translateY(-20px);
 }
        10% { opacity: 1; transform: translateY(0);
 }
        90% { opacity: 1; transform: translateY(0);
 }
        100% { opacity: 0; transform: translateY(-20px); visibility: hidden;
 }
    }
    .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb;
 }
    .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb;
 }

    .action-icons a {
        color: #888;
        text-decoration: none;
 margin: 0 8px;
        font-size: 1.2rem;
        transition: transform 0.2s ease, color 0.2s ease;
 }
    .action-icons a:hover {
        transform: scale(1.25);
        color: var(--primary-blue);
 }

    .modal {
        display: flex;
        align-items: center;
        justify-content: center;
 position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        opacity: 0;
        visibility: hidden;
 transition: opacity 0.3s ease, visibility 0.3s ease;
    }
    .modal.is-visible {
        opacity: 1;
 visibility: visible;
    }
    .modal-content {
        background-color: #fefefe;
        padding: 25px;
 border-radius: 12px;
        width: 90%;
        max-width: 600px;
        position: relative;
        transform: translateY(-20px);
        transition: transform 0.3s ease;
 }
    .modal.is-visible .modal-content {
        transform: translateY(0);
 }
    .close-btn { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer;
 }
    .modal-table { width: 100%; border-collapse: collapse; }
    .modal-table td { padding: 8px;
 border-bottom: 1px solid #ddd; }
    .modal-table td:first-child { font-weight: 600; width: 30%;
 }
    .form-grid-modal { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px;
 }
    .form-grid-modal .form-group { display: flex; flex-direction: column;
 }
    .form-grid-modal .form-group.full-width { grid-column: 1 / -1;
 }
    .form-grid-modal input, .form-grid-modal select, .form-grid-modal textarea { width: 100%; padding: 10px; border: 1px solid #ccc;
 border-radius: 4px; }
    .form-grid-modal textarea { min-height: 80px; }
    .text-center { text-align: center;
 }
    .modal-actions { margin-top: 20px; display: flex; justify-content: center; gap: 15px;
 }
    .btn-secondary, .btn-danger { display: inline-block; padding: 10px 20px; border-radius: 5px; text-decoration: none; color: white; border: none;
 cursor: pointer; }
    .btn-secondary { background-color: #6c757d; }
    .btn-danger { background-color: #dc3545;
 }
    .quick-register-form .form-grid-register { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; align-items: flex-end;
 }
    .quick-register-form .form-group { display: flex; flex-direction: column;
 }
    .quick-register-form .form-group label { margin-bottom: 8px; font-weight: 500;
 }
    .quick-register-form .form-group input, .quick-register-form .form-group select { padding: 12px; border-radius: 8px; border: 1px solid var(--border-color);
 font-size: 1rem; }
    .quick-register-form .form-actions-register { grid-column: 3; display: flex; justify-content: space-between; align-items: center;
 }
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    // --- CÓDIGO EXISTENTE PARA ALERTAS Y MODALES ---
    const alertMessage = document.querySelector('.alert');
    if (alertMessage) {
        setTimeout(() => {
            alertMessage.remove();
        }, 5000);
    }

    const viewModal = document.getElementById('viewModal');
    const editModal = document.getElementById('editModal');
    const deleteModal = document.getElementById('deleteModal');
    const modals = [viewModal, editModal, deleteModal];

    function closeModal(modal) {
        if(modal) modal.classList.remove('is-visible');
    
 }

    modals.forEach(modal => {
        if (modal) {
            modal.querySelector('.close-btn').addEventListener('click', () => closeModal(modal));
            modal.addEventListener('click', (event) => {
                if (event.target === modal) {
                    closeModal(modal);
              
   }
            });
        }
    });

    document.querySelectorAll('.view-btn').forEach(button => {
        button.addEventListener('click', function (e) {
            e.preventDefault();
 document.getElementById('viewNombre').textContent = this.dataset.nombre;
            document.getElementById('viewDocumento').textContent = this.dataset.documento;
            document.getElementById('viewEmail').textContent = this.dataset.email;
            document.getElementById('viewTelefono').textContent = this.dataset.telefono || 'N/A';
            document.getElementById('viewNacimiento').textContent = this.dataset.nacimiento || 'N/A';
 document.getElementById('viewGenero').textContent = this.dataset.genero || 'No especificado';
            document.getElementById('viewDireccion').textContent = this.dataset.direccion || 'N/A';
            document.getElementById('viewAlergias').textContent = this.dataset.alergias || 'Ninguna';
            viewModal.classList.add('is-visible');
        });
    });
 const editForm = document.getElementById('editForm');
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function (e) {
            e.preventDefault();
            document.getElementById('editPacienteId').value = this.dataset.id;
            document.getElementById('editNombre').value = this.dataset.nombre;
            document.getElementById('editApellido').value = this.dataset.apellido;
            document.getElementById('editEmail').value = this.dataset.email;
            document.getElementById('editTelefono').value = this.dataset.telefono;
 
            document.getElementById('editNacimiento').value = this.dataset.nacimiento;
            document.getElementById('editGenero').value = this.dataset.genero;
            document.getElementById('editDireccion').value = this.dataset.direccion;
            document.getElementById('editAlergias').value = this.dataset.alergias;
            editModal.classList.add('is-visible');
        });
    });
 document.getElementById('saveChangesBtn').addEventListener('click', function() {
        if (confirm('¿Estás seguro de que deseas guardar los cambios?')) {
            editForm.submit();
        }
    });
 document.querySelectorAll('.delete-btn').forEach(button => {
        button.addEventListener('click', function (e) {
            e.preventDefault();
            document.getElementById('deleteNombre').textContent = this.dataset.nombre;
            const patientId = this.dataset.id;
            document.getElementById('confirmDeleteBtn').href = `../paciente?action=delete&id=${patientId}`;
            deleteModal.classList.add('is-visible');
        });
    });
 document.getElementById('cancelDeleteBtn').addEventListener('click', () => closeModal(deleteModal));
    
    // --- SCRIPT PARA BÚSQUEDA ---
    
    const searchInput = document.getElementById('searchInput');
    const tableBody = document.getElementById('pacientesTableBody');
    const rows = tableBody.getElementsByTagName('tr');

    searchInput.addEventListener('keyup', function() {
        const filter = searchInput.value.toLowerCase();
        
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            
            const nombreCompleto = row.cells[0].textContent.toLowerCase();
            const documento = row.cells[1].textContent.toLowerCase();
            
            if (nombreCompleto.includes(filter) || documento.includes(filter)) {
                row.style.display = ""; 
            } else {
                row.style.display = "none"; 
            }
        }
    });
});
</script>