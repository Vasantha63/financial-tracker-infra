# Dockerfile
# Multi-stage build — Production ready

# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY app/ .
RUN echo '{"name":"financial-tracker","version":"1.0.0"}' > package.json

# Stage 2: Production — Nginx తో serve చేయడం
FROM nginx:alpine
COPY --from=builder /app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]