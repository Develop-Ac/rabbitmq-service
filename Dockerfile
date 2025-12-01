# syntax=docker/dockerfile:1

FROM python:3.12-slim AS base

# Evita criação de .pyc e deixa logs mais “live”
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Cria diretório de trabalho
WORKDIR /app

# Instala dependências do sistema (se precisar de algo adicional, adiciona aqui)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ==== Dependências Python ====
# Se você tiver um requirements.txt, descomente esse bloco
# e remova o bloco logo abaixo de "INSTALAÇÃO DIRETA"

# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# ==== INSTALAÇÃO DIRETA (sem requirements.txt) ====
# Se preferir, pode usar esse bloco direto:
RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    pika

# Copia todo o código para dentro da imagem
COPY . .

# Porta usada pelo uvicorn
EXPOSE 8000

# Comando para subir a API
# Se o arquivo NÃO for main.py, altere "main:app" para <arquivo>:<instância_fastapi>
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
