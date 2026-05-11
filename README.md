# DemoCompany Identity Generator

Proyecto Python 3.13 reproducible con Docker Compose y uv.

## Inicio

```sh
make bootstrap
```

El `Makefile` crea todos los archivos del proyecto e inicializa git. No construye,
no ejecuta lint/tests y no genera archivos de salida.

Comandos separados:

```sh
make bootstrap-verify
make bootstrap-run
```

`make bootstrap-verify` construye la imagen, genera `uv.lock`, formatea, ejecuta lint y
tests. `make bootstrap-run` consulta usuarios, genera correos corporativos y produce:

- `output/contractors.csv`
- `logs/app.log`

## Portal web

```sh
make web-install
make web-dev
```

El portal Next.js permite consultar usuarios, generar emails corporativos y ver el log
en tiempo real. Tanto el portal como los botones ejecutan sus procesos dentro de Docker
Compose.

## Variables sensibles

El proyecto crea un `.env` local y un `.env.example` con estos parametros:

- `DEMOCOMPANY_USERS_URL`
- `DEMOCOMPANY_DOMAIN`
- `DEMOCOMPANY_TIMEOUT_SECONDS`

## Criterio funcional

La aplicacion consume `https://jsonplaceholder.typicode.com/users` y genera correos
corporativos `@democompany.com`. No genera tokens JWT ni hashes/encriptados del email.

Columnas del CSV:

- `full_name`
- `phone`
- `original_email`
- `company`
- `city`
- `corporate_email`
