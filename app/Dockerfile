# syntax=docker/dockerfile:1
###############################################################################
# ETAPA 1: cache de dependencias
###############################################################################
FROM denoland/deno:alpine-1.44.4 AS builder
WORKDIR /app

# Copiamos todo el código de la carpeta app
COPY . .

# Cachea imports de Deno (main.ts debe ser el punto de entrada)
RUN deno cache main.ts

###############################################################################
# ETAPA 2: imagen final ligera
###############################################################################
FROM denoland/deno:alpine-1.44.4
WORKDIR /app

# Copiamos sólo lo cacheado y el código
COPY --from=builder /app .

# Ejecutar como usuario 'deno' por seguridad
USER deno

# Puerto por defecto de tu servidor Deno
EXPOSE 8000

# Arranca la aplicación con permisos de red y acceso a ENV
CMD ["run", "--allow-net", "--allow-env", "main.ts"]
