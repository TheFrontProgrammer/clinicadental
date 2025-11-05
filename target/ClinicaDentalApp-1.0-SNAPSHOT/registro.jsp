<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Crear Cuenta de Paciente - Sonrisa Plena</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/autenticacion/registro-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
</head>
<body>

    <div class="registro-page-container">
        
        <header class="top-nav">
            <div class="logo">
                <i class="fa-solid fa-tooth"></i>
                <span>Sonrisa Plena</span>
            </div>
            <div class="user-actions">
                <a href="index.jsp" class="btn-login">
                    <i class="fa-solid fa-arrow-right-to-bracket"></i>
                    <span>Iniciar Sesión</span>
                </a>
            </div>
        </header>

        <div class="form-container-background">
            <div class="registro-card">
                <div class="card-header">
                    <h2>Crear cuenta de Paciente</h2>
                </div>
                
                <form action="registro" method="post" class="registro-form">
            
                    <%-- Bloque para mostrar mensajes de error del servidor --%>
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null) {
                    %>
                    <div class="alert-error"><%= error %></div>
                    <%
                        }
                    %>
                    
                    <%-- Fila 1: Nombre y Apellido --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="nombre">Nombre(s) *</label>
                            <input type="text" id="nombre" name="nombre" placeholder="Ingresa tu nombre" required>
                        </div>
                        <div class="form-group">
                            <label for="apellido">Apellido(s) *</label>
                            <input type="text" id="apellido" name="apellido" placeholder="Ingresa tu apellido" required>
                        </div>
                    </div>

                    <%-- Fila 2: Email y Teléfono --%>
                    <div class="form-row">
                         <div class="form-group">
                            <label for="email">Correo electrónico *</label>
                            <input type="email" id="email" name="email" placeholder="tu.correo@ejemplo.com" required>
                        </div>
                        <div class="form-group">
                            <label for="telefono">Teléfono</label>
                            <input type="tel" id="telefono" name="telefono" placeholder="Ej: 987654321">
                        </div>
                    </div>

                    <%-- Fila 3: Fecha de Nacimiento y Género --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="fechaNacimiento">Fecha de Nacimiento</label>
                            <input type="date" id="fechaNacimiento" name="fecha_nacimiento">
                        </div>
                        <div class="form-group">
                            <label for="genero">Género</label>
                            <select id="genero" name="genero">
                                <option value="" disabled selected>Seleccionar...</option>
                                <option value="M">Masculino</option>
                                <option value="F">Femenino</option>
                                <option value="O">Otro</option>
                            </select>
                        </div>
                    </div>
                    
                    <%-- Fila 4: Dirección --%>
                    <div class="form-group full-width">
                        <label for="direccion">Dirección</label>
                        <input type="text" id="direccion" name="direccion" placeholder="Ej: Av. Principal 123, tu ciudad">
                    </div>

                    <hr class="form-divider">

                    <%-- Fila 5: DNI --%>
                    <div class="form-group full-width">
                        <label for="doc">Número de Documento (DNI) *</label>
                        <%-- CORRECCIÓN: Se cambió pattern="\\d{8}" por pattern="\d{8}" --%>
                        <input type="text" id="doc" name="documento_identidad" placeholder="Tu DNI de 8 dígitos" required maxlength="8" pattern="\d{8}" title="El DNI debe tener 8 dígitos.">
                    </div>
        
                    <%-- Fila 6: Contraseñas --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="pass">Contraseña *</label>
                            <input type="password" id="pass" name="password" required>
                            <span class="password-hint">Mín. 8 caracteres, 1 mayús., 1 núm., 1 esp.</span>
                        </div>
                        <div class="form-group">
                            <label for="confirm_pass">Confirmar contraseña *</label>
                            <input type="password" id="confirm_pass" name="confirm_password" required>
                        </div>
                    </div>
                    
                    <%-- Fila 7: Términos y Botón --%>
                    <div class="form-checkbox-group">
                        <input type="checkbox" id="accept_terms" name="accept_terms" required>
                        <label for="accept_terms">Acepto los <a href="#" class="link-inline">Términos y Condiciones</a> y la <a href="#" class="link-inline">Política de Privacidad</a></label>
                    </div>

                    <button type="submit" class="btn-register">Registrarme</button>
        
                    <div class="login-link">
                        <span>¿Ya tienes cuenta? <a href="index.jsp" class="link-primary">Inicia sesión aquí</a></span>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>