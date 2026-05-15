# Prompt Para Agente de IA

## Prompt

```text
Actua como un ingeniero senior full stack. Necesito que construyas desde cero un proyecto
reproducible con Python 3.13, Docker Compose, uv y Next.js.

El proyecto debe permitir consultar usuarios desde un endpoint externo, mostrar la
informacion en un portal web, generar correos corporativos, descargar la tabla en CSV y
tambien poder ejecutarse desde CLI.

No incluyas informacion de empresas reales, procesos de seleccion, nombres de clientes ni
datos sensibles. Usa nombres genericos y neutrales para variables, documentacion y codigo.

## Objetivo Funcional

La aplicacion debe:

1. Consumir usuarios desde un endpoint HTTP configurable.
2. Parsear y validar los campos relevantes del usuario.
3. Mostrar los usuarios consultados en una tabla dentro de un portal web.
4. Generar emails corporativos usando un dominio configurable.
5. Evitar emails corporativos demasiado cortos.
6. Permitir descargar la tabla visible en formato CSV desde el navegador.
7. Mostrar en la web solo el log de la accion ejecutada en la sesion actual.
8. Mantener tambien una ejecucion CLI que genere un CSV.

## Reglas Importantes

- No guardar secretos en el repositorio.
- Crear `.env.example` para documentar variables.
- Crear `.env` local con valores de ejemplo.
- Agregar `.env`, `node_modules`, `.next`, `logs`, `output`, caches y artefactos a `.gitignore`.

## Datos De Entrada

El endpoint por defecto debe ser:

```env
DEMOCOMPANY_USERS_URL=https://jsonplaceholder.typicode.com/users
```

Cada usuario externo debe mapearse desde el JSON del endpoint con estos datos:

- `id`
- `name`
- `username`
- `email`
- `phone`
- `company.name`
- `address.city`

## Variables De Entorno

Crear `.env.example` y `.env` con:

```env
DEMOCOMPANY_USERS_URL=https://jsonplaceholder.typicode.com/users
DEMOCOMPANY_DOMAIN=democompany.com
DEMOCOMPANY_TIMEOUT_SECONDS=10
```

La aplicacion Python debe cargar estas variables usando `python-dotenv`.

## Regla De Generacion De Emails

Crear una funcion que genere emails corporativos a partir del nombre completo y el dominio.

Reglas:

1. Normalizar texto a ASCII.
2. Convertir a minusculas.
3. Eliminar caracteres no alfanumericos.
4. Usar `inicial + apellido` cuando el resultado tenga al menos 5 caracteres.
5. Si el resultado queda por debajo de 5 caracteres, agregar letras del primer nombre y
   mantener el apellido al final.
6. Si el email generado se repite, agregar un consecutivo numerico antes del dominio.

Ejemplos esperados:

- `Leanne Graham` -> `lgraham@democompany.com`
- `John Doe` -> `jodoe@democompany.com`
- `Johana Doe` -> `jodoe1@democompany.com` si `jodoe` ya existe
- `Nicholas Runolfsdottir V` -> `nichv@democompany.com`

## Salida CSV

El CSV debe tener exactamente estas columnas:

- `full_name`
- `phone`
- `original_email`
- `company`
- `city`
- `corporate_email`


## Stack Backend

Usar Python 3.13 con:

- `httpx`
- `python-dotenv`
- `pytest`
- `pytest-cov`
- `respx`
- `ruff`
- `hatchling`
- `uv`

Configurar `pyproject.toml` con:

- paquete en `src/<package_name>`
- script CLI llamado `democompany-identities`
- ruff
- pytest con cobertura

## Estructura Python Esperada

Crear una estructura similar a:

```text
src/democompany_identities/
|-- __init__.py
|-- __main__.py
|-- cli.py
|-- client.py
|-- config.py
|-- csv_exporter.py
|-- emailing.py
|-- logging_config.py
|-- models.py
|-- portal_api.py
|-- service.py
|-- transform.py
`-- web_actions.py
```

Responsabilidades:

- `config.py`: cargar settings desde `.env`.
- `models.py`: dataclasses para usuario externo e identidad generada.
- `client.py`: cliente HTTP para consumir usuarios.
- `emailing.py`: normalizacion y generacion de emails.
- `transform.py`: convertir usuarios externos en registros con email corporativo.
- `csv_exporter.py`: escribir CSV.
- `logging_config.py`: configurar logger CLI.
- `service.py`: orquestar flujo CLI.
- `cli.py`: parsear argumentos y ejecutar el flujo.
- `web_actions.py`: acciones usadas por el portal web y logs de sesion.
- `portal_api.py`: API HTTP simple para que Next.js invoque acciones Python.

## API Python Para El Portal

Crear una API Python ligera con libreria estandar, usando `http.server` o equivalente
sin agregar frameworks innecesarios.

Endpoints:

- `POST /users`: consulta usuarios, guarda `output/users.json` y retorna usuarios + log de sesion.
- `POST /emails`: genera emails, guarda `output/contractors.json` y `output/contractors.csv`, retorna identidades + log de sesion.
- `GET /logs`: retornar `{ "logs": "" }`, porque el portal no debe leer el archivo `.log`.

Importante:

- El log mostrado por la web debe ser solo el de la accion actual.
- No debe hacer polling automatico del archivo `logs/app.log`.
- El CLI si puede seguir escribiendo `logs/app.log`.

## Portal Web Next.js

Crear un portal Next.js con App Router.

Pantalla principal:

- Titulo: `Portal de identidades`.
- Boton `Ejecutar scripts`.
- Boton `Generar emails`.
- Contadores de usuarios consultados y emails generados.
- Tabla con:
  - Nombre
  - Telefono
  - Email original
  - Empresa
  - Ciudad
  - Email corporativo
- Boton `Descargar CSV`.
- Panel de log de sesion.

Comportamiento:

1. Al abrir la pagina, el log debe estar vacio o mostrar un texto neutral.
2. Al presionar `Ejecutar scripts`, llamar al backend y mostrar usuarios.
3. Al presionar `Generar emails`, llamar al backend y mostrar emails corporativos.
4. El log debe reemplazarse con el log de la accion actual.
5. El log no debe actualizarse automaticamente.
6. El boton de descarga CSV debe estar deshabilitado si no hay datos.
7. Si hay emails generados, descargar `contractors.csv`.
8. Si solo hay usuarios consultados, descargar `users.csv`.

Estilo visual:

- Interfaz limpia y agradable.
- Layout tipo dashboard.
- Tabla legible.
- Botones claros.
- Panel de log con fondo oscuro.
- Responsive para pantallas pequenas.
- Evitar landing page; la pantalla inicial debe ser la herramienta usable.

Hidratacion:

- En `app/layout.tsx`, usar `<html lang="es" suppressHydrationWarning>` para evitar warnings
  causados por extensiones del navegador que agregan atributos al HTML.

## Rutas API Next.js

Crear rutas Next.js que llamen a la API Python:

- `app/api/users/route.ts`
- `app/api/emails/route.ts`
- `app/api/logs/route.ts`

Las rutas deben usar una variable:

```env
PYTHON_API_URL=http://api:8000
```

Dentro de Docker Compose, Next.js debe llamar a `http://api:8000`.

## Docker

Crear `Dockerfile` para Python:

- Base: `ghcr.io/astral-sh/uv:python3.13-bookworm-slim`
- Workdir: `/app`
- Copiar `pyproject.toml`, `README.md`, `src`, `tests`
- Ejecutar `uv sync --all-extras --dev`
- `ENTRYPOINT []`
- `CMD ["uv", "run", "democompany-identities"]`

Crear `docker-compose.yml` con servicios:

1. `app`
   - backend Python para CLI/tests
   - monta el repo en `/app`
   - usa `.env`
   - volumen de cache uv

2. `api`
   - usa la imagen Python
   - comando: `uv run python -m democompany_identities.portal_api`
   - expone puerto `8000`
   - usa `.env`

3. `web`
   - imagen `node:22-bookworm-slim`
   - workdir `/app`
   - monta el repo
   - usa `.env`
   - variable `PYTHON_API_URL=http://api:8000`
   - depende de `api`
   - expone puerto `3000`
   - comando: `npm run dev -- --hostname 0.0.0.0`

## Makefile

Crear un `Makefile` con targets:

- `help`
- `bootstrap`
- `boostrap` como alias por typo
- `project-dirs`
- `scaffold`
- `bootstrap-verify`
- `bootstrap-run`
- `bootstrap-full`
- `build`
- `lock`
- `sync`
- `lint`
- `format`
- `test`
- `run`
- `web-install`
- `web-dev`
- `web-build`
- `logs`
- `shell`
- `clean`

Reglas:

- `make bootstrap` solo debe crear archivos e inicializar git. No debe construir, testear ni ejecutar.
- `make scaffold` debe crear o recrear los archivos del proyecto.
- `make bootstrap-verify` debe construir, bloquear dependencias, formatear, lint y test.
- `make bootstrap-run` debe ejecutar el flujo CLI.
- `make web-install` debe instalar dependencias Next.js dentro del contenedor web.
- `make web-dev` debe levantar `web` y `api`.
- `make web-build` debe compilar Next.js.

## Tests

Crear pruebas para:

- generacion de email normal
- generacion de email con minimo 5 caracteres
- deduplicacion de emails
- transformacion de usuarios
- exportacion CSV
- cliente HTTP con `respx`

Casos obligatorios:

- `John Doe` -> `jodoe@democompany.com`
- `Johana Doe` -> `jodoe1@democompany.com` cuando `jodoe` ya existe
- `Nicholas Runolfsdottir V` -> `nichv@democompany.com`

Validar con:

```sh
docker compose run --rm --build app uv run pytest
```

## README

Crear un README completo que incluya:

- objetivo
- requisitos
- configuracion
- ejecucion CLI
- ejecucion web
- flujo paso a paso del portal
- regla de generacion de emails
- estructura del proyecto
- componentes principales
- comandos Make
- pruebas
- salidas generadas
- notas de seguridad y privacidad

Si existe una carpeta `img/`, incluir evidencias visuales:

- `img/PaginaWeb-Limpia.png`
- `img/PaginaWeb-Script.png`
- `img/PaginaWeb-Emails.png`

## Validaciones Finales

Antes de terminar, ejecutar:

```sh
docker compose config
docker compose run --rm --build app uv run pytest
docker compose run --rm web npm install
docker compose run --rm web npm run build
docker compose run --rm web npm audit --omit=dev
```

El resultado esperado:

- Compose valido.
- Tests Python pasando.
- Build Next.js correcto.
- Sin vulnerabilidades de produccion en npm audit.

## Entrega Esperada

Al finalizar, entrega un resumen con:

- archivos principales creados
- comandos para ejecutar CLI
- comandos para ejecutar portal web
- comandos de validacion
- notas de privacidad
```

## Como Usar Este Prompt

1. Copie el bloque completo del prompt.
2. Pegue el contenido en la IA que usara para generar el proyecto.
3. Pida que implemente los archivos directamente.
4. Solicite que ejecute las validaciones finales.
5. Revise que el resultado no contenga referencias a empresas reales ni datos sensibles.

## Recomendacion De Nombre De Repositorio

Use un nombre generico para no revelar informacion del proceso:

- `contractor-identity-portal`
- `identity-email-generator`
- `user-email-provisioning-tool`
- `identity-processing-dashboard`

Recomendado:

```text
contractor-identity-portal
```
