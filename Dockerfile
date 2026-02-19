# Etapa de Build
FROM fedora:37 AS build-env

# Instalar dependências básicas
RUN dnf install -y git wget unzip which xz mesa-libGLU

# Instalar Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Flutter
RUN flutter doctor -v
RUN flutter config --enable-web

# Copiar arquivos do projeto
WORKDIR /app
COPY . .

# Obter dependências e fazer o build para Web
RUN flutter pub get
RUN flutter build web --release

# Etapa de Execução (Servidor Web Leve)
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Configurar porta do Railway
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
