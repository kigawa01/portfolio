# ============================================
# Builder Stage
# ============================================
FROM node:20-alpine AS builder
WORKDIR /app

# 1. まず package.json と package-lock.json のみをコピー
COPY package.json package-lock.json ./

# 2. 依存関係をインストール（package*.json が変わらなければキャッシュが効きます）
RUN npm ci

# 3. ソースコードをコピー（これが変わっても npm ci は再実行されない）
COPY . .

# 4. ビルドを実行
RUN npm run build


# ============================================
# Runner Stage
# ============================================
FROM nginx:alpine AS runner
ENV SERVER_NAME _
ENV PORT 80

RUN mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && echo "\
    \
    server {\
      listen ${PORT};\
      server_name ${SERVER_NAME};\
\
      # HTMLファイルのキャッシュ設定 \
      location ~* \.html$ { \
        root /usr/share/nginx/html; \
        expires 1h; \
        add_header Cache-Control \"public, max-age=3600\"; \
      } \
\
      # 静的アセットのキャッシュ設定\
      location ~* \\.(jpg|jpeg|png|gif|ico|svg|webp|avif)$ {\
        root /usr/share/nginx/html;\
        expires 30d;\
        add_header Cache-Control \"public, max-age=2592000\";\
      }\
\
      location ~* \\.(css|js)$ {\
        root /usr/share/nginx/html;\
        expires 7d;\
        add_header Cache-Control \"public, max-age=604800\";\
      }\
\
      location ~* \\.(woff|woff2|ttf|eot|otf)$ {\
        root /usr/share/nginx/html;\
        expires 1y;\
        add_header Cache-Control \"public, max-age=31536000\";\
      }\
\
      location / {\
        root /usr/share/nginx/html;\
        add_header uri \$uri;\
        index /index.html;\
        try_files \$uri /index.html;\
      }\
    }\
    " > /etc/nginx/conf.d/server.conf

EXPOSE ${PORT}
COPY --from=builder /app/dist /usr/share/nginx/html
