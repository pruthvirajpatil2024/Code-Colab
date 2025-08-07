# ----------- Stage 1: Build Frontend -----------
FROM node:18-alpine AS client-builder

WORKDIR /client

COPY client/package*.json ./
RUN npm ci

COPY client/ ./
RUN npm run build


# ----------- Stage 2: Build Backend -----------
FROM node:18-alpine AS server-builder

WORKDIR /server

COPY server/package*.json ./
RUN npm ci

COPY server/ ./
RUN npm run build || true  # only if you have a build step
RUN npm prune --omit=dev


# ----------- Stage 3: Final Production Image -----------
FROM node:18-alpine AS final

WORKDIR /app

# Copy backend
COPY --from=server-builder /server ./

# Copy frontend build into backend public folder (or customize)
COPY --from=client-builder /client/dist ./public

# Expose the backend port
EXPOSE 3000

# Start backend server (Express)
CMD ["npm", "start"]
