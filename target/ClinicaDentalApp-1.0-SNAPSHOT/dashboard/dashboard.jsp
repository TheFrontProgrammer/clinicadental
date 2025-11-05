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
    
    // =================================================================
    // ==           NUEVA LÓGICA PARA EL MODAL DE BIENVENIDA          ==
    // =================================================================
    String loginStatus = request.getParameter("login");
    
    // Usamos el DNI para el saludo, ya que es el dato que tenemos en el objeto Usuario
    String nombreUsuario = "Estimado(a)"; // Valor por defecto
    if (usuario != null && usuario.getDocumentoIdentidad() != null) {
        nombreUsuario = usuario.getDocumentoIdentidad(); 
    }
    
    // Determinar el tipo de portal para el mensaje
    String nombrePortal = "Portal";
    if ("Paciente".equals(rol)) {
        nombrePortal = "Portal de Paciente";
    } else if ("Administrador".equals(rol) || "Recepcionista".equals(rol)) {
        nombrePortal = "Portal de Administración";
    } else if ("Odontologo".equals(rol)) {
        nombrePortal = "Portal de Odontólogo";
    }
    // =================================================================
    // ==                      FIN DE LA NUEVA LÓGICA                 ==
    // =================================================================
    
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
    <%-- ==  CORRECCIÓN 1: Carga de CSS con ruta absoluta (más seguro)  == --%>
    <%-- ================================================================= --%>
    <% if ("Paciente".equals(rol)) { %>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/dashboard/dashboard-patient-styles.css">
    <% } else { %>
         <link rel="stylesheet" href="${pageContext.request.contextPath}/dashboard/dashboard-styles.css">
    <% } %>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>

    <%-- ================================================================= --%>
    <%-- ==       CORRECCIÓN 2: Librería de gráficos Chart.js (en head)   == --%>
    <%-- ================================================================= --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <%-- ================================================================= --%>
    <%-- ==           NUEVO: Estilos para el Modal de Bienvenida        == --%>
    <%-- ================================================================= --%>
    <style>
        .welcome-modal {
            display: none; /* Oculto por defecto, se muestra con JS */
            align-items: center;
            justify-content: center;
            position: fixed;
            z-index: 2000; /* Encima de todo */
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
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
            background-color: #fefefe;
            padding: 30px 35px;
            border-radius: 12px;
            width: 90%;
            max-width: 450px;
            position: relative;
            transform: translateY(-20px) scale(0.95);
            transition: transform 0.3s ease, opacity 0.3s ease;
            opacity: 0;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            text-align: center; /* Centrar contenido */
        }
        .welcome-modal.is-visible .welcome-modal-content {
            transform: translateY(0) scale(1);
            opacity: 1;
        }
        .welcome-modal-icon {
            font-size: 3rem;
            color: #2A79EE; /* --primary-blue (del css) */
            margin-bottom: 15px;
        }
        .welcome-modal-content h2 {
            font-size: 1.5rem;
            color: #1C3F78; /* --dark-blue-text (del css) */
            margin: 0 0 10px 0;
        }
        .welcome-modal-content p {
            font-size: 1rem;
            color: #555; /* --text-color (del css) */
            margin-bottom: 25px;
        }
        /* Asumiendo que .btn-primary ya está definido en tus CSS */
        .welcome-modal-content .btn-primary {
            padding: 12px 30px;
            font-size: 1rem;
            width: 100%; 
        }
    </style>
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
        <%-- LAYOUT ORIGINAL PARA ADMIN/RECEPCIONISTA (sin cambios) --%>
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
    <% } %>

    <%-- ================================================================= --%>
    <%-- ==           NUEVO: MODAL DE BIENVENIDA Y SCRIPT               == --%>
    <%-- ================================================================= --%>
    <% if ("success".equals(loginStatus)) { %>
    <div id="welcomeModal" class="welcome-modal">
        <div class="welcome-modal-content">
            <div class="welcome-modal-icon">
                <i class="fa-solid fa-hands-clapping"></i>
            </div>
            <h2>¡Bienvenido(a)!</h2>
            <%-- Usamos las variables definidas al inicio --%>
            <p>Te damos la bienvenida al <%= nombrePortal %>, estimado(a) <%= nombreUsuario %>.</p>
            <button id="closeWelcomeModal" class="btn-primary">Entendido</button>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const modal = document.getElementById('welcomeModal');
            const closeBtn = document.getElementById('closeWelcomeModal');
            
            if (modal) {
                // Función para cerrar
                const closeModal = () => {
                    modal.classList.remove('is-visible');
                };
    
                // Mostrar el modal
                // Usamos un pequeño timeout para dejar que la página cargue primero
                setTimeout(() => {
                    modal.classList.add('is-visible');
                }, 300); // 0.3 segundos
    
                // Asignar eventos de cierre
                closeBtn.addEventListener('click', closeModal);
                modal.addEventListener('click', (e) => {
                    if (e.target === modal) {
                        closeModal();
                    }
                });
            }
        });
    </script>
    <% } %>

</body>
</html>
