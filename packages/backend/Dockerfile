# Test stage
FROM node:24.6.0-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test

# Production stage
FROM node:24.6.0-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --chown=node:node . .
RUN mkdir -p uploads && chown -R node:node uploads
EXPOSE 3000
USER node
CMD ["npm", "start"]