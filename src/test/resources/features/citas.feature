
@citas
Feature: Gestión de Citas (CP-013 a CP-017)

Background: Preparación del entorno de prueba de citas
Given el sistema cuenta con un Paciente Jonathan Rujel con DNI "DNIJR01" y un Odontologo Daniel Valdivia con DNI "DNIDV01"

@CP-013 @RegistroValido
Scenario: CP-013 - Registro de cita válida
When el paciente Jonathan Rujel solicita una cita con Daniel Valdivia el "2025-09-15" a las "10:00"
Then la operacion de registro de cita debe ser exitosa y mostrar el mensaje "Cita reservada con éxito"
And la cita debe existir en la base de datos con el estado "PENDIENTE"

@CP-014 @HorarioOcupado
Scenario: CP-014 - Intento de cita en horario ocupado (Colision)
Given existe una cita previa registrada para Daniel Valdivia el "2025-09-15" a las "10:00"
When el paciente Jonathan Rujel solicita una cita con Daniel Valdivia el "2025-09-15" a las "10:00"
Then la operacion de registro de cita debe fallar por disponibilidad y mostrar el mensaje "Horario no disponible"
And solo debe existir una cita para Daniel Valdivia el "2025-09-15" a las "10:00"

@CP-015 @Reprogramacion
Scenario: CP-015 - Reprogramar cita existente
Given existe una cita registrada para Jonathan Rujel con Daniel Valdivia el "2025-09-16" a las "10:00"
When el paciente reprograma su cita existente para el "2025-09-16" a las "11:00"
Then la operacion de reprogramacion debe ser exitosa y mostrar el mensaje "Cita reprogramada"
And la cita debe tener la nueva fecha "2025-09-16" y hora "11:00"

@CP-016 @Cancelacion
Scenario: CP-016 - Cancelar cita
Given existe una cita registrada para Jonathan Rujel con Daniel Valdivia el "2025-09-17" a las "10:00"
When el paciente Jonathan Rujel cancela su cita con el motivo "Cambio de fecha sin disponibilidad"
Then la operacion de cancelacion debe ser exitosa y mostrar el mensaje "Cita cancelada"
And la cita debe tener el estado "CANCELADA" y el motivo de cancelacion "Cambio de fecha sin disponibilidad"

@CP-017 @Consulta
Scenario: CP-017 - Consulta de citas por paciente
Given existen 3 citas registradas para el paciente Jonathan Rujel
When el usuario busca las citas del paciente por el nombre "Jonathan" y apellido "Rujel"
Then se debe obtener una lista con 3 citas en el resultado de la busqueda