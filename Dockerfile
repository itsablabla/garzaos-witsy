FROM node:22-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --ignore-scripts --no-audit --no-fund

COPY . .
RUN npx patch-package && npm run build:renderer:web

FROM nginx:alpine
COPY --from=builder /app/.vite/renderer/main_window /usr/share/nginx/html
EXPOSE 80
