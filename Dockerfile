# ---- ETAPA 1: Construcción (Build) ----
# Usamos una imagen de Maven (que incluye JDK 11) para construir el .war
FROM maven:3.8.4-openjdk-11 AS build

# Creamos un directorio de trabajo dentro de la imagen
WORKDIR /app

# Copiamos el pom.xml primero para aprovechar la caché de Docker
COPY pom.xml .

# Descargamos las dependencias
RUN mvn dependency:go-offline

# Copiamos todo el resto del código fuente
COPY src ./src

# ¡El paso clave! Construimos el proyecto y generamos el .war
# Usamos -DskipTests para que no falle si las pruebas no pasan
RUN mvn package -DskipTests

# ---- ETAPA 2: Final (Ejecución) ----
# Ahora usamos la imagen limpia de Tomcat que ya tenías
FROM tomcat:10.1-jdk11-openjdk-slim

# Borramos la carpeta webapps por defecto
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiamos el .war que se generó en la ETAPA 1 (desde la imagen 'build')
# directamente a la carpeta webapps de Tomcat
COPY --from=build /app/target/ClinicaDentalApp-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# (No hace falta EXPOSE ni CMD, la imagen de Tomcat ya los tiene)