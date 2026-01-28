# Use puppeteer-node base image (Node.js with Puppeteer dependencies pre-installed)
FROM satantime/puppeteer-node:20-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for TypeScript build)
RUN npm ci

# Copy TypeScript config
COPY tsconfig.json ./

# Copy source code
COPY src/ ./src/

# Build TypeScript
RUN npm run build

# Remove dev dependencies to reduce image size (optional but recommended)
RUN npm prune --production

# Expose port
EXPOSE 3000

# Run the server
CMD ["npm", "start"]
