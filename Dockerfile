FROM node:21-alpine

WORKDIR /app

COPY /basic-app/package.json .

RUN npm install

COPY /basic-app/ .

CMD ["npm", "start"]