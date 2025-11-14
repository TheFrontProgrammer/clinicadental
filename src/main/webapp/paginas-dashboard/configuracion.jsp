<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String updateStatus = request.getParameter("update");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Configuración</title>
        <style>
            /* Estilos para las alertas (copiados de otras páginas) */
            .alert {
                padding: 15px;
                margin-bottom: 20px;
                border: 1px solid transparent;
                border-radius: 4px;
                animation: fadeInOut 5s ease-in-out forwards;
            }
            @keyframes fadeInOut {
                0% { opacity: 0; transform: translateY(-20px); }
                10% { opacity: 1; transform: translateY(0); }
                90% { opacity: 1; transform: translateY(0); }
                100% { opacity: 0; transform: translateY(-20px); visibility: hidden; }
            }
            .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
            .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
            
            /* Estilos para el formulario de contraseña */
            .form-password {
                max-width: 500px;
            }
            .form-password .form-group {
                display: flex;
                flex-direction: column;
                margin-bottom: 15px;
            }
            .form-password label {
                margin-bottom: 8px;
                font-weight: 500;
            }
            .form-password input[type="password"] {
                padding: 12px;
                border-radius: 8px;
                border: 1px solid var(--border-color);
                font-size: 1rem;
            }
            .password-rules {
                font-size: 0.8rem;
                color: #666;
                margin-top: 5px;
            }
            /* Mensaje de error del lado del cliente */
            #passwordError {
                color: var(--danger-red);
                margin-top: 10px;
                font-weight: 500;
                display: none; /* Oculto por defecto */
            }
        </style>
    </head>
    <body>
        
        <header class="header">
            <h1>Configuración de la Cuenta</h1>
            <div class="header-actions">
                <a href="../logout" title="Cerrar Sesión" style="margin-right: 15px; color: var(--danger-red);"><i class="fa-solid fa-right-from-bracket"></i></a>
            </div>
        </header>

        <%-- (CP-019) Mensaje de éxito --%>
        <% if ("exito".equals(updateStatus)) { %><div class="alert alert-success">¡Contraseña actualizada exitosamente!</div><% } %>
        
        <%-- (CP-020) Mensajes de error --%>
        <% if ("error".equals(updateStatus)) { %><div class="alert alert-danger">Error: No se pudo actualizar la contraseña.</div><% } %>
        <% if ("error_actual".equals(updateStatus)) { %><div class="alert alert-danger">Error: La contraseña actual es incorrecta.</div><% } %>
        <% if ("error_formato".equals(updateStatus)) { %><div class="alert alert-danger">Error: La nueva contraseña no cumple con los requisitos de seguridad.</div><% } %>
        <% if ("error_no_coinciden".equals(updateStatus)) { %><div class="alert alert-danger">Error: Las nuevas contraseñas no coinciden.</div><% } %>

        
        <section class="content-card">
            <h3>Cambiar mi Contraseña</h3>
            <p>Por razones de seguridad, se recomienda cambiar la contraseña que se le asignó por defecto al registrarse.</p>
            <br>
            
            <form action="../usuario" method="post" class="form-password" id="changePasswordForm">
                
                <div class="form-group">
                    <label for="pass_actual">Contraseña Actual</label>
                    <input type="password" id="pass_actual" name="password_actual" required>
                </div>
                
                <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;">
                
                <div class="form-group">
                    <label for="pass_nueva">Nueva Contraseña</label>
                    <input type="password" id="pass_nueva" name="password_nueva" required>
                    <div class="password-rules">
                        Mínimo 8 caracteres, una mayúscula, una minúscula, un número y un caracter especial (@_#$%^&+=!*?).
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="pass_confirmar">Confirmar Nueva Contraseña</label>
                    <input type="password" id="pass_confirmar" name="confirmar_password" required>
                </div>
                
                <p id="passwordError">Las nuevas contraseñas no coinciden.</p>
                
                <br>
                <button type="submit" class="btn-primary">Actualizar Contraseña</button>
            </form>
        </section>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                // (CP-020) Validación en el cliente para confirmar contraseña
                const form = document.getElementById('changePasswordForm');
                const passNueva = document.getElementById('pass_nueva');
                const passConfirmar = document.getElementById('pass_confirmar');
                const errorMsg = document.getElementById('passwordError');

                form.addEventListener('submit', function(event) {
                    if (passNueva.value !== passConfirmar.value) {
                        // 1. Evita que el formulario se envíe
                        event.preventDefault(); 
                        // 2. Muestra el mensaje de error
                        errorMsg.style.display = 'block'; 
                    } else {
                        // 3. Oculta el mensaje de error si coinciden
                        errorMsg.style.display = 'none';
                    }
                });
                
                // Ocultar el mensaje de error mientras escriben
                passNueva.addEventListener('keyup', () => errorMsg.style.display = 'none');
                passConfirmar.addEventListener('keyup', () => errorMsg.style.display = 'none');
            });
        </script>
    </body>
</html>