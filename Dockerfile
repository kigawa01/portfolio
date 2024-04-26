FROM node:20 AS builder
WORKDIR /app
COPY ./ ./
RUN npm ci
RUN npm run build

FROM nginx AS runner
ENV SERVER_NAME _
ENV PORT 80
RUN echo "\n\
    server {\n\
      listen ${PORT};\n\
      server_name ${SERVER_NAME};\n\
    \n\
      location / {\n\
        root /usr/share/nginx/html;\n\
        add_header uri \$uri;\n\
        index /index.html;\n\
        try_files \$uri /index.html;\n\
      }\n\
    } \n\
    " > /etc/nginx/conf.d/server.conf
EXPOSE $PORT
COPY --from=builder /app/dist  /usr/share/nginx/html