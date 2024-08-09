# Stage 1: Build the entire Maven project
FROM maven:3.8.4-openjdk-17-slim AS build
WORKDIR /app

# Copy the entire Maven project
COPY . .

# Run a clean install at the project root. This will build all modules.
RUN mvn clean install -DskipTests

# No need to change directory, already in the project root
WORKDIR /app/pizza-shop-web-receiver
RUN mvn package -DskipTests

RUN ls -la /app/
RUN ls -la /app/pizza-shop-web-receiver/
RUN ls -la /app/pizza-shop-web-receiver/target/

# Stage 2: Setup the runtime environment
FROM openjdk:17-slim AS runtime
WORKDIR /usr/src/app

# Copy the built jar file from the 'build' stage
COPY --from=build /app/pizza-shop-web-receiver/target/pizza-shop-web-receiver-*.jar ./

# Expose the port the application uses
EXPOSE 10010

# Command to run the application using a shell command to handle the wildcard
CMD java -jar $(ls pizza-shop-web-receiver-*.jar)