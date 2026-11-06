# syntax=docker/dockerfile:1

# ---- Dependências de produção ----
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- Imagem final ----
FROM node:22-alpine
ENV PORT=3000 \
    HOST=0.0.0.0 \
    DB_FILE=/data/db.json
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY servidor ./servidor
COPY scripts ./scripts
COPY estilos ./estilos
COPY paginas ./paginas
# dados/ contém municipios.json (somente leitura) e o db.json usado como
# semente inicial do volume (copiado apenas se o volume ainda estiver vazio).
COPY dados ./dados
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# /data é o ponto de montagem do volume com o banco JSON persistente.
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /data \
    && chown -R node:node /data /app/dados

USER node
EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=5 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/api/saude').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "servidor/server.js"]
