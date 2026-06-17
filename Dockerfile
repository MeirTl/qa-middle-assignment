FROM mcr.microsoft.com/playwright:v1.61.0-noble

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

ENV CI=true

CMD ["sh", "-c", "npm run test:api && npm run test:e2e"]
