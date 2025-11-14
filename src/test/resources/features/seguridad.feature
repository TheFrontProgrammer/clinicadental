@seguridad @CP-018 @CP-019 @CP-020
Feature: Gestion de Contrasenas y Seguridad

Background: Setup de Usuarios
# Prepara un usuario para pruebas de cambio de contraseña (CP-019, CP-020)
Given existe un usuario con documento "CP019_DNI", nombre "Test", apellido "Password" y rol "Paciente"
# El usuario debe tener una contraseña inicial válida
And el usuario "CP019_DNI" tiene la contraseña inicial "AntiguaClave!1"

@CP-018
Scenario: CP-018 - Registro Exitoso con Contraseña Segura
Given el sistema de registro de usuarios esta disponible
When intento registrar un nuevo paciente con documento "CP018_DNI" y contraseña "ClaveSegura#2025"
Then la operacion de registro de usuario debe ser "EXITO"
And el sistema debe mostrar el mensaje "Paciente registrado correctamente"

@CP-019
Scenario: CP-019 - Cambio de Contraseña Exitoso con Nueva Contraseña Segura
Given el usuario "CP019_DNI" intenta cambiar su contraseña
When la contraseña actual es "AntiguaClave!1" y la nueva contraseña es "NuevaClave#2026"
Then la operacion de cambio de contraseña debe ser "EXITO"
And la nueva contraseña "NuevaClave#2026" debe ser la contraseña activa para el usuario "CP019_DNI"
And el sistema debe mostrar el mensaje "Contraseña actualizada"

@CP-020
Scenario: CP-020 - Intento de Cambio con Contraseña Inválida (Insegura)
Given el usuario "CP019_DNI" intenta cambiar su contraseña
When la contraseña actual es "AntiguaClave!1" y la nueva contraseña es "claveinvalida"
Then la operacion de cambio de contraseña debe ser "ERROR_SEGURIDAD"
And el sistema debe mostrar el mensaje "La contraseña no cumple con requisitos de seguridad"