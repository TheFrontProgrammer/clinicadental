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

    // --- INICIO DE MODIFICACIÓN AJAX ---
    // 1. Revisamos si se agregó el parámetro 'ajax=true' a la URL
    String ajaxParam = request.getParameter("ajax");
    if ("true".equals(ajaxParam)) {
        // Si es una petición AJAX, solo incluimos la página de contenido y detenemos
        response.setContentType("text/html; charset=UTF-8");
        pageContext.include(contentPage);
        return; // Detiene la renderización del layout principal
    }
    // --- FIN DE MODIFICACIÓN AJAX ---
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
    
    <%-- Corrección 2: Librería de gráficos (ya la tenías, la moví al head) --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="<%= "Paciente".equals(rol) ? "paciente-view-body" : "" %>">

    <% if ("Paciente".equals(rol)) { %>
        <%-- LAYOUT PARA PACIENTES --%>
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
            
            <main class="patient-content-area" id="ajax-content-wrapper">
                <jsp:include page="<%= contentPage %>" />
            </main>
        </div>

    <% } else { %>
        <%-- LAYOUT ORIGINAL PARA ADMIN/RECEPCIONISTA --%>
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

        <main class="main-content" id="ajax-content-wrapper">
            <jsp:include page="<%= contentPage %>" />
        </main>
    <% } %>


    <script>
    document.addEventListener('DOMContentLoaded', function() {
        
        // 1. Encontrar el contenedor de contenido principal
        const contentArea = document.getElementById('ajax-content-wrapper');
        
        // 2. Encontrar todos los enlaces de navegación
        const navLinks = document.querySelectorAll('.sidebar-nav a, .patient-main-nav a');

        /**
         * Función para cargar una página vía AJAX
         * @param {string} url - La URL del dashboard (ej: dashboard.jsp?page=pacientes)
         * @param {boolean} pushHistory - true si debe agregarse al historial del navegador
         */
        function loadPage(url, pushHistory = true) {
            
            // Crear una URL para la solicitud AJAX, añadiendo el parámetro 'ajax=true'
            // Usamos location.origin + location.pathname para construir la URL base
            const ajaxUrl = new URL(url, location.origin + location.pathname.substring(0, location.pathname.lastIndexOf('/') + 1));
            ajaxUrl.searchParams.set('ajax', 'true');

            // Opcional: Mostrar un indicador de carga
            if(contentArea) {
                contentArea.style.opacity = '0.5';
                contentArea.style.transition = 'opacity 0.3s ease-in-out';
            }

            // 3. Realizar la petición FETCH
            fetch(ajaxUrl.href)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Error al cargar la página. Estatus: ' + response.status);
                    }
                    return response.text();
                })
                .then(html => {
                    // 4. Inyectar el HTML de la página parcial en el contenedor
                    if(contentArea) {
                        contentArea.innerHTML = html;
                        contentArea.style.opacity = '1';
                    }

                    // 5. Actualizar la URL en la barra de direcciones del navegador
                    if (pushHistory) {
                        // Usamos la URL original (sin ajax=true) para la barra de direcciones
                        history.pushState({page: new URL(url).searchParams.get('page')}, '', url);
                    }

                    // 6. Actualizar la clase 'active' en los enlaces de navegación
                    const pageParam = new URL(url).searchParams.get('page') || 'inicio';
                    navLinks.forEach(link => {
                        // Obtenemos el parámetro 'page' de cada enlace
                        const linkUrl = new URL(link.href);
                        const linkPage = linkUrl.searchParams.get('page') || 'inicio';
                        
                        // Para la navegación del paciente
                        if (link.closest('.patient-main-nav')) {
                             if (linkPage === pageParam) {
                                link.classList.add('active');
                            } else {
                                link.classList.remove('active');
                            }
                        } 
                        // Para la navegación del admin/recepcionista
                        else if (link.closest('.sidebar-nav')) {
                            if (linkPage === pageParam) {
                                link.parentElement.classList.add('active');
                            } else {
                                link.parentElement.classList.remove('active');
                            }
                        }
                    });
                })
                .catch(error => {
                    console.error('Error en la carga AJAX:', error);
                    if(contentArea) {
                        contentArea.innerHTML = '<div class="content-card"><h3>Error</h3><p>No se pudo cargar el contenido. Por favor, intente recargar la página completa.</p></div>';
                        contentArea.style.opacity = '1';
                    }
                });
        }

        // 7. Interceptar clics en los enlaces de navegación
        navLinks.forEach(link => {
            // Solo interceptar enlaces que cargan páginas del dashboard (internos)
            if (link.href && (link.href.includes('dashboard.jsp?page=') || link.getAttribute('href').startsWith('#'))) {
                // Si es un enlace de anclaje simple (como #), también lo prevenimos
                 if(link.getAttribute('href') === '#') {
                    link.addEventListener('click', function(event) {
                        event.preventDefault();
                        console.log("Enlace de anclaje clickeado, sin acción AJAX.");
                    });
                 } else {
                    link.addEventListener('click', function(event) {
                        event.preventDefault(); // Prevenir la recarga de la página
                        loadPage(this.href, true);
                    });
                 }
            }
        });

        // 8. Manejar los botones "atrás" y "adelante" del navegador
        window.addEventListener('popstate', function(event) {
            // Cuando el usuario presiona atrás/adelante, 'location.href' ya es la URL correcta.
            // La cargamos sin agregar un nuevo estado al historial (pushHistory = false).
            // Esto asegura que la página se actualice al estado correcto.
            loadPage(location.href, false);
        });
    });
    </script>
    </body>
</html>