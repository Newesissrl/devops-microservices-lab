# Test stage
FROM node:24.6.0-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN CI=true npm test -- --coverage --watchAll=false

# Build stage
FROM node:24.6.0-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN CI=false npm run build

# Production stage
FROM nginx:alpine AS production

COPY --from=builder /app/build /usr/share/nginx/html
COPY --from=builder /app/public/config.js /usr/share/nginx/html/config.js

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]