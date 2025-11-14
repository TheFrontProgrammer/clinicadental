<%@page import="java.util.Random"%> <%-- (Esta importación ya no es necesaria, pero no hace daño) --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.LinkedHashMap, java.time.LocalDate, java.time.format.DateTimeFormatter, java.time.temporal.ChronoUnit"%>

<%-- ========================================================== --%>
<%-- ==           IMPORTACIONES CORREGIDAS (SIN .DAO)        == --%>
<%-- ========================================================== --%>
<%@page import="com.dental.app.clinicadentalapp.CitaDAO"%>
<%@page import="com.dental.app.clinicadentalapp.PacienteDAO"%>
<%@page import="com.dental.app.clinicadentalapp.OdontologoDAO"%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page import="com.dental.app.clinicadentalapp.model.Cita"%>
<%@page import="com.dental.app.clinicadentalapp.model.Paciente"%>
<%@page import="com.dental.app.clinicadentalapp.model.Odontologo"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>

<%
    // =================================================================
    // ==     SE ELIMINÓ TODA LA SECCIÓN if ("Paciente".equals(rol))    ==
    // =================================================================
%>

<%-- =================================================================== --%>
<%-- ==   VISTA PARA ROLES DE ADMINISTRADOR Y RECEPCIONISTA           == --%>
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

    // --- Lógica para Gráfico de Citas Próximas (7 días) ---
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

<%-- No es necesario el <!DOCTYPE html> aquí porque es un fragmento --%>
<head>
    <%-- El <script> de Chart.js ya está en el dashboard.jsp principal --%>
    
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
        justify-content: center; font-size: 1.5rem; color: var(--white); flex-shrink: 0; 
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
    
    .chart-container {
         background-color: var(--white);
         padding: 30px; border-radius: 12px;
         box-shadow: var(--shadow-light);
         position: relative; 
         height: 400px; 
         max-height: 450px;
    }
    
     .chart-container h3 { 
         font-size: 1.1rem; color: var(--dark-blue-text); margin-bottom: 25px; 
         padding-bottom: 10px; border-bottom: 1px solid #eee; font-weight: 600; 
         margin-top: 0;
     }

    .list-container { 
        display: flex;
        flex-direction: column;
        gap: 20px; 
    }
    
    .list-card {
        background-color: var(--white); padding: 30px; border-radius: 12px;
        box-shadow: var(--shadow-light); flex-grow: 1; 
    }
    .list-card h3 { 
         font-size: 1.1rem; color: var(--dark-blue-text); margin-bottom: 25px; 
         padding-bottom: 10px; border-bottom: 1px solid #eee; font-weight: 600; 
         margin-top: 0;
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
<%-- No se necesita </body> o </html> --%>
    
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
        
         // --- Script para inicializar el gráfico ---
         const ctx = document.getElementById('citasChart');
           if (ctx) { // Asegurarse que el canvas existe
             const chartLabels = <%= chartLabels %>; // Obtener etiquetas desde Java
             const chartData = <%= chartData %>;     // Obtener datos desde Java

             const data = {
                   labels: chartLabels,
                 datasets: [{
                     label: 'Número de Citas',
                     data: chartData,
                     backgroundColor: 'rgba(42, 121, 238, 0.6)', 
                     borderColor: 'rgba(42, 121, 238, 1)',
                     borderWidth: 1,
                     borderRadius: 4, 
                     hoverBackgroundColor: 'rgba(42, 121, 238, 0.8)' 
                 }]
             };

             const config = {
                 type: 'bar',
                 data: data,
                 options: {
                     responsive: true, 
                     maintainAspectRatio: false, 
                     plugins: {
                         legend: {
                            display: false 
                         },
                         title: {
                            display: false 
                         },
                         tooltip: { 
                            backgroundColor: '#333',
                             titleColor: '#fff',
                             bodyColor: '#fff',
                             padding: 10,
                             cornerRadius: 4,
                             displayColors: false 
                               }
                     },
                     scales: {
                           y: {
                             beginAtZero: true, 
                             ticks: {
                               stepSize: 1 
                             },
                             grid: {
                               color: '#eee' 
                             }
                         },
                          x: {
                             grid: {
                                 display: false 
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