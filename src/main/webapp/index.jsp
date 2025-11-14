<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Iniciar Sesión - Clínica Dental</title>
    <link rel="stylesheet" href="autenticacion/login-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
</head>
<body>

    <div class="login-container">

        <div class="login-branding">
            <div class="branding-logo">
                <i class="fa-solid fa-tooth"></i>
                <h1>Sonrisa Plena</h1>
                <p>Cuidamos tu sonrisa con la mejor tecnología y un equipo de profesionales apasionados.</p>
            </div>
        </div>

        <div class="login-form-wrapper">
            <div class="login-box">
                <h2>Bienvenido de Nuevo</h2>
                <p class="subtitle">Ingresa tus credenciales para acceder</p>
                
                <form action="login" method="post">
                    <div class="form-group">
                        <label for="doc">Documento de Identidad</label>
                        <input type="text" id="doc" name="documento_identidad" required autofocus>
                    </div>
                    
                    <div class="form-group">
                        <label for="pass">Contraseña</label>
                        <input type="password" id="pass" name="password" required>
                    </div>
                                 
                    <input type="submit" value="Ingresar">
                </form>
                
                <div class="register-link">
                    <span>¿No tienes una cuenta? <a href="registro.jsp">Regístrate aquí</a></span>
                </div>
                
                <%-- Bloque para mostrar mensajes de error --%>
                <%
                    String error = (String) request.getAttribute("mensajeError");
                    if (error != null) {
                %>
                <p class="error"><%= error %></p>
                <%
                    }
                %>

                <%-- Bloque para mostrar mensaje de registro exitoso --%>
                <%
                    String registroExitoso = request.getParameter("registro");
                    if (registroExitoso != null && registroExitoso.equals("exitoso")) {
                %>
                <p class="success">¡Registro exitoso! Por favor, inicia sesión.</p>
                <%
                    }
                %>
            </div>
        </div>
        
    </div>

</body>
</html>