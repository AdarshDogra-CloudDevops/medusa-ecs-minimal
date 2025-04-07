# Stage 1: Build dependencies
FROM node:18-alpine AS builder
WORKDIR /app

# 1. Configure yarn to use temp directory
RUN yarn config set cache-folder /tmp/.yarn-cache

# 2. Install only production dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production --network-timeout 1000000

# 3. Copy all files and build
COPY . .
RUN yarn build

# Stage 2: Create final image
FROM node:18-alpine
WORKDIR /app

# 4. Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

# 5. Runtime configuration
EXPOSE 9000
CMD ["yarn", "start"]
