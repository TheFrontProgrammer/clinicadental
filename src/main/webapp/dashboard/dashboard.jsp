<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Lógica para obtener el rol y la página a incluir (sin cambios)
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("../index.jsp");
        return;
    }
    String rol = usuario.getRol().getNombreRol();
    String pageToInclude = request.getParameter("page");
    if (pageToInclude == null || pageToInclude.trim().isEmpty()) {
        pageToInclude = "inicio";
    }
    // Lógica de permisos (sin cambios)
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
    String contentPage = "../paginas-dashboard/" + pageToInclude + ".jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Clínica Bienestar</title>
    
    <%-- ================================================================= --%>
    <%-- ==           CORRECCIÓN: Carga condicional del CSS             == --%>
    <%-- ================================================================= --%>
    <% if ("Paciente".equals(rol)) { %>
        <link rel="stylesheet" href="dashboard-patient-styles.css">
    <% } else { %>
        <link rel="stylesheet" href="dashboard-styles.css">
    <% } %>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
</head>
<body class="<%= "Paciente".equals(rol) ? "paciente-view-body" : "" %>">

    <% if ("Paciente".equals(rol)) { %>
        <%-- LAYOUT PARA PACIENTES (sin cambios) --%>
        <div class="patient-portal-container">
            <header class="patient-header">
                 <div class="patient-logo">
                    <i class="fa-solid fa-clinic-medical"></i>
                    Clínica Bienestar
                </div>
                <nav class="patient-main-nav">
                    <a href="dashboard.jsp?page=inicio" class="<%= "inicio".equals(pageToInclude) ? "active" : "" %>">Inicio</a>
                    <a href="dashboard.jsp?page=citas" class="<%= "citas".equals(pageToInclude) ? "active" : "" %>">Mis Citas</a>
                    <a href="#">Agendar Cita</a>
                    <a href="#">Nuestros Médicos</a>
                    <a href="#">Servicios</a>
                </nav>
                <div class="patient-user-profile">
                    <i class="fa-regular fa-user-circle"></i>
                    <span>Gloria</span>
                    <i class="fa-solid fa-chevron-down"></i>
                </div>
            </header>
            <main class="patient-content-area">
                <jsp:include page="<%= contentPage %>" />
            </main>
        </div>

    <% } else { %>
        <%-- LAYOUT ORIGINAL PARA ADMIN (sin cambios) --%>
        <aside class="sidebar">
             <div class="sidebar-header">
                <img src="https://i.imgur.com/x5A5p2B.png" alt="Logo Sonrisa Plena" class="logo-icon">
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
    <% } %>

</body>
</html>