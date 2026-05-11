SHELL := /bin/sh

COMPOSE := docker compose
SERVICE := app

.PHONY: help bootstrap boostrap bootstrap-verify bootstrap-run bootstrap-full git-init project-dirs scaffold build lock sync lint format test run web-install web-dev web-build logs shell clean

help:
	@printf '%s\n' "Targets:"
	@printf '%s\n' "  make bootstrap  Create files and init git only"
	@printf '%s\n' "  make bootstrap-verify  Build, lock, format, lint, and test"
	@printf '%s\n' "  make bootstrap-run     Generate CSV and logs"
	@printf '%s\n' "  make bootstrap-full    Create files, init git, verify, and run"
	@printf '%s\n' "  make project-dirs      Create project directories"
	@printf '%s\n' "  make scaffold   Recreate project files"
	@printf '%s\n' "  make build      Build Docker image"
	@printf '%s\n' "  make test       Run tests in Docker Compose"
	@printf '%s\n' "  make run        Generate CSV and logs"
	@printf '%s\n' "  make web-install  Install Next.js dependencies in Docker"
	@printf '%s\n' "  make web-dev    Run the Next.js portal in Docker"
	@printf '%s\n' "  make web-build  Build the Next.js portal"
	@printf '%s\n' "  make format     Format Python code"
	@printf '%s\n' "  make clean      Remove generated runtime artifacts"

bootstrap: scaffold git-init

boostrap: bootstrap

bootstrap-verify: build lock format lint test

bootstrap-run: run

bootstrap-full: bootstrap bootstrap-verify bootstrap-run

git-init:
	@if [ ! -d .git ]; then git init; else printf '%s\n' "Git repository already initialized"; fi

project-dirs:
	@mkdir -p src/democompany_identities tests output logs app/api/users app/api/emails app/api/logs

scaffold: project-dirs
	$(file >.gitignore,$(GITIGNORE))@:
	$(file >.dockerignore,$(DOCKERIGNORE))@:
	$(file >.env,$(ENV_FILE))@:
	$(file >.env.example,$(ENV_FILE))@:
	$(file >pyproject.toml,$(PYPROJECT))@:
	$(file >package.json,$(PACKAGE_JSON))@:
	$(file >next-env.d.ts,$(NEXT_ENV_D_TS))@:
	$(file >next.config.ts,$(NEXT_CONFIG_TS))@:
	$(file >tsconfig.json,$(TSCONFIG_JSON))@:
	$(file >Dockerfile,$(DOCKERFILE))@:
	$(file >docker-compose.yml,$(COMPOSE_YML))@:
	$(file >README.md,$(README_MD))@:
	$(file >src/democompany_identities/__init__.py,$(INIT_PY))@:
	$(file >src/democompany_identities/__main__.py,$(MAIN_PY))@:
	$(file >src/democompany_identities/config.py,$(CONFIG_PY))@:
	$(file >src/democompany_identities/emailing.py,$(EMAILING_PY))@:
	$(file >src/democompany_identities/models.py,$(MODELS_PY))@:
	$(file >src/democompany_identities/client.py,$(CLIENT_PY))@:
	$(file >src/democompany_identities/transform.py,$(TRANSFORM_PY))@:
	$(file >src/democompany_identities/csv_exporter.py,$(CSV_EXPORTER_PY))@:
	$(file >src/democompany_identities/logging_config.py,$(LOGGING_CONFIG_PY))@:
	$(file >src/democompany_identities/service.py,$(SERVICE_PY))@:
	$(file >src/democompany_identities/cli.py,$(CLI_PY))@:
	$(file >src/democompany_identities/web_actions.py,$(WEB_ACTIONS_PY))@:
	$(file >src/democompany_identities/portal_api.py,$(PORTAL_API_PY))@:
	$(file >app/layout.tsx,$(APP_LAYOUT_TSX))@:
	$(file >app/page.tsx,$(APP_PAGE_TSX))@:
	$(file >app/globals.css,$(APP_GLOBALS_CSS))@:
	$(file >app/api/users/route.ts,$(API_USERS_ROUTE_TS))@:
	$(file >app/api/emails/route.ts,$(API_EMAILS_ROUTE_TS))@:
	$(file >app/api/logs/route.ts,$(API_LOGS_ROUTE_TS))@:
	$(file >tests/test_emailing.py,$(TEST_EMAILING_PY))@:
	$(file >tests/test_transform.py,$(TEST_TRANSFORM_PY))@:
	$(file >tests/test_csv_exporter.py,$(TEST_CSV_EXPORTER_PY))@:
	$(file >tests/test_client.py,$(TEST_CLIENT_PY))@:
	@printf '%s\n' "Project files created"

build:
	$(COMPOSE) build

lock:
	$(COMPOSE) run --rm $(SERVICE) uv lock

sync:
	$(COMPOSE) run --rm $(SERVICE) uv sync --all-extras --dev

lint:
	$(COMPOSE) run --rm $(SERVICE) uv run ruff check .
	$(COMPOSE) run --rm $(SERVICE) uv run ruff format --check .

format:
	$(COMPOSE) run --rm $(SERVICE) uv run ruff format .
	$(COMPOSE) run --rm $(SERVICE) uv run ruff check . --fix

test:
	$(COMPOSE) run --rm $(SERVICE) uv run pytest

run:
	@mkdir -p output logs
	$(COMPOSE) run --rm $(SERVICE) uv run democompany-identities --output output/contractors.csv --log-file logs/app.log

web-install:
	$(COMPOSE) run --rm web npm install

web-dev:
	$(COMPOSE) up web api

web-build:
	$(COMPOSE) run --rm web npm run build

logs:
	@tail -n 80 logs/app.log

shell:
	$(COMPOSE) run --rm $(SERVICE) sh

clean:
	$(COMPOSE) down --remove-orphans
	@rm -rf output logs .pytest_cache .ruff_cache .coverage htmlcov

define GITIGNORE
.venv/
.pytest_cache/
.ruff_cache/
.coverage
htmlcov/
logs/
output/
__pycache__/
*.py[cod]
*.egg-info/
.env
node_modules/
.next/
next-env.d.ts
endef

define DOCKERIGNORE
.git
.venv
.pytest_cache
.ruff_cache
.coverage
htmlcov
logs
output
*.pyc
__pycache__
node_modules
.next
endef

define ENV_FILE
DEMOCOMPANY_USERS_URL=https://jsonplaceholder.typicode.com/users
DEMOCOMPANY_DOMAIN=democompany.com
DEMOCOMPANY_TIMEOUT_SECONDS=10
endef

define PYPROJECT
[project]
name = "democompany-identities"
version = "0.1.0"
description = "Generate corporate contractor identities and corporate emails."
readme = "README.md"
requires-python = ">=3.13"
dependencies = [
    "httpx>=0.28.1",
    "python-dotenv>=1.1.0",
]

[project.scripts]
democompany-identities = "democompany_identities.cli:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/democompany_identities"]

[dependency-groups]
dev = [
    "pytest>=8.3.5",
    "pytest-cov>=6.1.1",
    "respx>=0.22.0",
    "ruff>=0.11.7",
]

[tool.ruff]
line-length = 100
target-version = "py313"
src = ["src", "tests"]
extend-exclude = [".venv", "output", "logs"]

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM", "RUF"]

[tool.pytest.ini_options]
addopts = "--cov=democompany_identities --cov-report=term-missing"
testpaths = ["tests"]
endef

define PACKAGE_JSON
{
  "name": "democompany-identities-portal",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "16.2.6",
    "react": "19.2.6",
    "react-dom": "19.2.6"
  },
  "devDependencies": {
    "@types/node": "25.6.2",
    "@types/react": "19.2.14",
    "@types/react-dom": "19.2.3",
    "typescript": "6.0.3"
  },
  "overrides": {
    "postcss": "8.5.14"
  }
}
endef

define NEXT_ENV_D_TS
/// <reference types="next" />
/// <reference types="next/image-types/global" />

// This file should not be edited.
endef

define NEXT_CONFIG_TS
import type { NextConfig } from "next";

const nextConfig: NextConfig = {};

export default nextConfig;
endef

define TSCONFIG_JSON
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts", ".next/dev/types/**/*.ts"],
  "exclude": ["node_modules"]
}
endef

define DOCKERFILE
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src ./src
COPY tests ./tests

RUN uv sync --all-extras --dev

ENTRYPOINT []
CMD ["uv", "run", "democompany-identities"]
endef

define COMPOSE_YML
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: democompany-identities:local
    working_dir: /app
    volumes:
      - .:/app
      - uv-cache:/root/.cache/uv
    env_file:
      - .env
    environment:
      DEMOCOMPANY_USERS_URL: $${DEMOCOMPANY_USERS_URL:-https://jsonplaceholder.typicode.com/users}
      DEMOCOMPANY_DOMAIN: $${DEMOCOMPANY_DOMAIN:-democompany.com}
      DEMOCOMPANY_TIMEOUT_SECONDS: $${DEMOCOMPANY_TIMEOUT_SECONDS:-10}
  api:
    build:
      context: .
      dockerfile: Dockerfile
    image: democompany-identities:local
    working_dir: /app
    volumes:
      - .:/app
      - uv-cache:/root/.cache/uv
    env_file:
      - .env
    command: uv run python -m democompany_identities.portal_api
    ports:
      - "8000:8000"
  web:
    image: node:22-bookworm-slim
    working_dir: /app
    volumes:
      - .:/app
    env_file:
      - .env
    environment:
      PYTHON_API_URL: http://api:8000
    depends_on:
      - api
    ports:
      - "3000:3000"
    command: npm run dev -- --hostname 0.0.0.0

volumes:
  uv-cache:
endef

define README_MD
# Contractor Identity Portal

Proyecto Python 3.13 con Docker Compose, uv y Next.js para consultar usuarios externos,
generar correos corporativos y visualizar el resultado desde CLI o desde un portal web.

## Objetivo

La aplicacion consume usuarios desde un endpoint configurable, transforma la informacion
relevante y genera correos corporativos bajo el dominio configurado.

El proyecto no genera tokens JWT, no cifra correos y no guarda hashes del email original.
La salida se mantiene simple y auditable:

- nombre completo
- telefono
- email original
- empresa
- ciudad
- email corporativo generado

## Requisitos

Antes de ejecutar el proyecto, asegurese de tener instalado:

- Docker
- Docker Compose
- Make

No es necesario instalar Python, uv o Node.js localmente. El proyecto usa contenedores
para ejecutar tanto el backend Python como el portal Next.js.

## Configuracion

El proyecto incluye un archivo `.env.example` con las variables necesarias:

```env
DEMOCOMPANY_USERS_URL=https://jsonplaceholder.typicode.com/users
DEMOCOMPANY_DOMAIN=democompany.com
DEMOCOMPANY_TIMEOUT_SECONDS=10
```

Para ejecutar localmente, el `Makefile` crea un `.env` con esos valores por defecto.
Si desea cambiar el endpoint, dominio corporativo o timeout, edite `.env`.

## Primer Uso

```sh
make bootstrap
```

Este comando solo crea archivos e inicializa git. No construye imagenes, no ejecuta
tests y no corre la aplicacion.

## Ejecucion Por CLI

```sh
make bootstrap-run
```

Este comando consulta usuarios, genera correos corporativos y crea:

- `output/contractors.csv`
- `logs/app.log`

Tambien puede ejecutar el comando directamente dentro de Docker Compose:

```sh
docker compose run --rm app uv run democompany-identities --output output/contractors.csv --log-file logs/app.log
```

## Ejecucion Del Portal Web

```sh
make web-install
make web-dev
```

Abra el navegador en:

```text
http://localhost:3000
```

El portal web permite:

- ejecutar la consulta de usuarios
- ver los usuarios en una tabla
- generar correos corporativos
- ver el log de la sesion actual
- descargar la tabla visible en formato CSV

## Flujo En El Portal

1. Abra `http://localhost:3000`.
2. Presione `Ejecutar scripts` para consultar los usuarios externos.
3. Revise la tabla con la informacion consultada.
4. Presione `Generar emails` para crear los correos corporativos.
5. Use `Descargar CSV` para descargar la tabla actual.

El cuadro de log del portal no lee el archivo `logs/app.log`. Solo muestra el log
generado por la accion actual de la sesion web.

## Regla De Generacion De Emails

El email corporativo se genera con base en el nombre del usuario y el dominio configurado.
La regla evita direcciones demasiado cortas:

- si `inicial + apellido` tiene 5 o mas caracteres, se usa esa forma
- si queda por debajo de 5 caracteres, se agregan letras del primer nombre
- si hay duplicados, se agrega un consecutivo numerico

Ejemplos:

- `Leanne Graham` -> `lgraham@democompany.com`
- `John Doe` -> `jodoe@democompany.com`
- `Nicholas Runolfsdottir V` -> `nichv@democompany.com`

## Evidencia Visual

Pagina inicial limpia:

![Pagina web limpia](img/PaginaWeb-Limpia.png)

Pagina despues de ejecutar la consulta de usuarios:

![Pagina web con usuarios consultados](img/PaginaWeb-Script.png)

Pagina despues de generar correos corporativos:

![Pagina web con emails generados](img/PaginaWeb-Emails.png)

## Estructura Del Proyecto

```text
.
|-- app/                         # Portal web Next.js
|   |-- api/                     # Rutas API usadas por la UI
|   |-- globals.css              # Estilos globales
|   |-- layout.tsx               # Layout principal
|   `-- page.tsx                 # Pantalla del portal
|-- img/                         # Capturas de evidencia
|-- logs/                        # Logs generados por CLI
|-- output/                      # CSV y JSON generados
|-- src/democompany_identities/  # Backend Python
|-- tests/                       # Pruebas unitarias
|-- docker-compose.yml           # Servicios app, api y web
|-- Dockerfile                   # Imagen Python con uv
|-- Makefile                     # Comandos de automatizacion
|-- package.json                 # Dependencias del portal Next.js
`-- pyproject.toml               # Dependencias y config Python
```

## Componentes Principales

- `client.py`: consume el endpoint externo de usuarios.
- `emailing.py`: normaliza nombres y genera emails corporativos.
- `transform.py`: transforma usuarios externos en identidades de contratistas.
- `csv_exporter.py`: escribe el CSV final.
- `service.py`: coordina el flujo CLI.
- `web_actions.py`: acciones usadas por el portal web.
- `portal_api.py`: API HTTP simple usada por Next.js dentro de Docker Compose.

## Comandos Make

```sh
make bootstrap
```

Crea archivos e inicializa git.

```sh
make bootstrap-verify
```

Construye la imagen, actualiza lock, formatea, ejecuta lint y corre tests.

```sh
make bootstrap-run
```

Ejecuta el flujo CLI y genera el CSV.

```sh
make web-install
```

Instala dependencias del portal Next.js dentro del contenedor Node.

```sh
make web-dev
```

Levanta el portal web y la API Python.

```sh
make web-build
```

Compila el portal Next.js.

```sh
make test
```

Ejecuta las pruebas Python.

```sh
make clean
```

Elimina artefactos de ejecucion local.

## Pruebas

```sh
make test
```

O directamente:

```sh
docker compose run --rm --build app uv run pytest
```

## Salidas Generadas

El flujo CLI genera:

- `output/contractors.csv`
- `logs/app.log`

El portal web puede generar:

- `output/users.json`
- `output/contractors.json`
- `output/contractors.csv`

La descarga desde el boton `Descargar CSV` exporta la tabla visible en el navegador.

## Notas De Seguridad Y Privacidad

- `.env` esta ignorado por git para evitar publicar parametros locales.
- `.env.example` documenta las variables esperadas sin exponer secretos reales.
- El proyecto no incluye datos sensibles de una empresa especifica.
- El nombre, documentacion y variables se mantienen genericos para evitar divulgar
  informacion del proceso o de la compania.
endef

define INIT_PY
"""DemoCompany identity generation package."""

__version__ = "0.1.0"
endef

define MAIN_PY
from democompany_identities.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
endef

define APP_LAYOUT_TSX
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DemoCompany Identity Portal",
  description: "Portal para consultar usuarios y generar correos corporativos.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
endef

define APP_PAGE_TSX
"use client";

import { useEffect, useMemo, useState } from "react";

type ExternalUser = {
  id: number;
  name: string;
  username: string;
  email: string;
  phone: string;
  company: string;
  city: string;
};

type ContractorIdentity = {
  full_name: string;
  phone: string;
  original_email: string;
  company: string;
  city: string;
  corporate_email: string;
};

type Row = Partial<ExternalUser & ContractorIdentity>;

async function postJson<T>(url: string): Promise<T> {
  const response = await fetch(url, { method: "POST" });
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(payload.error ?? "La operacion fallo");
  }
  return payload;
}

export default function Home() {
  const [users, setUsers] = useState<ExternalUser[]>([]);
  const [identities, setIdentities] = useState<ContractorIdentity[]>([]);
  const [logs, setLogs] = useState("");
  const [loadingUsers, setLoadingUsers] = useState(false);
  const [loadingEmails, setLoadingEmails] = useState(false);
  const [error, setError] = useState("");

  async function refreshLogs() {
    const response = await fetch("/api/logs");
    const payload = await response.json();
    setLogs(payload.logs ?? "");
  }

  useEffect(() => {
    refreshLogs();
  }, []);

  async function fetchUsers() {
    setError("");
    setLoadingUsers(true);
    try {
      const payload = await postJson<{ users: ExternalUser[] }>("/api/users");
      setUsers(payload.users);
      setIdentities([]);
      await refreshLogs();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudieron consultar usuarios");
    } finally {
      setLoadingUsers(false);
    }
  }

  async function generateEmails() {
    setError("");
    setLoadingEmails(true);
    try {
      const payload = await postJson<{ identities: ContractorIdentity[] }>("/api/emails");
      setIdentities(payload.identities);
      await refreshLogs();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudieron generar correos");
    } finally {
      setLoadingEmails(false);
    }
  }

  const rows = useMemo<Row[]>(() => (identities.length > 0 ? identities : users), [identities, users]);
  const rowCountLabel = rows.length ? String(rows.length) + " registros disponibles" : "Sin registros todavia";

  function csvCell(value: unknown): string {
    const text = String(value ?? "");
    return `"${text.replaceAll('"', '""')}"`;
  }

  function downloadCsv() {
    const headers = ["Nombre", "Telefono", "Email original", "Empresa", "Ciudad", "Email corporativo"];
    const csvRows = rows.map((row) =>
      [
        row.full_name ?? row.name,
        row.phone,
        row.original_email ?? row.email,
        row.company,
        row.city,
        row.corporate_email ?? "",
      ]
        .map(csvCell)
        .join(","),
    );
    const csv = [headers.map(csvCell).join(","), ...csvRows].join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = identities.length > 0 ? "contractors.csv" : "users.csv";
    link.click();
    URL.revokeObjectURL(url);
  }

  return (
    <main className="shell">
      <section className="topbar">
        <div>
          <p className="eyebrow">DemoCompany</p>
          <h1>Portal de identidades</h1>
        </div>
        <div className="actions">
          <button onClick={fetchUsers} disabled={loadingUsers || loadingEmails}>
            {loadingUsers ? "Consultando..." : "Ejecutar scripts"}
          </button>
          <button className="secondary" onClick={generateEmails} disabled={loadingUsers || loadingEmails}>
            {loadingEmails ? "Generando..." : "Generar emails"}
          </button>
        </div>
      </section>

      {error ? <p className="error">{error}</p> : null}

      <section className="summary">
        <div>
          <span>{users.length}</span>
          <p>usuarios consultados</p>
        </div>
        <div>
          <span>{identities.length}</span>
          <p>emails generados</p>
        </div>
        <div>
          <span>democompany.com</span>
          <p>dominio corporativo</p>
        </div>
      </section>

      <section className="workspace">
        <div className="tablePanel">
          <div className="sectionHeader">
            <div>
              <h2>Informacion procesada</h2>
              <p>{rowCountLabel}</p>
            </div>
            <button className="ghost" onClick={downloadCsv} disabled={rows.length === 0}>
              Descargar CSV
            </button>
          </div>
          <div className="tableWrap">
            <table>
              <thead>
                <tr>
                  <th>Nombre</th>
                  <th>Telefono</th>
                  <th>Email original</th>
                  <th>Empresa</th>
                  <th>Ciudad</th>
                  <th>Email corporativo</th>
                </tr>
              </thead>
              <tbody>
                {rows.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="empty">
                      Ejecuta la consulta para cargar informacion.
                    </td>
                  </tr>
                ) : (
                  rows.map((row, index) => (
                    <tr key={(row.email ?? row.original_email ?? "row") + String(index)}>
                      <td>{row.full_name ?? row.name}</td>
                      <td>{row.phone}</td>
                      <td>{row.original_email ?? row.email}</td>
                      <td>{row.company}</td>
                      <td>{row.city}</td>
                      <td className="corporate">{row.corporate_email ?? "Pendiente"}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>

        <aside className="logPanel">
          <div className="sectionHeader">
            <h2>Log en tiempo real</h2>
            <p>Contenido fijo</p>
          </div>
          <pre>{logs || "Aun no hay actividad registrada."}</pre>
        </aside>
      </section>
    </main>
  );
}
endef

define API_USERS_ROUTE_TS
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.PYTHON_API_URL ?? "http://api:8000";

export async function POST() {
  try {
    const response = await fetch(`$${API_BASE_URL}/users`, { method: "POST" });
    const payload = await response.json();
    return NextResponse.json(payload, { status: response.status });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "No se pudieron consultar usuarios" },
      { status: 500 },
    );
  }
}
endef

define API_EMAILS_ROUTE_TS
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.PYTHON_API_URL ?? "http://api:8000";

export async function POST() {
  try {
    const response = await fetch(`$${API_BASE_URL}/emails`, { method: "POST" });
    const payload = await response.json();
    return NextResponse.json(payload, { status: response.status });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "No se pudieron generar correos" },
      { status: 500 },
    );
  }
}
endef

define API_LOGS_ROUTE_TS
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.PYTHON_API_URL ?? "http://api:8000";

export async function GET() {
  try {
    const response = await fetch(`$${API_BASE_URL}/logs`);
    const payload = await response.json();
    return NextResponse.json(payload, { status: response.status });
  } catch {
    return NextResponse.json({ logs: "" });
  }
}
endef

define APP_GLOBALS_CSS
:root {
  --bg: #f5f7fb;
  --ink: #172033;
  --muted: #667085;
  --line: #d8dee9;
  --panel: #ffffff;
  --primary: #0f766e;
  --primary-dark: #115e59;
  --danger: #b42318;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font-family: Arial, Helvetica, sans-serif;
}

button {
  border: 0;
  border-radius: 6px;
  background: var(--primary);
  color: white;
  cursor: pointer;
  font-weight: 700;
  min-height: 42px;
  padding: 0 18px;
}

button:hover {
  background: var(--primary-dark);
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.62;
}

button.secondary {
  background: #263449;
}

button.secondary:hover {
  background: #182231;
}

button.ghost {
  background: #eef6f5;
  color: var(--primary-dark);
}

button.ghost:hover {
  background: #d9eeeb;
}

.shell {
  margin: 0 auto;
  max-width: 1440px;
  padding: 28px;
}

.topbar {
  align-items: center;
  display: flex;
  justify-content: space-between;
  gap: 20px;
  margin-bottom: 22px;
}

.eyebrow {
  color: var(--primary);
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 0;
  margin: 0 0 6px;
  text-transform: uppercase;
}

h1,
h2,
p {
  margin: 0;
}

h1 {
  font-size: 34px;
  line-height: 1.15;
}

h2 {
  font-size: 18px;
}

.actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.error {
  background: #fff1f0;
  border: 1px solid #fecdca;
  border-radius: 6px;
  color: var(--danger);
  margin-bottom: 18px;
  padding: 12px 14px;
}

.summary {
  display: grid;
  gap: 14px;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  margin-bottom: 18px;
}

.summary div,
.tablePanel,
.logPanel {
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 8px;
}

.summary div {
  padding: 18px;
}

.summary span {
  color: var(--primary);
  display: block;
  font-size: 26px;
  font-weight: 800;
  line-height: 1.1;
  overflow-wrap: anywhere;
}

.summary p,
.sectionHeader p {
  color: var(--muted);
  font-size: 14px;
  margin-top: 5px;
}

.workspace {
  display: grid;
  gap: 18px;
  grid-template-columns: minmax(0, 1.7fr) minmax(340px, 0.8fr);
}

.sectionHeader {
  align-items: center;
  border-bottom: 1px solid var(--line);
  display: flex;
  justify-content: space-between;
  gap: 14px;
  padding: 16px 18px;
}

.tableWrap {
  overflow-x: auto;
}

table {
  border-collapse: collapse;
  min-width: 920px;
  width: 100%;
}

th,
td {
  border-bottom: 1px solid #edf0f5;
  font-size: 14px;
  padding: 13px 16px;
  text-align: left;
  vertical-align: top;
}

th {
  background: #f9fafb;
  color: #475467;
  font-size: 12px;
  text-transform: uppercase;
}

.corporate {
  color: var(--primary-dark);
  font-weight: 700;
}

.empty {
  color: var(--muted);
  height: 160px;
  text-align: center;
  vertical-align: middle;
}

.logPanel pre {
  background: #101828;
  border-radius: 0 0 8px 8px;
  color: #d1fadf;
  font-family: "Courier New", monospace;
  font-size: 13px;
  height: 520px;
  line-height: 1.45;
  margin: 0;
  overflow: auto;
  padding: 18px;
  white-space: pre-wrap;
}

@media (max-width: 980px) {
  .topbar,
  .sectionHeader {
    align-items: flex-start;
    flex-direction: column;
  }

  .actions {
    justify-content: flex-start;
  }

  .summary,
  .workspace {
    grid-template-columns: 1fr;
  }

  .logPanel pre {
    height: 360px;
  }
}

@media (max-width: 560px) {
  .shell {
    padding: 18px;
  }

  h1 {
    font-size: 28px;
  }

  button {
    width: 100%;
  }

  .actions {
    width: 100%;
  }
}
endef

define CONFIG_PY
from dataclasses import dataclass
from os import getenv

from dotenv import load_dotenv

DEFAULT_USERS_URL = "https://jsonplaceholder.typicode.com/users"
DEFAULT_DOMAIN = "democompany.com"


@dataclass(frozen=True)
class Settings:
    users_url: str = DEFAULT_USERS_URL
    corporate_domain: str = DEFAULT_DOMAIN
    timeout_seconds: float = 10.0

    @classmethod
    def from_env(cls) -> "Settings":
        load_dotenv()
        return cls(
            users_url=getenv("DEMOCOMPANY_USERS_URL", DEFAULT_USERS_URL),
            corporate_domain=getenv("DEMOCOMPANY_DOMAIN", DEFAULT_DOMAIN),
            timeout_seconds=float(getenv("DEMOCOMPANY_TIMEOUT_SECONDS", "10")),
        )
endef

define EMAILING_PY
import re
import unicodedata
from collections import defaultdict

NON_ALNUM = re.compile(r"[^a-z0-9]+")
MIN_LOCAL_PART_LENGTH = 5


def normalize_token(value: str) -> str:
    ascii_value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    return NON_ALNUM.sub("", ascii_value.lower())


def build_email_local_part(full_name: str) -> str:
    tokens = [normalize_token(part) for part in full_name.split()]
    tokens = [token for token in tokens if token]
    if len(tokens) < 2:
        raise ValueError(f"Cannot generate corporate email from incomplete name: {full_name!r}")
    local_part = f"{tokens[0][0]}{tokens[-1]}"
    if len(local_part) >= MIN_LOCAL_PART_LENGTH:
        return local_part
    first_name_prefix_length = max(MIN_LOCAL_PART_LENGTH - len(tokens[-1]), 1)
    return f"{tokens[0][:first_name_prefix_length]}{tokens[-1]}"


def generate_unique_email(full_name: str, domain: str, used_counts: defaultdict[str, int]) -> str:
    base = build_email_local_part(full_name)
    index = used_counts[base]
    used_counts[base] += 1
    suffix = "" if index == 0 else str(index)
    return f"{base}{suffix}@{domain}"
endef

define MODELS_PY
from dataclasses import dataclass


@dataclass(frozen=True)
class ExternalUser:
    id: int
    name: str
    username: str
    email: str
    phone: str
    company: str
    city: str


@dataclass(frozen=True)
class ContractorIdentity:
    full_name: str
    phone: str
    original_email: str
    company: str
    city: str
    corporate_email: str
endef

define CLIENT_PY
from typing import Any

import httpx

from democompany_identities.models import ExternalUser


class UsersClientError(RuntimeError):
    """Raised when the users service cannot be consumed safely."""


class UsersClient:
    def __init__(self, url: str, timeout_seconds: float) -> None:
        self._url = url
        self._timeout_seconds = timeout_seconds

    def fetch_users(self) -> list[ExternalUser]:
        try:
            response = httpx.get(self._url, timeout=self._timeout_seconds)
            response.raise_for_status()
            payload = response.json()
        except httpx.HTTPError as exc:
            raise UsersClientError(f"Failed to fetch users from {self._url}") from exc
        except ValueError as exc:
            raise UsersClientError("Users service returned invalid JSON") from exc

        if not isinstance(payload, list):
            raise UsersClientError("Users service response must be a JSON array")

        return [parse_user(item) for item in payload]


def parse_user(item: Any) -> ExternalUser:
    if not isinstance(item, dict):
        raise UsersClientError("Each user record must be an object")
    address = item.get("address")
    company = item.get("company")
    if not isinstance(address, dict) or not isinstance(company, dict):
        raise UsersClientError("User record must include address and company objects")
    return ExternalUser(
        id=int(item["id"]),
        name=str(item["name"]).strip(),
        username=str(item["username"]).strip(),
        email=str(item["email"]).strip(),
        phone=str(item["phone"]).strip(),
        company=str(company["name"]).strip(),
        city=str(address["city"]).strip(),
    )
endef

define TRANSFORM_PY
from collections import defaultdict

from democompany_identities.config import Settings
from democompany_identities.emailing import generate_unique_email
from democompany_identities.models import ContractorIdentity, ExternalUser


def transform_users(users: list[ExternalUser], settings: Settings) -> list[ContractorIdentity]:
    used_counts: defaultdict[str, int] = defaultdict(int)
    identities: list[ContractorIdentity] = []

    for user in users:
        corporate_email = generate_unique_email(user.name, settings.corporate_domain, used_counts)
        identities.append(
            ContractorIdentity(
                full_name=user.name,
                phone=user.phone,
                original_email=user.email,
                company=user.company,
                city=user.city,
                corporate_email=corporate_email,
            )
        )

    return identities
endef

define CSV_EXPORTER_PY
import csv
from dataclasses import asdict
from pathlib import Path

from democompany_identities.models import ContractorIdentity

FIELDNAMES = [
    "full_name",
    "phone",
    "original_email",
    "company",
    "city",
    "corporate_email",
]


def write_contractors_csv(path: Path, identities: list[ContractorIdentity]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        for identity in identities:
            writer.writerow(asdict(identity))
endef

define LOGGING_CONFIG_PY
import logging
from pathlib import Path


def configure_logging(log_file: Path) -> logging.Logger:
    log_file.parent.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger("democompany_identities")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    logger.propagate = False

    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    file_handler = logging.FileHandler(log_file, encoding="utf-8")
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger
endef

define SERVICE_PY
import logging
from pathlib import Path

from democompany_identities.client import UsersClient
from democompany_identities.config import Settings
from democompany_identities.csv_exporter import write_contractors_csv
from democompany_identities.models import ExternalUser
from democompany_identities.transform import transform_users


def fetch_external_users(settings: Settings, logger: logging.Logger) -> list[ExternalUser]:
    logger.info("Fetching external users from %s", settings.users_url)
    users = UsersClient(settings.users_url, settings.timeout_seconds).fetch_users()
    logger.info("Total records fetched from endpoint: %s", len(users))
    return users


def generate_contractor_report(settings: Settings, output_path: Path, logger: logging.Logger) -> None:
    logger.info("Process started")
    users = fetch_external_users(settings, logger)
    identities = transform_users(users, settings)
    logger.info("Corporate emails generated successfully: %s", len(identities))
    write_contractors_csv(output_path, identities)
    logger.info("CSV file generated successfully: %s", output_path)
endef

define CLI_PY
import argparse
from pathlib import Path

from democompany_identities.config import Settings
from democompany_identities.logging_config import configure_logging
from democompany_identities.service import generate_contractor_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate DemoCompany contractor identities from a JSON users endpoint."
    )
    parser.add_argument("--output", type=Path, default=Path("output/contractors.csv"))
    parser.add_argument("--log-file", type=Path, default=Path("logs/app.log"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    settings = Settings.from_env()
    logger = configure_logging(args.log_file)
    generate_contractor_report(settings, args.output, logger)
    return 0
endef

define WEB_ACTIONS_PY
import argparse
import json
from dataclasses import asdict
from pathlib import Path

from democompany_identities.config import Settings
from democompany_identities.csv_exporter import write_contractors_csv
from democompany_identities.logging_config import configure_logging
from democompany_identities.models import ExternalUser
from democompany_identities.service import fetch_external_users
from democompany_identities.transform import transform_users

OUTPUT_DIR = Path("output")
LOG_FILE = Path("logs/app.log")
USERS_JSON = OUTPUT_DIR / "users.json"
IDENTITIES_JSON = OUTPUT_DIR / "contractors.json"
CSV_FILE = OUTPUT_DIR / "contractors.csv"


def write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def read_users() -> list[ExternalUser]:
    payload = json.loads(USERS_JSON.read_text(encoding="utf-8"))
    return [ExternalUser(**item) for item in payload]


def fetch_users_action() -> dict[str, object]:
    settings = Settings.from_env()
    logger = configure_logging(LOG_FILE)
    logger.info("Portal action started: fetch users")
    users = fetch_external_users(settings, logger)
    payload = [asdict(user) for user in users]
    write_json(USERS_JSON, payload)
    logger.info("Portal action finished: users saved to %s", USERS_JSON)
    return {"users": payload}


def generate_emails_action() -> dict[str, object]:
    settings = Settings.from_env()
    logger = configure_logging(LOG_FILE)
    logger.info("Portal action started: generate corporate emails")
    if USERS_JSON.exists():
        users = read_users()
        logger.info("Loaded users from %s", USERS_JSON)
    else:
        users = fetch_external_users(settings, logger)
        write_json(USERS_JSON, [asdict(user) for user in users])
    identities = transform_users(users, settings)
    payload = [asdict(identity) for identity in identities]
    write_json(IDENTITIES_JSON, payload)
    write_contractors_csv(CSV_FILE, identities)
    logger.info("Corporate emails generated successfully: %s", len(identities))
    logger.info("CSV file generated successfully: %s", CSV_FILE)
    return {"identities": payload}


def logs_action() -> dict[str, object]:
    if not LOG_FILE.exists():
        return {"logs": ""}
    return {"logs": LOG_FILE.read_text(encoding="utf-8")}


def main() -> int:
    parser = argparse.ArgumentParser(description="Actions used by the Next.js portal.")
    parser.add_argument("action", choices=["fetch-users", "generate-emails"])
    args = parser.parse_args()

    if args.action == "fetch-users":
        result = fetch_users_action()
    else:
        result = generate_emails_action()

    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
endef

define PORTAL_API_PY
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Callable

from democompany_identities.web_actions import fetch_users_action, generate_emails_action, logs_action

HOST = "0.0.0.0"
PORT = 8000


def json_response(handler: BaseHTTPRequestHandler, status: int, payload: dict[str, object]) -> None:
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json")
    handler.send_header("Content-Length", str(len(body)))
    handler.send_header("Access-Control-Allow-Origin", "*")
    handler.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
    handler.send_header("Access-Control-Allow-Headers", "Content-Type")
    handler.end_headers()
    handler.wfile.write(body)


class PortalHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self) -> None:
        json_response(self, 204, {})

    def do_GET(self) -> None:
        if self.path == "/logs":
            json_response(self, 200, logs_action())
            return
        json_response(self, 404, {"error": "Endpoint not found"})

    def do_POST(self) -> None:
        routes: dict[str, Callable[[], dict[str, object]]] = {
            "/users": fetch_users_action,
            "/emails": generate_emails_action,
        }
        action = routes.get(self.path)
        if action is None:
            json_response(self, 404, {"error": "Endpoint not found"})
            return
        try:
            json_response(self, 200, action())
        except Exception as exc:
            json_response(self, 500, {"error": str(exc)})

    def log_message(self, format: str, *args: object) -> None:
        return


def main() -> int:
    server = ThreadingHTTPServer((HOST, PORT), PortalHandler)
    print(f"Portal API listening on http://{HOST}:{PORT}", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
endef

define TEST_EMAILING_PY
from collections import defaultdict

import pytest

from democompany_identities.emailing import build_email_local_part, generate_unique_email


def test_build_email_local_part_uses_first_initial_and_last_name() -> None:
    assert build_email_local_part("John Ronald Doe") == "jodoe"


def test_build_email_local_part_uses_name_when_last_name_is_too_short() -> None:
    assert build_email_local_part("Nicholas Runolfsdottir V") == "nichv"


def test_build_email_local_part_requires_name_and_last_name() -> None:
    with pytest.raises(ValueError):
        build_email_local_part("Prince")


def test_generate_unique_email_adds_correlative_suffixes() -> None:
    used_counts: defaultdict[str, int] = defaultdict(int)

    assert generate_unique_email("John Doe", "democompany.com", used_counts) == "jodoe@democompany.com"
    assert generate_unique_email("Johana Doe", "democompany.com", used_counts) == "jodoe1@democompany.com"
endef

define TEST_TRANSFORM_PY
from democompany_identities.config import Settings
from democompany_identities.models import ExternalUser
from democompany_identities.transform import transform_users


def make_settings() -> Settings:
    return Settings()


def make_user(user_id: int, name: str) -> ExternalUser:
    return ExternalUser(
        id=user_id,
        name=name,
        username=f"user{user_id}",
        email=f"user{user_id}@example.com",
        phone="1-770-736-8031",
        company="Romaguera-Crona",
        city="Gwenborough",
    )


def test_transform_users_maps_fields_and_generates_email() -> None:
    settings = make_settings()
    identities = transform_users([make_user(1, "Leanne Graham")], settings)
    identity = identities[0]

    assert identity.corporate_email == "lgraham@democompany.com"
    assert identity.original_email == "user1@example.com"


def test_transform_users_deduplicates_generated_emails() -> None:
    identities = transform_users([make_user(1, "John Doe"), make_user(2, "Johana Doe")], make_settings())

    assert [identity.corporate_email for identity in identities] == [
        "jodoe@democompany.com",
        "jodoe1@democompany.com",
    ]
endef

define TEST_CSV_EXPORTER_PY
import csv

from democompany_identities.csv_exporter import FIELDNAMES, write_contractors_csv
from democompany_identities.models import ContractorIdentity


def test_write_contractors_csv_includes_identity_columns(tmp_path) -> None:
    identity = ContractorIdentity(
        full_name="Leanne Graham",
        phone="1-770-736-8031",
        original_email="user1@example.com",
        company="Romaguera-Crona",
        city="Gwenborough",
        corporate_email="lgraham@democompany.com",
    )

    output_path = tmp_path / "contractors.csv"
    write_contractors_csv(output_path, [identity])

    with output_path.open(encoding="utf-8", newline="") as file:
        rows = list(csv.DictReader(file))

    assert list(rows[0]) == FIELDNAMES
    assert rows[0]["corporate_email"] == "lgraham@democompany.com"
endef

define TEST_CLIENT_PY
import httpx
import pytest
import respx

from democompany_identities.client import UsersClient, UsersClientError

VALID_USER = {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "phone": "1-770-736-8031 x56442",
    "address": {"city": "Gwenborough"},
    "company": {"name": "Romaguera-Crona"},
}


@respx.mock
def test_fetch_users_returns_validated_users() -> None:
    respx.get("https://example.test/users").mock(return_value=httpx.Response(200, json=[VALID_USER]))

    users = UsersClient("https://example.test/users", timeout_seconds=1).fetch_users()

    assert len(users) == 1
    assert users[0].name == "Leanne Graham"


@respx.mock
def test_fetch_users_rejects_non_array_payload() -> None:
    respx.get("https://example.test/users").mock(return_value=httpx.Response(200, json={"id": 1}))

    with pytest.raises(UsersClientError, match="JSON array"):
        UsersClient("https://example.test/users", timeout_seconds=1).fetch_users()
endef
