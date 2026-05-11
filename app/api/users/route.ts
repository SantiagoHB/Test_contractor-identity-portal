import { NextResponse } from "next/server";

const API_BASE_URL = process.env.PYTHON_API_URL ?? "http://api:8000";

export async function POST() {
  try {
    const response = await fetch(`${API_BASE_URL}/users`, { method: "POST" });
    const payload = await response.json();
    return NextResponse.json(payload, { status: response.status });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "No se pudieron consultar usuarios" },
      { status: 500 },
    );
  }
}
