import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Tool DB",
  description: "Curated AI tools from your inbox, organized and searchable.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen">{children}</body>
    </html>
  );
}
