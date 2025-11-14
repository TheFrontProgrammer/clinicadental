<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%-- ========================================================== --%>
<%-- ==           IMPORTACIONES CORREGIDAS (COMPLETO)        == --%>
<%-- ========================================================== --%>

<%-- Java Utilidades (Listas, Fechas, Random, etc.) --%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.temporal.ChronoUnit"%>
<%@page import="java.util.Random"%> <%-- <-- ¡ESTA ES LA LÍNEA QUE FALTABA! --%>

<%-- Modelos de la Aplicación --%>
<%@page import="com.dental.app.clinicadentalapp.model.Usuario"%>
<%@page import="com.dental.app.clinicadentalapp.model.Cita"%>
<%@page import="com.dental.app.clinicadentalapp.model.Paciente"%>
<%@page import="com.dental.app.clinicadentalapp.model.Odontologo"%>

<%-- Clases DAO (Rutas Corregidas) --%>
<%@page import="com.dental.app.clinicadentalapp.CitaDAO"%>
<%@page import="com.dental.app.clinicadentalapp.PacienteDAO"%>
<%@page import="com.dental.app.clinicadentalapp.OdontologoDAO"%>
<%
    // Esta lógica ahora solo se ejecuta para el paciente
    Usuario usuario = (Usuario) session.getAttribute("usuario");
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

        <div class="right-column">
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

        <div class="conexion-social-card card-shadow">
            <i class="fa-solid fa-people-group"></i>
            <h4>Conexión Social</h4>
            <p><%= consejoDelDia %></p>
        </div>

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