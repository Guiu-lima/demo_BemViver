#!/bin/sh
set -e

# Semeia o banco no volume apenas na primeira execução.
# Se /data/db.json já existe, NUNCA é sobrescrito.
if [ ! -f "$DB_FILE" ]; then
  echo "[entrypoint] Banco não encontrado em $DB_FILE; copiando semente inicial."
  mkdir -p "$(dirname "$DB_FILE")"
  cp /app/dados/db.json "$DB_FILE"
else
  echo "[entrypoint] Banco existente mantido em $DB_FILE."
fi

exec "$@"
