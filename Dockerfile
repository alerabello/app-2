# -------------------------
# Etapa 1: Build com Maven
# -------------------------
  FROM eclipse-temurin:21-jdk-alpine AS builder

  # Diretório de trabalho para build
  WORKDIR /build
  
  # Instala Maven
  RUN apk add --no-cache curl wget tar \
    && MAVEN_VERSION=3.9.6 \
    && wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz
  
  # Copia apenas os arquivos necessários primeiro para aproveitar cache
  COPY pom.xml .
  
  # Baixa dependências antes do código (para aproveitar o cache do Docker)
  RUN mvn dependency:go-offline
  
  # Agora copia o restante do código
  COPY src ./src
  
  # Executa o build da aplicação (sem rodar testes, mas você pode tirar o -DskipTests)
  RUN mvn clean install -DskipTests
  
  # -------------------------
  # Etapa 2: Runtime com JAR
  # -------------------------
  FROM eclipse-temurin:21-jdk-alpine
  
  # Diretório de trabalho para runtime
  WORKDIR /app
  
  # Copia o JAR gerado na etapa anterior
  COPY --from=builder /build/target/*.jar app.jar
  
  # Instala curl para healthcheck
  RUN apk add --no-cache curl
  
  # Expondo a porta do app
  EXPOSE 8081
  
  # Healthcheck padrão Spring Boot
  HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl --fail http://localhost:8081/actuator/health || exit 1
  
  # Comando de execução
  ENTRYPOINT ["java", "-jar", "app.jar"]
  