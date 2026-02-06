# Use an official Node runtime
FROM node:18-alpine

WORKDIR /app

# Copy package and install
COPY package.json package-lock.json* ./
RUN npm ci --only=production || npm install --only=production

# Copy source
COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
