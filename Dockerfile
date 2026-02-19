# Stage 1: Build
FROM debian:latest AS build

# Instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter SDK 3.16.0 (ou superior)
RUN git clone https://github.com/flutter/flutter.git -b 3.16.0 /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Desativar aviso de root do Flutter e preparar ferramentas
RUN git config --global --add safe.directory /usr/local/flutter
RUN flutter config --no-analytics
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# Executar comandos de build
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
