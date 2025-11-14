<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Lógica para obtener el rol y la página a incluir
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("../index.jsp");
        return;
    }
    
    String rol = usuario.getRol().getNombreRol();
    
    // =================================================================
    // ==   CAMBIO: Si es Paciente, redirigir a su propio dashboard   ==
    // =================================================================
    if ("Paciente".equals(rol)) {
        // getContextPath() es más seguro que usar "../"
        response.sendRedirect(request.getContextPath() + "/paciente-dashboard/dashboard.jsp");
        return;
    }
    // =================================================================

    String pageToInclude = request.getParameter("page");
    if (pageToInclude == null || pageToInclude.trim().isEmpty()) {
        pageToInclude = "inicio";
    }
    
    // Lógica de permisos (Solo para roles Admin/Staff)
    boolean tienePermiso = false;
    switch (pageToInclude) {
        case "inicio":
        case "citas":
        case "configuracion":
            tienePermiso = true;
            break;
        case "pacientes":
            if (rol.equals("Administrador") || rol.equals("Recepcionista")) {
                tienePermiso = true;
            }
            break;
        case "odontologos":
        case "usuarios": 
            if (rol.equals("Administrador")) {
                tienePermiso = true;
            }
            break;
    }
    if (!tienePermiso) {
        pageToInclude = "inicio";
    }
    
    // Esta ruta siempre apunta a las páginas de admin/compartidas
    String contentPage = "../paginas-dashboard/" + pageToInclude + ".jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Administración</title>

    <%-- Carga de CSS (Solo el de Admin) --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dashboard/dashboard-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <%-- Se eliminó el IF/ELSE de Paciente, solo queda la vista de Admin --%>
    <aside class="sidebar">
         <div class="sidebar-header">
            <img src="https://i.imgur.com/Oz512AH.png" alt="Logo Sonrisa Plena" class="logo-icon">
            <h2>SONRISA PLENA</h2>
        </div>
         <nav class="sidebar-nav">
           <ul>
               <li class="<%= "inicio".equals(pageToInclude) ? "active" : "" %>"><a href="dashboard.jsp?page=inicio"><i class="fa-solid fa-chart-pie"></i> inicio</a></li>
               <% if (rol.equals("Administrador") || rol.equals("Recepcionista")) { %>
                   <li class="<%= "pacientes".equals(pageToInclude) ? "active" : "" %>"><a href="dashboard.jsp?page=pacientes"><i class="fa-solid fa-hospital-user"></i> Pacientes</a></li>
               <% } %>
               <li class="<%= "citas".equals(pageToInclude) ? "active" : "" %>"><a href="dashboard.jsp?page=citas"><i class="fa-solid fa-calendar-days"></i> Citas</a></li>
               <% if (rol.equals("Administrador")) { %>
                   <li class="<%= "odontologos".equals(pageToInclude) ? "active" : "" %>"><a href="dashboard.jsp?page=odontologos"><i class="fa-solid fa-user-doctor"></i> Odontólogos</a></li>
                   <li class="<%= "usuarios".equals(pageToInclude) ? "active" : "" %>"><a href="dashboard.jsp?page=usuarios"><i class="fa-solid fa-users-cog"></i> Usuarios</a></li>
               <% } %>
           </ul>
        </nav>
    </aside>

    <main class="main-content">
        <jsp:include page="<%= contentPage %>" />
    </main>

    <%-- ========================================================== --%>
    <%-- ==     AQUÍ ESTÁ EL MODAL DE BIENVENIDA PARA ADMIN      == --%>
    <%-- ========================================================== --%>
    <%
        String loginStatus = request.getParameter("login");
        if ("success".equals(loginStatus)) {
    %>
        <%-- CSS para el modal de bienvenida (puedes moverlo a dashboard-styles.css si prefieres) --%>
        <style>
            .welcome-modal {
                display: none; align-items: center; justify-content: center;
                position: fixed; z-index: 2000; left: 0; top: 0;
                width: 100%; height: 100%;
                background-color: rgba(0,0,0,0.6);
                opacity: 0; visibility: hidden;
                transition: opacity 0.3s ease, visibility 0.3s ease;
            }
            .welcome-modal.is-visible { display: flex; opacity: 1; visibility: visible; }
            .welcome-modal-content {
                background-color: #fefefe; padding: 30px 35px; border-radius: 12px;
                width: 90%; max-width: 450px; position: relative;
                transform: translateY(-20px) scale(0.95);
                transition: transform 0.3s ease, opacity 0.3s ease;
                opacity: 0; box-shadow: 0 10px 30px rgba(0,0,0,0.15);
                text-align: center;
            }
            .welcome-modal.is-visible .welcome-modal-content { transform: translateY(0) scale(1); opacity: 1; }
            .welcome-modal-icon { font-size: 3rem; color: var(--primary-blue); margin-bottom: 15px; }
            .welcome-modal-content h2 { font-size: 1.5rem; color: var(--dark-blue-text); margin: 0 0 10px 0; }
            .welcome-modal-content p { font-size: 1rem; color: var(--text-color); margin-bottom: 25px; }
        </style>
    
        <div id="welcomeModal" class="welcome-modal">
             <div class="welcome-modal-content">
                 <div class="welcome-modal-icon">
                     <i class="fa-solid fa-hands-clapping"></i>
                 </div>
                 <h2>¡Bienvenido(a)!</h2>
                 <p>Te damos la bienvenida al Portal de Administración.</p>
                 <button id="closeWelcomeModal" class="btn-primary">Entendido</button>
             </div>
        </div>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const modal = document.getElementById('welcomeModal');
                const closeBtn = document.getElementById('closeWelcomeModal');
                if (modal) {
                    const closeModal = () => modal.classList.remove('is-visible');
                    setTimeout(() => modal.classList.add('is-visible'), 300);
                    closeBtn.addEventListener('click', closeModal);
                    modal.addEventListener('click', (e) => {
                        if (e.target === modal) closeModal();
                    });
                }
            });
        </script>
    <% } %>
    
</body>
</html>