<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dental.app.clinicadentalapp.dao.OdontologoDAO"%>
<%@page import="com.dental.app.clinicadentalapp.model.Odontologo"%>

<%
    OdontologoDAO dao = new OdontologoDAO();
    List<Odontologo> listaOdontologos = dao.listarOdontologos();
    String registroStatus = request.getParameter("registro");
    String updateStatus = request.getParameter("update");
    String deleteStatus = request.getParameter("delete");
%>

<header class="header">
    <div class="search-bar"><i class="fa-solid fa-magnifying-glass"></i><input type="text" placeholder="Buscar por nombre, DNI o especialidad"></div>
    <div class="header-actions">
        <a href="../logout" title="Cerrar Sesión" style="margin-right: 15px; color: var(--danger-red);"><i class="fa-solid fa-right-from-bracket"></i></a>
        <%-- CAMBIO: El href="#" ahora es funcional --%>
        <a href="dashboard.jsp?page=configuracion" title="Configuración"><i class="fa-solid fa-cog"></i></a>
    </div>
</header>

<% if ("exito".equals(registroStatus)) { %><div class="alert alert-success">¡Odontólogo registrado exitosamente!</div><% } %>
<% if ("error".equals(registroStatus)) { %><div class="alert alert-danger">Error: No se pudo registrar al odontólogo.</div><% } %>
<% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Odontólogo actualizado exitosamente!</div><% } %>
<% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar al odontólogo.</div><% } %>
<% if ("exito".equals(deleteStatus)) { %><div class="alert alert-success">¡Odontólogo eliminado exitosamente!</div><% } %>
<% if ("error".equals(deleteStatus)) { %><div class="alert alert-danger">Error: No se pudo eliminar al odontólogo.</div><% } %>


<section class="content-card">
    <h3>Lista de Odontólogos</h3>
    <table>
        <thead>
            <tr><th>Nombre Completo</th><th>Email</th><th>Especialidad</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <% if (listaOdontologos.isEmpty()) { 
 %>
                <tr><td colspan="4" style="text-align: center;">No hay odontólogos registrados.</td></tr>
            <% } else { for (Odontologo o : listaOdontologos) { 
                    Odontologo oCompleto = dao.obtenerOdontologoPorId(o.getOdontologoId());
 %>
                    <tr>
                        <td><%= o.getNombreCompleto() %></td>
                        <td><%= o.getEmail() %></td>
                        <td><%= o.getEspecialidad() %></td>
  
                       <td class="action-icons">
                            <a href="#" class="view-btn" title="Ver Detalles"
                               data-nombre="<%= o.getNombreCompleto() %>"
            
                    data-email="<%= o.getEmail() %>"
                               data-especialidad="<%= o.getEspecialidad() %>"
                               data-telefono="<%= oCompleto.getTelefono() != null ? oCompleto.getTelefono() : "N/A" %>"
       
                         data-dni="<%= o.getUsuario().getDocumentoIdentidad() %>">
                               <i class="fa-solid fa-eye"></i></a>
                            <a href="#" class="edit-btn" title="Editar"
          
                      data-id="<%= o.getOdontologoId() %>"
                               data-nombre="<%= o.getNombre() %>"
                               data-apellido="<%= o.getApellido() %>"
           
                     data-email="<%= o.getEmail() %>"
                               data-especialidad="<%= o.getEspecialidad() %>"
                               data-telefono="<%= oCompleto.getTelefono() != null ?
oCompleto.getTelefono() : "" %>">
                               <i class="fa-solid fa-pencil"></i></a>
                            <a href="#" class="delete-btn" title="Eliminar"
                               data-id="<%= o.getOdontologoId() 
 %>"
                               data-nombre="<%= o.getNombreCompleto() %>">
                               <i class="fa-solid fa-trash"></i></a>
                        </td>
          
           </tr>
            <% }} %>
        </tbody>
    </table>
</section>

<section class="content-card">
    <h3>Registro rápido de Odontólogo</h3>
    <form action="../registroOdontologo" method="post" class="quick-register-form">
        <div class="form-grid-register">
            <%-- ✨ MEJORADO: Placeholders añadidos a los campos de registro --%>
            <div class="form-group"><label>DNI</label><input type="text" name="dni" placeholder="Ej: 12345678" 
 required maxlength="8" pattern="\d{8}"></div>
            <div class="form-group"><label>Nombre(s)</label><input type="text" name="nombre" placeholder="Ej: Carlos" required></div>
            <div class="form-group"><label>Apellido(s)</label><input type="text" name="apellido" placeholder="Ej: Rodriguez" required></div>
            <div class="form-group">
                <label>Especialidad</label>
                <select name="especialidad" required>
                    <option value="" disabled selected>-- Seleccionar --</option>
                    <option value="Dentista general">Dentista general</option>
                    <option value="Odontopediatra">Odontopediatra</option>
                    <option value="Ortodoncista">Ortodoncista</option>
                    <option value="Periodoncista">Periodoncista</option>
                    <option value="Endodoncista">Endodoncista</option>
                    <option value="Patólogo oral">Patólogo oral</option>
                    <option value="Prostodoncista">Prostodoncista</option>
                </select>
            </div>
            <div class="form-group">
                <label>Teléfono</label>
                <input type="text" name="telefono" placeholder="Ej: 987654321" 
                       pattern="\d{9}" maxlength="9" title="El teléfono debe contener 9 dígitos.">
            </div> 
            <div class="form-group"><label>Email</label><input type="email" name="email" placeholder="Ej: carlos.r@email.com" required></div>
         
           <div class="form-actions-register" style="grid-column: 3; justify-content: flex-end;"><button type="submit" class="btn-primary">Registrar</button></div>
        </div>
    </form>
</section>

<div id="viewModal" class="modal"><div class="modal-content"> <span class="close-btn">&times;</span><h2>Detalles del Odontólogo</h2> <table class="modal-table"><tr><td><strong>Nombre Completo:</strong></td><td id="viewNombre"></td></tr><tr><td><strong>DNI:</strong></td><td id="viewDni"></td></tr><tr><td><strong>Email:</strong></td><td id="viewEmail"></td></tr><tr><td><strong>Teléfono:</strong></td><td id="viewTelefono"></td></tr><tr><td><strong>Especialidad:</strong></td><td id="viewEspecialidad"></td></tr></table> </div></div>
<div id="editModal" class="modal"><div class="modal-content"> <span class="close-btn">&times;</span><h2>Editar Odontólogo</h2> <form id="editForm" action="../odontologo" method="post"><input type="hidden" name="id" id="editId"><div class="form-grid-modal"><div class="form-group"><label>Nombre:</label><input type="text" id="editNombre" name="nombre"></div><div class="form-group"><label>Apellido:</label><input type="text" id="editApellido" name="apellido"></div><div class="form-group"><label>Email:</label><input type="email" id="editEmail" name="email"></div><div class="form-group"><label>Teléfono:</label><input type="text" id="editTelefono" name="telefono"></div><div class="form-group full-width"><label>Especialidad:</label><input type="text" id="editEspecialidad" name="especialidad"></div></div><button type="submit" class="btn-primary">Guardar Cambios</button></form> </div></div>
<div id="deleteModal" class="modal"><div class="modal-content text-center"> <span class="close-btn">&times;</span><h2>Confirmar Eliminación</h2> <p>¿Seguro que deseas eliminar a <strong id="deleteNombre"></strong>?</p><div class="modal-actions"><button id="cancelDeleteBtn" class="btn-secondary">Cancelar</button><a id="confirmDeleteBtn" href="#" class="btn-danger">Eliminar</a></div></div></div>

<style>
   
     .alert{animation:fadeInOut 5s ease-in-out forwards}@keyframes fadeInOut{0%{opacity:0;transform:translateY(-20px)}10%{opacity:1;transform:translateY(0)}90%{opacity:1;transform:translateY(0)}100%{opacity:0;transform:translateY(-20px);visibility:hidden}}.alert-success{color:#155724;background-color:#d4edda;border-color:#c3e6cb}.alert-danger{color:#721c24;background-color:#f8d7da;border-color:#f5c6cb}.action-icons a{color:#888;text-decoration:none;margin:0 8px;font-size:1.2rem;transition:transform .2s ease,color .2s ease}.action-icons a:hover{transform:scale(1.25);color:var(--primary-blue)}.modal{display:flex;align-items:center;justify-content:center;position:fixed;z-index:1000;left:0;top:0;width:100%;height:100%;background-color:rgba(0,0,0,.5);opacity:0;visibility:hidden;transition:opacity .3s ease,visibility .3s ease}.modal.is-visible{opacity:1;visibility:visible}.modal-content{background-color:#fefefe;padding:25px;border-radius:12px;width:90%;max-width:600px;position:relative;transform:translateY(-20px);transition:transform .3s ease}.modal.is-visible .modal-content{transform:translateY(0)}.close-btn{color:#aaa;float:right;font-size:28px;font-weight:700;cursor:pointer}.modal-table{width:100%;border-collapse:collapse}.modal-table td{padding:8px;border-bottom:1px solid #ddd}.modal-table td:first-child{font-weight:600;width:30%}.form-grid-modal{display:grid;grid-template-columns:1fr 1fr;gap:15px;margin-bottom:20px}.form-grid-modal .form-group{display:flex;flex-direction:column}.form-grid-modal .form-group.full-width{grid-column:1 / -1}.form-grid-modal input{width:100%;padding:10px;border:1px solid #ccc;border-radius:4px}.text-center{text-align:center}.modal-actions{margin-top:20px;display:flex;justify-content:center;gap:15px}.btn-secondary,.btn-danger{display:inline-block;padding:10px 20px;border-radius:5px;text-decoration:none;color:#fff;border:none;cursor:pointer}.btn-secondary{background-color:#6c757d}.btn-danger{background-color:#dc3545}.quick-register-form .form-grid-register{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;align-items:flex-end}.quick-register-form .form-group label{margin-bottom:8px;font-weight:500}.quick-register-form .form-group input{padding:12px;border-radius:8px;border:1px solid var(--border-color);font-size:1rem}
</style>
<script>
document.addEventListener("DOMContentLoaded",function(){const t=document.querySelector(".alert");t&&setTimeout(()=>{t.remove()},5e3);const e=document.getElementById("viewModal"),o=document.getElementById("editModal"),n=document.getElementById("deleteModal"),a=[e,o,n];function d(t){t&&t.classList.remove("is-visible")}a.forEach(t=>{t&&(t.querySelector(".close-btn").addEventListener("click",()=>d(t)),t.addEventListener("click",e=>{e.target===t&&d(t)}))}),document.querySelectorAll(".view-btn").forEach(t=>{t.addEventListener("click",function(o){o.preventDefault(),document.getElementById("viewNombre").textContent=this.dataset.nombre,document.getElementById("viewDni").textContent=this.dataset.dni,document.getElementById("viewEmail").textContent=this.dataset.email,document.getElementById("viewTelefono").textContent=this.dataset.telefono,document.getElementById("viewEspecialidad").textContent=this.dataset.especialidad,e.classList.add("is-visible")})}),document.querySelectorAll(".edit-btn").forEach(t=>{t.addEventListener("click",function(e){e.preventDefault(),document.getElementById("editId").value=this.dataset.id,document.getElementById("editNombre").value=this.dataset.nombre,document.getElementById("editApellido").value=this.dataset.apellido,document.getElementById("editEmail").value=this.dataset.email,document.getElementById("editTelefono").value=this.dataset.telefono,document.getElementById("editEspecialidad").value=this.dataset.especialidad,o.classList.add("is-visible")})}),document.querySelectorAll(".delete-btn").forEach(t=>{t.addEventListener("click",function(e){e.preventDefault(),document.getElementById("deleteNombre").textContent=this.dataset.nombre;const o=this.dataset.id;document.getElementById("confirmDeleteBtn").href=`../odontologo?id=${o}`,n.classList.add("is-visible")})}),document.getElementById("cancelDeleteBtn").addEventListener("click",()=>d(n))});
</script>