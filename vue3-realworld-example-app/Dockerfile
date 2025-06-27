# Build stage for Vue3 frontend (S3 deployment)
FROM node:18-alpine as build-stage

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build arguments for environment
ARG BUILD_ENV=production
ARG VITE_API_HOST
ARG VITE_API_BASE_URL
ARG VITE_APP_TITLE="RealWorld"
ARG VITE_APP_DESCRIPTION="RealWorld example app"
ARG VITE_DEBUG=false
ARG VITE_LOG_LEVEL=error

# Set environment variables for build
ENV NODE_ENV=production
ENV VITE_API_HOST=${VITE_API_HOST}
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
ENV VITE_APP_TITLE=${VITE_APP_TITLE}
ENV VITE_APP_DESCRIPTION=${VITE_APP_DESCRIPTION}
ENV VITE_DEBUG=${VITE_DEBUG}
ENV VITE_LOG_LEVEL=${VITE_LOG_LEVEL}
ENV VITE_ENABLE_DEV_TOOLS=false
ENV VITE_ENABLE_MOCK_API=false

# Build the application
RUN pnpm build

# Output stage - just the built files (for S3 upload)
FROM scratch as output
COPY --from=build-stage /app/dist /dist
