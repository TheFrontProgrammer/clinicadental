<%@page import="com.dental.app.clinicadentalapp.model.Paciente"%>
<%@page import="com.dental.app.clinicadentalapp.dao.PacienteDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Lógica para obtener el rol y la página a incluir
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    // Seguridad: Si no hay sesión o no es paciente, redirigir al login
    if (usuario == null || !"Paciente".equals(usuario.getRol().getNombreRol())) {
        response.sendRedirect("../index.jsp");
        return;
    }
    String rol = usuario.getRol().getNombreRol();
    String pageToInclude = request.getParameter("page");
    if (pageToInclude == null || pageToInclude.trim().isEmpty()) {
        pageToInclude = "inicio";
    }
    
    // 2. Lógica para obtener el nombre del Paciente
    String nombrePaciente = "Paciente"; 
    try {
        PacienteDAO pDao = new PacienteDAO();
        String dniLogueado = usuario.getDocumentoIdentidad();
        List<Paciente> listaPacientes = pDao.listarPacientes();
        for (Paciente p : listaPacientes) {
            if (p.getUsuario() != null && p.getUsuario().getDocumentoIdentidad().equals(dniLogueado)) {
                nombrePaciente = p.getNombre();
                break;
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    
    // 3. Lógica de permisos y RUTAS de contenido
    boolean tienePermiso = false;
    switch (pageToInclude) {
        case "inicio":
        case "citas":
        case "configuracion": // Para cambiar contraseña
        case "historial":     // Para "Mi Historial"
        case "miperfil":      // Para "Mi Perfil"
            tienePermiso = true;
            break;
    }
    if (!tienePermiso) {
        pageToInclude = "inicio";
    }
    
    String contentPage;
    if (pageToInclude.equals("historial")) {
        // "Mi Historial" (temporalmente) usa la nueva página de citas del paciente
        contentPage = "../paginas-dashboard-paciente/citas.jsp";
    } else if (pageToInclude.equals("configuracion")) {
        // "Cambiar Contraseña" usa la página compartida original
        contentPage = "../paginas-dashboard/configuracion.jsp";
    } else {
        // "inicio", "citas", y "miperfil" usan la nueva carpeta del paciente
        contentPage = "../paginas-dashboard-paciente/" + pageToInclude + ".jsp";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Clínica Bienestar</title>
    <%-- Ruta al CSS de Paciente --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dashboard/dashboard-patient-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <%-- CSS para el Menú Desplegable --%>
    <style>
        .patient-user-profile { position: relative; cursor: pointer; }
        .dropdown-menu { display: none; position: absolute; top: 130%; right: 0; background-color: var(--patient-card-bg, #FFFFFF); min-width: 180px; box-shadow: 0 8px 16px rgba(0,0,0,0.1); border-radius: 8px; z-index: 100; border: 1px solid var(--patient-border-color, #E2E8F0); }
        .dropdown-menu.show { display: block; }
        .dropdown-menu a { display: flex; align-items: center; gap: 12px; padding: 12px 16px; text-decoration: none; color: var(--patient-dark-text, #2D3748); font-weight: 500; font-size: 0.9rem; }
        .dropdown-menu a i { width: 16px; text-align: center; color: #888; }
        .dropdown-menu a:hover { background-color: var(--patient-bg, #F5F7FA); }
        .dropdown-menu a.logout-link, .dropdown-menu a.logout-link i { color: var(--patient-accent-red, #E53E3E); }
        .dropdown-menu hr { border: 0; height: 1px; background-color: var(--patient-border-color, #E2E8F0); margin: 4px 0; }
        
        /* === CSS PARA EL MODAL DE BIENVENIDA === */
        .welcome-modal {
            display: none; /* Oculto por defecto */
            align-items: center;
            justify-content: center;
            position: fixed;
            z-index: 2000;
            left: 0; top: 0;
            width: 100%; height: 100%;
            background-color: rgba(0,0,0,0.6);
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease, visibility 0.3s ease;
        }
        .welcome-modal.is-visible {
            display: flex;
            opacity: 1;
            visibility: visible;
        }
        .welcome-modal-content {
            background-color: var(--patient-card-bg, #FFFFFF);
            padding: 30px 35px;
            border-radius: 12px;
            width: 90%;
            max-width: 450px;
            position: relative;
            transform: translateY(-20px) scale(0.95);
            transition: transform 0.3s ease, opacity 0.3s ease;
            opacity: 0;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            text-align: center;
        }
        .welcome-modal.is-visible .welcome-modal-content {
            transform: translateY(0) scale(1);
            opacity: 1;
        }
        .welcome-modal-icon {
            font-size: 3rem;
            color: var(--patient-primary-blue, #4F63D7);
            margin-bottom: 15px;
        }
        .welcome-modal-content h2 {
            font-size: 1.5rem;
            color: var(--patient-dark-text, #2D3748);
            margin: 0 0 10px 0;
        }
        .welcome-modal-content p {
            font-size: 1rem;
            color: var(--patient-light-text, #A0AEC0);
            margin-bottom: 25px;
        }
        .welcome-modal-content .btn-primary {
            padding: 12px 30px;
            font-size: 1rem;
            width: 100%; 
            background-color: var(--patient-primary-blue, #4F63D7);
            color: white; border-radius: 8px; border: none; cursor: pointer;
        }
    </style>
</head>
<body class="paciente-view-body">

    <div class="patient-portal-container">
        <header class="patient-header">
             <div class="patient-logo">
                 <i class="fa-solid fa-tooth"></i>
                 <span>Sonrisa Plena</span>
            </div>
            <nav class="patient-main-nav">
                <a href="dashboard.jsp?page=inicio" class="<%= "inicio".equals(pageToInclude) ? "active" : "" %>">Inicio</a>
                <a href="dashboard.jsp?page=citas" class="<%= "citas".equals(pageToInclude) ? "active" : "" %>">Mis Citas</a>
                <a href="#">Agendar Cita</a>
                <a href="#">Nuestros Médicos</a>
                <a href="#">Servicios</a>
            </nav>

            <div class="patient-user-profile" id="userProfileButton">
                <i class="fa-regular fa-user-circle"></i>
                <span><%= nombrePaciente %></span>
                <i class="fa-solid fa-chevron-down"></i>
                
                <div class="dropdown-menu" id="userDropdown">
                    <a href="dashboard.jsp?page=miperfil">
                        <i class="fa-solid fa-user-pen"></i>
                        Mi Perfil
                    </a>
                    <a href="dashboard.jsp?page=historial">
                        <i class="fa-solid fa-file-medical"></i>
                        Mi Historial
                    </a>
                    <hr>
                    <a href="../logout" class="logout-link">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        Cerrar Sesión
                    </a>
                </div>
            </div>
        </header>

        <main class="patient-content-area">
            <%-- Esta línea carga el JSP correcto desde la carpeta correcta --%>
            <jsp:include page="<%= contentPage %>" />
        </main>
    </div>
    
    <%-- ========================================================== --%>
    <%-- ==         AQUÍ ESTÁ EL CÓDIGO DEL MODAL                == --%>
    <%-- ========================================================== --%>
    <%
        String loginStatus = request.getParameter("login");
        if ("success".equals(loginStatus)) {
    %>
        <div id="welcomeModal" class="welcome-modal">
             <div class="welcome-modal-content">
                 <div class="welcome-modal-icon">
                     <i class="fa-solid fa-hands-clapping"></i>
                 </div>
                 <h2>¡Bienvenido(a)!</h2>
                 <p>Te damos la bienvenida al Portal de Paciente, <%= nombrePaciente %>.</p>
                 <button id="closeWelcomeModal" class="btn-primary">Entendido</button>
             </div>
        </div>
    
        <%-- Y aquí su script --%>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const modal = document.getElementById('welcomeModal');
                const closeBtn = document.getElementById('closeWelcomeModal');
                if (modal) {
                    const closeModal = () => modal.classList.remove('is-visible');
                    // Espera un poco para que la página cargue antes de mostrar el modal
                    setTimeout(() => modal.classList.add('is-visible'), 300);
                    closeBtn.addEventListener('click', closeModal);
                    // Cierra si se hace clic fuera del contenido
                    modal.addEventListener('click', (e) => {
                        if (e.target === modal) closeModal();
                    });
                }
            });
        </script>
    <% } %>

    <%-- Script para el Menú Desplegable --%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const userProfileButton = document.getElementById('userProfileButton');
            const userDropdown = document.getElementById('userDropdown');

            if (userProfileButton && userDropdown) {
                userProfileButton.addEventListener('click', function(event) {
                    event.stopPropagation();
                    userDropdown.classList.toggle('show');
                });
                window.addEventListener('click', function(event) {
                    if (userDropdown.classList.contains('show') && !userProfileButton.contains(event.target)) {
                        userDropdown.classList.remove('show');
                    }
                });
            }
        });
    </script>
</body>
</html>