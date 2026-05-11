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
