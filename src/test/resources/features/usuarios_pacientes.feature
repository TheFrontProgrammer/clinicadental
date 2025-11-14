Feature: Gestion de Pacientes y Usuarios Asociados (CP-006 a CP-012)
  Como Administrador, quiero gestionar el CRUD de pacientes, asegurando la unicidad
  de datos (DNI/Email) y la integridad transaccional en todas las operaciones.

  Background: Preparación de la base de datos
    Given que la base de datos está disponible y limpia para el test
    # Este paso es manejado por el método general de la clase Steps.

  # CP-006: Registro Transaccional Exitoso
  @CP-006
  Scenario: CP-006 - Registro de Paciente y Usuario de forma Transaccional
    Given hay un nuevo paciente con DNI "45678901" y password "PassNueva123$"
    When el administrador intenta registrar al paciente
    Then el registro de usuario es exitoso
    And la cuenta de usuario "45678901" existe en la BD

  # CP-007: Unicidad (DNI/Email duplicado)
  @CP-007
  Scenario: CP-007 - Intento de Registro con DNI o Email duplicado
    Given existe un paciente con DNI "11111111" ya registrado
    And hay un nuevo paciente con DNI "11111111" (duplicado)
    When el administrador intenta registrar al paciente
    Then el registro debe fallar con un error de unicidad

  # CP-008: Modificación Segura (no permite cambiar DNI/Password)
  @CP-008
  Scenario: CP-008 - Modificación de datos personales de un paciente
    Given existe un paciente con ID 99 con nombre "Ana" y DNI "88888888"
    When el usuario actualiza el nombre del paciente ID 99 a "Anabel"
    Then la actualización de datos personales es exitosa
    And el DNI "88888888" y la contraseña del usuario ID 99 no han sido alterados

  # CP-009: Eliminación Transaccional (Citas -> Paciente -> Usuario)
  @CP-009
  Scenario: CP-009 - Eliminación Física Transaccional de Paciente con dependencias
    Given existe un paciente con ID 100 que tiene una cita asociada y un usuario
    When el administrador elimina al paciente con ID 100
    Then la eliminación es exitosa
    And la cita asociada ya no existe en la tabla Citas
    And el registro de usuario con ID 100 ya no existe en la tabla Usuarios

  # CP-010: Búsqueda exacta por DNI
  @CP-010
  Scenario: CP-010 - Búsqueda de un paciente por Documento de Identidad (DNI)
    Given existe un paciente con DNI "11122233" en la BD
    When se realiza una búsqueda por DNI "11122233"
    Then el sistema debe retornar exactamente a ese paciente

  # CP-011: Búsqueda por Criterio Parcial (Nombre/Apellido)
  @CP-011
  Scenario: CP-011 - Búsqueda de pacientes por Criterio (Coincidencia Parcial en Nombre o Apellido)
    Given existen pacientes llamados "Ana Lopez" y "Juan Loaiza" en la BD
    When se realiza una búsqueda por el criterio "Lo"
    Then el sistema debe retornar 2 pacientes
    And la lista de pacientes contiene a "Ana Lopez"

  # CP-012: Búsqueda por Criterio Completo (Nombre/Apellido)
  @CP-012
  Scenario: CP-012 - Búsqueda de pacientes por Criterio (Coincidencia Completa en Apellido)
    Given existen pacientes llamados "Marta García" y "Pedro García" en la BD
    When se realiza una búsqueda por el criterio "García"
    Then el sistema debe retornar 2 pacientes
    And la lista de pacientes contiene a "Marta García"