FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

USER node

EXPOSE 3000
CMD ["node", "src/app.js"]
