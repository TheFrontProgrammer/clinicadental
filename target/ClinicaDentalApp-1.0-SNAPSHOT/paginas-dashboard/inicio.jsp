<%@page import="java.util.Random"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.LinkedHashMap, java.time.LocalDate, java.time.format.DateTimeFormatter, java.time.temporal.ChronoUnit"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario, com.dental.app.clinicadentalapp.model.Cita, com.dental.app.clinicadentalapp.model.Paciente, com.dental.app.clinicadentalapp.model.Odontologo"%>
<%@page import="com.dental.app.clinicadentalapp.dao.CitaDAO, com.dental.app.clinicadentalapp.dao.PacienteDAO, com.dental.app.clinicadentalapp.dao.OdontologoDAO"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    String rol = (usuario != null && usuario.getRol() != null) ? usuario.getRol().getNombreRol() : "";
%>

<% if ("Paciente".equals(rol)) { %>
<%
    // --- DATOS PARA VISTA DE PACIENTE ---
    CitaDAO citaDAOPaciente = new CitaDAO();
    List<Cita> todasLasCitas = citaDAOPaciente.listarCitas();
    Cita proximaCita = null;
    
    // Buscar la próxima cita del paciente
    for (Cita c : todasLasCitas) {
        if (c.getPaciente().getUsuario().getDocumentoIdentidad().equals(usuario.getDocumentoIdentidad()) 
            && !c.getFechaCita().isBefore(LocalDate.now())) {
            if (proximaCita == null || c.getFechaCita().isBefore(proximaCita.getFechaCita())) {
                proximaCita = c;
            }
        }
    }
    
    // Array de consejos de salud
    String[] consejos = {
        "Recuerda beber al menos 2 litros de agua al día para mantenerte hidratado y lleno de energía.",
        "Una caminata de 30 minutos puede mejorar tu estado de ánimo y fortalecer tu corazón. ¡Muévete!",
        "Llama o visita a un ser querido. Las conexiones sociales son vitales para la salud mental.",
        "Intenta dormir entre 7 y 9 horas cada noche. Un buen descanso repara tu cuerpo y mente.",
        "Asegúrate de incluir frutas y verduras en cada comida. Tu cuerpo te lo agradecerá.",
        "No olvides realizar tus chequeos médicos anuales. La prevención es la mejor medicina.",
        "Dedica 15 minutos al día a una actividad que disfrutes, como leer o escuchar música, para reducir el estrés.",
        "Limita el consumo de alimentos procesados y azúcares. Opta por opciones más naturales y saludables.",
        "Practica ejercicios de respiración profunda para manejar la ansiedad del día a día.",
        "Mantén una postura correcta al trabajar frente al computador para evitar dolores de espalda."
    };
    String consejoDelDia = consejos[new Random().nextInt(consejos.length)];
%>

<div class="patient-dashboard-container">
    <h1 class="welcome-title">Tu Resumen de Bienestar</h1>
    <p class="welcome-subtitle">Hola <%= usuario.getDocumentoIdentidad() %>, bienvenido a tu centro de control personal.</p>

    <div class="patient-dashboard-grid">
        
        <!-- TARJETA: TU ASCENSO DE HOY -->
        <div class="ascenso-card card-shadow">
            <h3>Tu Ascenso de Hoy</h3>
            <div class="progreso-container">
                <div id="progreso-circular" class="progreso-circular" style="--progreso: 0;">
                    <div class="inner-circle">
                        <span id="progreso-texto">0%</span>
                    </div>
                </div>
                <div class="tareas-list">
                    <p>Progreso Diario</p>
                    <div class="tarea-item" data-tarea-id="tarea-vitamina" data-value="25">
                        <i class="fa-regular fa-circle"></i>
                        <span class="tarea-texto">Tomar vitamina D</span>
                        <div class="tarea-icons">
                            <i class="fa-solid fa-pills"></i>
                        </div>
                    </div>
                    <div class="tarea-item" data-tarea-id="tarea-caminata" data-value="25">
                        <i class="fa-regular fa-circle"></i>
                        <span class="tarea-texto">Caminata de 30 minutos</span>
                        <div class="tarea-icons">
                            <i class="fa-solid fa-person-walking"></i>
                        </div>
                    </div>
                    <div class="tarea-item" data-tarea-id="tarea-agua" data-value="25">
                        <i class="fa-regular fa-circle"></i>
                        <span class="tarea-texto">Beber 2L de agua</span>
                        <div class="tarea-icons">
                            <i class="fa-solid fa-glass-water"></i>
                        </div>
                    </div>
                    <div class="tarea-item" data-tarea-id="tarea-lectura" data-value="25">
                        <i class="fa-regular fa-circle"></i>
                        <span class="tarea-texto">Leer 15 minutos</span>
                        <div class="tarea-icons">
                            <i class="fa-solid fa-book-open-reader"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- COLUMNA DERECHA -->
        <div class="right-column">
            <!-- PRÓXIMA CITA -->
            <div class="proxima-cita-card card-shadow">
                <h4>Próximo Campamento Base</h4>
                <% if (proximaCita != null) { %>
                    <div class="cita-details">
                        <div class="cita-fecha">
                            <span><%= proximaCita.getFechaCita().getDayOfMonth() %></span>
                            <%= proximaCita.getFechaCita().format(DateTimeFormatter.ofPattern("MMM")).toUpperCase() %>
                        </div>
                        <div class="cita-info">
                            <strong>Medicina General</strong>
                            <span>con Dr(a). <%= proximaCita.getOdontologo().getNombreCompleto() %></span>
                        </div>
                        <a href="dashboard.jsp?page=citas" class="arrow-link">
                            <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>
                <% } else { %>
                    <p style="text-align: center; color: var(--patient-light-text); padding: 1rem;">
                        No tienes próximas citas agendadas.
                    </p>
                <% } %>
            </div>

            <!-- ESTADÍSTICAS -->
            <div class="stats-card-grid">
                <div class="stat-card">
                    <div class="stat-icon icon-verde">
                        <i class="fa-solid fa-flask-vial"></i>
                    </div>
                    <strong>1</strong>
                    <span>Resultados</span>
                </div>
                <div class="stat-card">
                    <div class="stat-icon icon-rojo">
                        <i class="fa-solid fa-prescription-bottle"></i>
                    </div>
                    <strong>3</strong>
                    <span>Recetas</span>
                </div>
                <div class="stat-card">
                    <div class="stat-icon icon-azul">
                        <i class="fa-solid fa-comment-medical"></i>
                    </div>
                    <strong>2</strong>
                    <span>Mensajes</span>
                </div>
            </div>
        </div>

        <!-- CONEXIÓN SOCIAL -->
        <div class="conexion-social-card card-shadow">
            <i class="fa-solid fa-people-group"></i>
            <h4>Conexión Social</h4>
            <p><%= consejoDelDia %></p>
        </div>

        <!-- ACCESOS RÁPIDOS -->
        <div class="accesos-rapidos-card card-shadow">
            <h4>Accesos Rápidos</h4>
            <div class="accesos-grid">
                <a href="dashboard.jsp?page=citas#agendar" class="acceso-item">
                    <i class="fa-solid fa-calendar-plus"></i>
                    Agendar Cita
                </a>
                <a href="dashboard.jsp?page=citas" class="acceso-item">
                    <i class="fa-solid fa-file-medical"></i>
                    Ver Mi Historial
                </a>
                <a href="dashboard.jsp?page=configuracion" class="acceso-item">
                    <i class="fa-solid fa-user-gear"></i>
                    Actualizar Mi Perfil
                </a>
                <a href="dashboard.jsp?page=odontologos" class="acceso-item">
                    <i class="fa-solid fa-stethoscope"></i>
                    Buscar Médicos
                </a>
            </div>
        </div>

    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tareas = document.querySelectorAll('.tarea-item');
    const progresoCircular = document.getElementById('progreso-circular');
    const progresoTexto = document.getElementById('progreso-texto');
    let progresoActual = 0;

    // Función para actualizar el gráfico
    function actualizarProgreso() {
        progresoCircular.style.setProperty('--progreso', progresoActual);
        progresoTexto.textContent = progresoActual + '%';
    }

    // Cargar estado inicial desde localStorage
    tareas.forEach(tarea => {
        const tareaId = tarea.dataset.tareaId;
        if (localStorage.getItem(tareaId) === 'done') {
            tarea.classList.add('done');
            tarea.querySelector('i:first-child').className = 'fa-solid fa-check-circle';
            progresoActual += parseInt(tarea.dataset.value, 10);
        }

        // Click en la tarea
        tarea.addEventListener('click', function() {
            const valorTarea = parseInt(this.dataset.value, 10);
            const id = this.dataset.tareaId;
            
            this.classList.toggle('done');
            
            if (this.classList.contains('done')) {
                // Tarea completada
                this.querySelector('i:first-child').className = 'fa-solid fa-check-circle';
                progresoActual += valorTarea;
                localStorage.setItem(id, 'done');
            } else {
                // Tarea desmarcada
                this.querySelector('i:first-child').className = 'fa-regular fa-circle';
                progresoActual -= valorTarea;
                localStorage.removeItem(id);
            }
            
            actualizarProgreso();
        });
    });

    // Actualizar el gráfico al cargar
    actualizarProgreso();
});
</script>

<% } else { %>
<%-- =================================================================== --%>
<%-- ==   VISTA ORIGINAL PARA ROLES DE ADMINISTRADOR Y RECEPCIONISTA  == --%>
<%-- =================================================================== --%>
<%
    // --- OBTENER DATOS DE LOS DAO ---
    PacienteDAO pacienteDAO = new PacienteDAO();
    OdontologoDAO odontoDAO = new OdontologoDAO();
    CitaDAO citaDAO = new CitaDAO();

    List<Paciente> listaPacientes = pacienteDAO.listarPacientes();
    List<Odontologo> listaOdontologos = odontoDAO.listarOdontologos();
    List<Cita> listaCitas = citaDAO.listarCitas();
    
    // --- CALCULAR KPIs ---
    int totalPacientes = listaPacientes.size();
    int totalOdontologos = listaOdontologos.size();
    
    LocalDate hoy = LocalDate.now();
    int citasHoyCount = 0;
    int citasPendientesCount = 0;
    
    // Formateadores 
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
    DateTimeFormatter chartLabelFormatter = DateTimeFormatter.ofPattern("EEE dd"); // Formato para etiquetas ej: Lun 20

    // Lista para "Próximas 5 Citas"
    List<Cita> proximas5Citas = new ArrayList<>();

    // --- NUEVO: Lógica para Gráfico de Citas Próximas (7 días) ---
    Map<LocalDate, Integer> citasPorDia = new LinkedHashMap<>(); // LinkedHashMap mantiene el orden de inserción
    LocalDate fechaLimite = hoy.plusDays(7); // Hasta 7 días en el futuro

    // Inicializar el mapa con los próximos 7 días (incluyendo hoy)
    for (long i = 0; i < 7; i++) {
        citasPorDia.put(hoy.plusDays(i), 0);
    }

    // Contar citas y llenar próximas 5
    for (Cita c : listaCitas) {
        LocalDate fechaCita = c.getFechaCita();
        // Contar citas pendientes y de hoy para KPIs
        if (!fechaCita.isBefore(hoy)) {
            citasPendientesCount++;
            if (fechaCita.equals(hoy)) {
                citasHoyCount++;
            }
            // Añadir a próximas 5
            if (proximas5Citas.size() < 5) {
                proximas5Citas.add(c);
            }
        }
        
        // Contar para el gráfico (solo citas desde hoy hasta 6 días más)
        if (!fechaCita.isBefore(hoy) && fechaCita.isBefore(fechaLimite)) {
            citasPorDia.put(fechaCita, citasPorDia.getOrDefault(fechaCita, 0) + 1);
        }
    }

    // Preparar datos para JavaScript
    StringBuilder labels = new StringBuilder("[");
    StringBuilder data = new StringBuilder("[");
    boolean first = true;
    for (Map.Entry<LocalDate, Integer> entry : citasPorDia.entrySet()) {
        if (!first) {
            labels.append(", ");
            data.append(", ");
        }
        // Añadir comillas a las etiquetas
        labels.append("'").append(entry.getKey().format(chartLabelFormatter)).append("'"); 
        data.append(entry.getValue());
        first = false;
    }
    labels.append("]");
    data.append("]");
    
    String chartLabels = labels.toString();
    String chartData = data.toString();
    
    // Lista para "Últimos 5 Pacientes"
    int totalPac = listaPacientes.size();
    List<Paciente> ultimos5Pacientes = listaPacientes.subList(Math.max(0, totalPac - 5), totalPac);
%>

<%-- Mover la inclusión de Chart.js al <head> (Mejor práctica) --%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Dashboard Inicio</title>
    <%-- Enlace a Chart.js --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
    
    <%-- Estilos CSS del dashboard --%>
    <style>
    /* Estilos específicos de inicio.jsp */
    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); /* Columnas responsivas */
        gap: 20px;
    }

    .kpi-card {
        background-color: var(--white); padding: 25px; border-radius: 12px;
        box-shadow: var(--shadow-light); display: flex; align-items: center; gap: 20px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .kpi-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-medium); }

    .kpi-card-icon {
        width: 55px; height: 55px; border-radius: 50%; display: flex; align-items: center;
        justify-content: center; font-size: 1.6rem; color: var(--white); flex-shrink: 0; 
    }
    .icon-pacientes { background-color: var(--primary-blue); }
    .icon-citas { background-color: var(--success-green); }
    .icon-hoy { background-color: var(--warning-orange); }
    .icon-odontologos { background-color: var(--danger-red); }

    .kpi-card-info h2 { font-size: 2.2rem; color: var(--sidebar-bg); margin: 0 0 2px 0; line-height: 1.1; }
    .kpi-card-info p { font-size: 0.85rem; color: var(--text-color); margin: 0; }
    
    /* Contenedor para Gráfico y Listas */
    .dashboard-main-area {
         display: grid;
         grid-template-columns: 2fr 1fr; /* Gráfico ocupa 2/3, listas 1/3 */
         gap: 20px;
         margin-top: 30px;
    }
     /* Media query para pantallas más pequeñas */
    @media (max-width: 992px) {
        .dashboard-main-area {
            grid-template-columns: 1fr; /* Una columna en pantallas pequeñas */
        }
    }
    
    /* --- CAMBIO PRINCIPAL AQUÍ --- */
    .chart-container {
         background-color: var(--white); padding: 30px; border-radius: 12px;
         box-shadow: var(--shadow-light);
         position: relative; 
         /* Altura fija para el contenedor del gráfico */
         height: 400px; /* Puedes ajustar este valor */
         max-height: 450px; /* Límite superior */
         /* min-height: 350px;  Quitamos min-height o lo dejamos como fallback si prefieres */
    }
    /* --- FIN DEL CAMBIO --- */
    
     .chart-container h3 { /* Estilo unificado título */
         font-size: 1.1rem; color: var(--dark-blue-text); margin-bottom: 25px; 
         padding-bottom: 10px; border-bottom: 1px solid #eee; font-weight: 600; 
         margin-top: 0; /* Quitar margen superior */
     }

    .list-container { /* Contenedor para las dos listas */
        display: flex;
        flex-direction: column;
        gap: 20px; /* Espacio entre las dos listas */
    }
    
    .list-card {
        background-color: var(--white); padding: 30px; border-radius: 12px;
        box-shadow: var(--shadow-light); flex-grow: 1; /* Para que ocupen espacio */
    }
    .list-card h3 { /* Estilo unificado título */
         font-size: 1.1rem; color: var(--dark-blue-text); margin-bottom: 25px; 
         padding-bottom: 10px; border-bottom: 1px solid #eee; font-weight: 600; 
         margin-top: 0; /* Quitar margen superior */
    }
    
    .list-card .list-card-item {
        display: flex; justify-content: space-between; align-items: center;
        padding: 12px 0; border-bottom: 1px solid #f0f0f0;
        transition: background-color 0.2s ease; 
    }
     .list-card .list-card-item:hover { background-color: #fcfdff; }
    .list-card .list-card-item:last-child { border-bottom: none; }
    .list-card .list-card-item-info { display: flex; flex-direction: column; gap: 2px; }
    .list-card .list-card-item-info strong { font-weight: 600; color: var(--dark-blue-text); font-size: 0.9rem; }
    .list-card .list-card-item-info span { font-size: 0.8rem; color: #777; }
    .list-card .list-card-item-extra { font-size: 0.8rem; font-weight: 600; color: var(--primary-blue); text-align: right; flex-shrink: 0; padding-left: 10px; }
    .list-card .list-card-item-extra.paciente { color: #555; font-weight: 500; }

</style>
</head>
<body>
    
    <header class="header">
        <h1>Dashboard Principal</h1>
        <div class="header-actions">
            <a href="../logout" title="Cerrar Sesión"><i class="fa-solid fa-right-from-bracket"></i></a>
            <a href="dashboard.jsp?page=configuracion" title="Configuración"><i class="fa-solid fa-cog"></i></a>
        </div>
    </header>

    <div class="dashboard-grid">
        <div class="kpi-card fade-in">
            <div class="kpi-card-icon icon-pacientes"> <i class="fa-solid fa-hospital-user"></i> </div>
            <div class="kpi-card-info"> <h2><%= totalPacientes %></h2> <p>Pacientes Totales</p> </div>
        </div>
        <div class="kpi-card fade-in">
            <div class="kpi-card-icon icon-citas"> <i class="fa-solid fa-calendar-check"></i> </div>
            <div class="kpi-card-info"> <h2><%= citasPendientesCount %></h2> <p>Citas Pendientes</p> </div>
        </div>
        <div class="kpi-card fade-in">
            <div class="kpi-card-icon icon-hoy"> <i class="fa-solid fa-calendar-day"></i> </div>
            <div class="kpi-card-info"> <h2><%= citasHoyCount %></h2> <p>Citas para Hoy</p> </div>
        </div>
        <div class="kpi-card fade-in">
            <div class="kpi-card-icon icon-odontologos"> <i class="fa-solid fa-user-doctor"></i> </div>
            <div class="kpi-card-info"> <h2><%= totalOdontologos %></h2> <p>Odontólogos Activos</p> </div>
        </div>
    </div>

    <div class="dashboard-main-area">
        
        <section class="content-card chart-container fade-in">
             <h3>Citas Próximos 7 Días</h3>
             <%-- El lienzo donde se dibujará el gráfico --%>
             <canvas id="citasChart"></canvas>
        </section>
        
        <div class="list-container">
            <section class="content-card list-card fade-in">
                <h3>Próximas 5 Citas</h3>
                <% if (proximas5Citas.isEmpty()) { %>
                    <div class="list-card-item"> <div class="list-card-item-info"> <span>No hay citas próximas.</span> </div> </div>
                <% } else { %>
                    <% for (Cita c : proximas5Citas) { %>
                        <div class="list-card-item">
                            <div class="list-card-item-info">
                                <strong><%= c.getPaciente().getNombreCompleto() %></strong>
                                <span>Dr(a). <%= c.getOdontologo().getApellido() %> - <%= c.getMotivo() %></span>
                            </div>
                            <div class="list-card-item-extra">
                                <% if(c.getFechaCita().equals(hoy)) { %> <strong style="color: var(--warning-orange);">HOY</strong>
                                <% } else { %> <%= c.getFechaCita().format(dateFormatter) %> <% } %>
                                <br> <span><%= c.getHoraCita().format(timeFormatter) %></span>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </section>
            
            <section class="content-card list-card fade-in">
                <h3>Últimos Pacientes</h3>
                <% if (ultimos5Pacientes.isEmpty()) { %>
                     <div class="list-card-item"> <div class="list-card-item-info"> <span>No hay pacientes recientes.</span> </div> </div>
                <% } else { %>
                    <% for (int i = ultimos5Pacientes.size() - 1; i >= 0; i--) { Paciente p = ultimos5Pacientes.get(i); %>
                        <div class="list-card-item">
                            <div class="list-card-item-info">
                                <strong><%= p.getNombreCompleto() %></strong>
                                <span><%= p.getEmail() != null && !p.getEmail().isEmpty() ? p.getEmail() : "Sin email" %></span>
                            </div>
                            <div class="list-card-item-extra paciente"> DNI: <%= p.getUsuario().getDocumentoIdentidad() %> </div>
                        </div>
                    <% } %>
                <% } %>
            </section>
        </div>
        
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const elements = document.querySelectorAll('.fade-in');
            elements.forEach((el, index) => {
                setTimeout(() => { el.classList.add('visible'); }, 50 * index); // Más rápido
            });
            
             // --- NUEVO: Script para inicializar el gráfico ---
             const ctx = document.getElementById('citasChart');
             if (ctx) { // Asegurarse que el canvas existe
                 const chartLabels = <%= chartLabels %>; // Obtener etiquetas desde Java
                 const chartData = <%= chartData %>;     // Obtener datos desde Java

                 const data = {
                     labels: chartLabels,
                     datasets: [{
                         label: 'Número de Citas',
                         data: chartData,
                         backgroundColor: 'rgba(42, 121, 238, 0.6)', // Azul primario con transparencia
                         borderColor: 'rgba(42, 121, 238, 1)',     // Azul primario sólido
                         borderWidth: 1,
                         borderRadius: 4, // Bordes redondeados
                         hoverBackgroundColor: 'rgba(42, 121, 238, 0.8)' // Más opaco al pasar el ratón
                     }]
                 };

                 const config = {
                     type: 'bar',
                     data: data,
                     options: {
                         responsive: true, // Hacerlo adaptable
                         maintainAspectRatio: false, // Permitir controlar altura con CSS
                         plugins: {
                             legend: {
                                 display: false // Ocultar leyenda (es obvio)
                             },
                             title: {
                                 display: false // Ya tenemos título en H3
                             },
                             tooltip: { // Mejorar tooltip
                                 backgroundColor: '#333',
                                 titleColor: '#fff',
                                 bodyColor: '#fff',
                                 padding: 10,
                                 cornerRadius: 4,
                                 displayColors: false // No mostrar el cuadrito de color
                             }
                         },
                         scales: {
                             y: {
                                 beginAtZero: true, // Empezar eje Y en 0
                                 ticks: {
                                     stepSize: 1 // Mostrar solo números enteros en Y
                                 },
                                 grid: {
                                     color: '#eee' // Líneas de grid más suaves
                                 }
                             },
                             x: {
                                 grid: {
                                     display: false // Ocultar líneas de grid en X
                                 }
                             }
                         }
                     }
                 };

                 // Crear el gráfico
                 new Chart(ctx, config);
             }
        });
    </script>
<% } %>