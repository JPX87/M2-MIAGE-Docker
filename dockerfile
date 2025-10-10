############################################
# Étape 1 : Builder avec Maven (multi-stage)
############################################
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# 1️⃣ Copier uniquement les fichiers nécessaires à la résolution des dépendances
COPY pom.xml .

# Télécharger les dépendances avant de copier le code (meilleur cache)
RUN mvn dependency:go-offline

# 2️⃣ Copier le reste du projet (le code source)
COPY src ./src

# Compiler et packager (skip tests pour accélérer)
RUN mvn clean package -DskipTests

################################
# Étape 2 : Image finale allégée
################################
FROM gcr.io/distroless/java17-debian12 AS runtime
WORKDIR /app


# Copier uniquement le jar final
COPY --from=build /app/target/*.jar app.jar

# Exposer le port 8080
EXPOSE 8080

# Commande de lancement
ENTRYPOINT ["java","-jar","/app/app.jar"]