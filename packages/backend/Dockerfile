FROM node:24.6.0-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --chown=node:node . .

RUN mkdir -p uploads && chown -R node:node uploads

EXPOSE 3000

USER node

CMD ["npm", "start"]