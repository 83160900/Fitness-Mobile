# Etapa 1: Compilação (Usando imagem oficial da comunidade com Flutter já instalado)
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Garantir permissões e compilar para web
RUN flutter pub get
RUN flutter build web --release

# Etapa 2: Entrega (Servidor web ultra-leve)
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Expor porta padrão
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
