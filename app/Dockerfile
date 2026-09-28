# ─── Stage 1: build das dependências ─────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copia apenas os arquivos de dependência primeiro (aproveita cache do Docker)
COPY package.json ./

# Instala somente dependências de produção
RUN npm install --omit=dev

# ─── Stage 2: imagem final ────────────────────────────────────────────────────
FROM node:20-alpine

WORKDIR /app

# Copia as dependências já instaladas do stage anterior
COPY --from=builder /app/node_modules ./node_modules

# Copia o código-fonte da aplicação
COPY package.json ./
COPY src/ ./src/

# Cria usuário não-root para execução segura
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["node", "src/index.js"]
