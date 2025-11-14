Feature: Autenticación de Inicio de sesión

Background: Setup de Usuarios de Prueba
# Nota: Se asume que en el código de Hooks/Setup se crean estos usuarios
# 1. Usuario 'Admin' (DNI: 99999999, Pass: Admin.2025!) con rol Administrador.
# 2. Usuario 'Bloqueado' (DNI: 87654321, Pass: Bloq.2025!) con rol Paciente, ya bloqueado (intentos_fallidos = 3).
# 3. Usuario 'Paciente' (DNI: 12345678, Pass: Rujel#2025r92!) con rol Paciente, NO bloqueado.

@CP-001
Scenario: CP-001 - Login exitoso con credenciales válidas
Given un usuario registrado con DNI "12345678" y contraseña "Rujel#2025r92!"
When el usuario intenta iniciar sesión
Then el estado de validación del login es LOGIN_EXITOSO
And la sesión contiene al usuario "12345678" con rol "Paciente"
And la fecha de ultimo login para el DNI "12345678" ha sido actualizada

@CP-002
Scenario: CP-002 - Login fallido por usuario no encontrado
Given un usuario con DNI "00000000" y contraseña "CualquierPass1!"
When el usuario intenta iniciar sesión
Then el estado de validación del login es USUARIO_NO_ENCONTRADO

@CP-003
Scenario: CP-003 - Login fallido por contraseña incorrecta
Given un usuario registrado con DNI "12345678"
When el usuario intenta iniciar sesión con contraseña incorrecta "WrongPass!"
Then el estado de validación del login es PASSWORD_INCORRECTO
And los intentos fallidos para el DNI "12345678" aumentan en la base de datos

@CP-004
Scenario: CP-004 - Bloqueo de cuenta por intentos fallidos
Given un usuario registrado con DNI "99999999" con 2 intentos fallidos
When el usuario intenta iniciar sesión por tercera vez con contraseña incorrecta "BadPass3!"
Then el estado de validación del login es CUENTA_BLOQUEADA
And el campo 'bloqueado' es TRUE para el DNI "99999999"

@CP-005
Scenario: CP-005 - Login fallido a cuenta ya bloqueada
Given un usuario con DNI "87654321" que tiene el estado 'bloqueado' en TRUE
When el usuario intenta iniciar sesión con contraseña "Bloq.2025!"
Then el estado de validación del login es CUENTA_BLOQUEADA