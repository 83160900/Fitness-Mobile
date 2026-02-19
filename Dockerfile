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

# Comando para injetar a porta do Railway dinamicamente e rodar o Nginx
CMD ["sh", "-c", "sed -i 's/listen       80;/listen       '\"$PORT\"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
