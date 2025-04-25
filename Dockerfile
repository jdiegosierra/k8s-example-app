FROM denoland/deno:alpine-2.2.11 AS builder

WORKDIR /app

COPY ./app .

RUN deno cache --lock=deno.lock main.ts


FROM denoland/deno:alpine-2.2.11

WORKDIR /app

COPY --from=builder --chown=deno:deno /app .

USER deno

CMD ["run", "--allow-net", "--allow-env", "--no-check", "--lock=deno.lock", "main.ts"]
