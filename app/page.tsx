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
