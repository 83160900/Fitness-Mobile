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
FROM nginx:stable-alpine
# Copiar os arquivos gerados no build para a pasta padrão do Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expor a porta 80 (padrão absoluto do Railway/Docker)
EXPOSE 80

# Comando para rodar o Nginx na porta 80 e garantir que ele responda ao Railway
CMD ["nginx", "-g", "daemon off;"]
