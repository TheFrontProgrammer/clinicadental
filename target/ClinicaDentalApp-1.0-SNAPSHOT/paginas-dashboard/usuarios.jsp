<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dental.app.clinicadentalapp.dao.UsuarioDAO"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page import="com.dental.app.clinicadentalapp.model.Rol"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.dental.app.clinicadentalapp.util.ConexionDB"%>


<%
    UsuarioDAO usuarioDAO = new UsuarioDAO();
    List<Usuario> listaUsuarios = usuarioDAO.listarTodosUsuarios();
    List<Rol> listaRoles = usuarioDAO.listarRoles(); 
    String updateStatus = request.getParameter("update");
%>

<header class="header">
    <h1>Gestión de Usuarios del Sistema</h1>
    <div class="header-actions">
        <a href="../logout" title="Cerrar Sesión"><i class="fa-solid fa-right-from-bracket"></i></a>
        <a href="dashboard.jsp?page=configuracion" title="Configuración"><i class="fa-solid fa-cog"></i></a>
    </div>
</header>

<%-- Bloque para mostrar mensajes de estado --%>
<% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Usuario actualizado exitosamente!</div><% } %>
<% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar al usuario.</div><% } %>

<section class="content-card">
    <h3>Todos los Usuarios Registrados</h3>
    <table>
        <thead>
            <tr>
                <th>Documento (DNI)</th>
                <th>Rol Asignado</th>
                <th>Estado</th> <%-- CAMBIO: Texto más genérico --%>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <% if (listaUsuarios.isEmpty()) { %>
                <tr><td colspan="4" style="text-align: center;">No hay usuarios registrados.</td></tr>
            <% } else { %>
                <% 
                for (Usuario u : listaUsuarios) {
                    // Leer estado de bloqueo directamente aquí
                    boolean estaBloqueado = false;
                    try (Connection conn = ConexionDB.getConnection();
                         PreparedStatement pstmt = conn.prepareStatement("SELECT bloqueado FROM Usuarios WHERE usuario_id = ?")) {
                        pstmt.setInt(1, u.getUsuarioId());
                        ResultSet rs = pstmt.executeQuery();
                        if (rs.next()) {
                            estaBloqueado = rs.getBoolean("bloqueado");
                        }
                    } catch (Exception e) { e.printStackTrace(); } // Imprimir error si falla
                %>
                    <tr>
                        <td><%= u.getDocumentoIdentidad() %></td>
                        <td><%= u.getRol().getNombreRol() %></td>
                        <%-- CAMBIO: Indicador visual de estado --%>
                        <td>
                            <% if (estaBloqueado) { %>
                                <span class="status-dot dot-red"></span>
                                <span>Bloqueado</span>
                            <% } else { %>
                                <span class="status-dot dot-green"></span>
                                <span>Activo</span>
                            <% } %>
                        </td>
                        <td class="action-icons">
                             <%-- IDEA 3: Icono mejorado y tooltip --%>
                            <a href="#" class="edit-btn" title="Editar Rol / Estado"
                               data-usuario-id="<%= u.getUsuarioId() %>"
                               data-dni="<%= u.getDocumentoIdentidad() %>"
                               data-rol-id="<%= u.getRol().getRolId() %>"
                               data-bloqueado="<%= estaBloqueado %>"
                            >
                                <i class="fa-solid fa-user-pen"></i> <%-- Icono diferente --%>
                            </a>
                        </td>
                    </tr>
                <% } %>
            <% } %>
        </tbody>
    </table>
</section>

<div id="editModal" class="modal">
    <div class="modal-content">
        <button class="close-btn">&times;</button>
        <h2>Modificar Usuario</h2>
        <form id="editForm" action="../adminUsuario" method="post">
            <input type="hidden" name="usuarioId" id="editUsuarioId">
            
            <div class="form-grid-modal" style="grid-template-columns: 1fr;">
                <div class="form-group">
                    <label>Documento de Identidad (DNI)</label>
                    <input type="text" id="editDni" name="dni" readonly style="background-color: #eee; cursor: not-allowed;">
                </div>
                
                <div class="form-group">
                    <label for="editRolId">Rol del Usuario</label>
                    <select id="editRolId" name="rolId" required>
                        <% for (Rol r : listaRoles) { %>
                            <option value="<%= r.getRolId() %>"><%= r.getNombreRol() %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="editBloqueado">Estado del Usuario</label>
                    <select id="editBloqueado" name="bloqueado" required>
                        <option value="false">Activo</option>
                        <option value="true">Bloqueado</option>
                    </select>
                </div>
            </div>
             <div class="modal-actions">
                 <button type="button" class="btn-secondary cancel-btn">Cancelar</button>
                 <button type="submit" class="btn-primary">Guardar Cambios</button>
             </div>
        </form>
    </div>
</div>


<style>
    /* Estilos base ya están en dashboard-styles.css */
    /* Puedes añadir estilos específicos aquí si es necesario */
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const alertMessage = document.querySelector('.alert');
    if (alertMessage) {
        setTimeout(() => alertMessage.remove(), 5000);
    }

    const editModal = document.getElementById('editModal');
    if (!editModal) return;

    function closeModal(modal) {
        if(modal) modal.classList.remove('is-visible');
    }

     // Cerrar modal con botón y click fuera
     editModal.querySelectorAll('.close-btn, .cancel-btn').forEach(btn => {
         btn.addEventListener('click', () => closeModal(editModal));
     });
     editModal.addEventListener('click', (event) => {
         if (event.target === editModal) closeModal(editModal);
     });

    // Poblar modal al hacer clic en editar
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function (e) {
            e.preventDefault();
            document.getElementById('editUsuarioId').value = this.dataset.usuarioId;
            document.getElementById('editDni').value = this.dataset.dni;
            document.getElementById('editRolId').value = this.dataset.rolId;
            document.getElementById('editBloqueado').value = this.dataset.bloqueado; 
            
            editModal.classList.add('is-visible');
        });
    });
});
</script>