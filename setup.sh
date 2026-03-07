#!/bin/bash
# ============================================================
# AI Tool Tracker - Full Project Setup Script
# Run from an EMPTY folder in your Cursor terminal:
#   bash setup.sh
# ============================================================

set -e
echo "🚀 Creating AI Tool Tracker project..."
echo ""

# Create directories
mkdir -p src/app/api/{auth,callback,sync,tools,favorites}
mkdir -p src/components src/lib public data
echo "📁 Directories created"

# ── package.json ──
cat > "package.json" << 'ENDOFFILE_000'
{
  "name": "ai-tool-tracker",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "googleapis": "^144.0.0",
    "cheerio": "^1.0.0",
    "better-sqlite3": "^11.0.0",
    "lucide-react": "^0.400.0"
  },
  "devDependencies": {
    "@types/better-sqlite3": "^7.6.0",
    "@types/node": "^20.0.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "typescript": "^5.5.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.2.0"
  }
}
ENDOFFILE_000
echo "  ✅ package.json"

# ── tsconfig.json ──
cat > "tsconfig.json" << 'ENDOFFILE_001'
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
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
ENDOFFILE_001
echo "  ✅ tsconfig.json"

# ── next.config.js ──
cat > "next.config.js" << 'ENDOFFILE_002'
/** @type {import('next').NextConfig} */
const nextConfig = {};
module.exports = nextConfig;
ENDOFFILE_002
echo "  ✅ next.config.js"

# ── tailwind.config.js ──
cat > "tailwind.config.js" << 'ENDOFFILE_003'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      fontFamily: {
        display: ['"DM Sans"', 'sans-serif'],
        body: ['"IBM Plex Sans"', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      colors: {
        surface: {
          0: '#0a0a0c',
          1: '#111114',
          2: '#1a1a1f',
          3: '#242429',
          4: '#2e2e35',
        },
        accent: {
          DEFAULT: '#22d3ee',
          dim: '#0e7490',
          bright: '#67e8f9',
        },
        warn: '#f59e0b',
        fav: '#f472b6',
      },
    },
  },
  plugins: [],
};
ENDOFFILE_003
echo "  ✅ tailwind.config.js"

# ── postcss.config.js ──
cat > "postcss.config.js" << 'ENDOFFILE_004'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
ENDOFFILE_004
echo "  ✅ postcss.config.js"

# ── .gitignore ──
cat > ".gitignore" << 'ENDOFFILE_005'
node_modules/
.next/
.env.local
data/
*.db
ENDOFFILE_005
echo "  ✅ .gitignore"

# ── .env.local.example ──
cat > ".env.local.example" << 'ENDOFFILE_006'
# Google OAuth credentials
# 1. Go to https://console.cloud.google.com
# 2. Create a project (or use an existing one)
# 3. Enable the Gmail API
# 4. Create OAuth 2.0 credentials (Web application type)
# 5. Add http://localhost:3000/api/callback as an authorized redirect URI
# 6. Copy your client ID and secret below

GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here

# Base URL for OAuth redirect (change for production)
NEXT_PUBLIC_BASE_URL=http://localhost:3000
ENDOFFILE_006
echo "  ✅ .env.local.example"

# ── src/app/globals.css ──
cat > "src/app/globals.css" << 'ENDOFFILE_007'
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700;1,9..40,400&family=IBM+Plex+Sans:wght@300;400;500;600&family=JetBrains+Mono:wght@400;500&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-surface-0 text-gray-200 font-body antialiased;
  }

  ::selection {
    @apply bg-accent/30 text-white;
  }

  ::-webkit-scrollbar {
    width: 6px;
  }
  ::-webkit-scrollbar-track {
    @apply bg-surface-1;
  }
  ::-webkit-scrollbar-thumb {
    @apply bg-surface-4 rounded-full;
  }
}

@layer components {
  .card {
    @apply bg-surface-1 border border-surface-3 rounded-xl;
  }

  .card-hover {
    @apply card transition-all duration-200 hover:border-accent/30 hover:shadow-lg hover:shadow-accent/5;
  }

  .chip {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-mono font-medium
           bg-surface-3 text-gray-400 border border-surface-4
           transition-all duration-150 cursor-pointer select-none;
  }

  .chip-active {
    @apply chip bg-accent/15 text-accent border-accent/30;
  }

  .btn-primary {
    @apply inline-flex items-center gap-2 px-4 py-2 rounded-lg
           bg-accent text-surface-0 font-display font-medium text-sm
           transition-all duration-200
           hover:bg-accent-bright active:scale-[0.97];
  }

  .btn-ghost {
    @apply inline-flex items-center gap-2 px-4 py-2 rounded-lg
           text-gray-400 font-display font-medium text-sm
           transition-all duration-200
           hover:bg-surface-3 hover:text-gray-200;
  }

  .search-input {
    @apply w-full bg-surface-2 border border-surface-4 rounded-xl
           px-4 py-3 pl-11 text-sm text-gray-200
           placeholder:text-gray-600 font-body
           outline-none transition-all duration-200
           focus:border-accent/40 focus:ring-1 focus:ring-accent/20;
  }
}

/* Fade-in animation for tool cards */
@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-up {
  animation: fadeUp 0.3s ease-out forwards;
  opacity: 0;
}

/* Stagger delays */
.delay-1 { animation-delay: 0.03s; }
.delay-2 { animation-delay: 0.06s; }
.delay-3 { animation-delay: 0.09s; }
.delay-4 { animation-delay: 0.12s; }
.delay-5 { animation-delay: 0.15s; }
ENDOFFILE_007
echo "  ✅ src/app/globals.css"

# ── src/app/layout.tsx ──
cat > "src/app/layout.tsx" << 'ENDOFFILE_008'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Tool Tracker",
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
ENDOFFILE_008
echo "  ✅ src/app/layout.tsx"

# ── src/app/page.tsx ──
cat > "src/app/page.tsx" << 'ENDOFFILE_009'
"use client";

import { useState, useEffect, useMemo, useCallback } from "react";
import {
  Search,
  Heart,
  Layers,
  Sparkles,
  Star,
  LayoutList,
} from "lucide-react";
import { AITool } from "@/lib/types";
import ToolCard from "@/components/ToolCard";
import SearchBar from "@/components/SearchBar";
import CategoryFilter from "@/components/CategoryFilter";
import SyncButton from "@/components/SyncButton";

type View = "all" | "favorites";
type SectionFilter = "all" | "daily" | "notable";

export default function Home() {
  const [tools, setTools] = useState<AITool[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const [authUrl, setAuthUrl] = useState("");

  // Filters
  const [search, setSearch] = useState("");
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [sectionFilter, setSectionFilter] = useState<SectionFilter>("all");
  const [view, setView] = useState<View>("all");

  // Fetch auth status
  useEffect(() => {
    fetch("/api/auth")
      .then((r) => r.json())
      .then((data) => {
        setAuthenticated(data.authenticated);
        if (data.authUrl) setAuthUrl(data.authUrl);
      })
      .catch(console.error);
  }, []);

  // Fetch tools
  const fetchTools = useCallback(() => {
    setLoading(true);
    fetch("/api/tools")
      .then((r) => r.json())
      .then((data) => {
        setTools(
          (data.tools || []).map((t: any) => ({
            ...t,
            favorited: !!t.favorited,
          }))
        );
        setCategories(data.categories || []);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    fetchTools();
  }, [fetchTools]);

  // Filter logic
  const filteredTools = useMemo(() => {
    let result = [...tools];

    // View filter
    if (view === "favorites") {
      result = result.filter((t) => t.favorited);
    }

    // Section filter
    if (sectionFilter !== "all") {
      result = result.filter((t) => t.section === sectionFilter);
    }

    // Category filter
    if (selectedCategories.length > 0) {
      result = result.filter((t) => selectedCategories.includes(t.category));
    }

    // Search
    if (search.trim()) {
      const q = search.toLowerCase();
      result = result.filter(
        (t) =>
          t.name.toLowerCase().includes(q) ||
          t.description.toLowerCase().includes(q)
      );
    }

    return result;
  }, [tools, view, sectionFilter, selectedCategories, search]);

  // Actions
  const toggleFavorite = async (id: number) => {
    // Optimistic update
    setTools((prev) =>
      prev.map((t) => (t.id === id ? { ...t, favorited: !t.favorited } : t))
    );
    await fetch("/api/favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "toggle_favorite", id }),
    });
  };

  const updateCategory = async (id: number, category: string) => {
    setTools((prev) =>
      prev.map((t) => (t.id === id ? { ...t, category } : t))
    );
    await fetch("/api/favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "update_category", id, category }),
    });
  };

  const toggleCategory = (cat: string) => {
    setSelectedCategories((prev) =>
      prev.includes(cat) ? prev.filter((c) => c !== cat) : [...prev, cat]
    );
  };

  const favCount = tools.filter((t) => t.favorited).length;

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-surface-0/80 backdrop-blur-xl border-b border-surface-3">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-accent to-cyan-600 flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-surface-0" />
              </div>
              <div>
                <h1 className="font-display font-bold text-lg text-gray-100">
                  AI Tool Tracker
                </h1>
                <p className="text-[11px] font-mono text-gray-500 -mt-0.5">
                  {tools.length} tools indexed
                </p>
              </div>
            </div>

            <SyncButton
              authenticated={authenticated}
              authUrl={authUrl}
              onSyncComplete={fetchTools}
            />
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        {/* Controls bar */}
        <div className="flex flex-col gap-5 mb-8">
          {/* View toggle + Search */}
          <div className="flex items-center gap-4">
            {/* View tabs */}
            <div className="flex items-center bg-surface-1 rounded-xl border border-surface-3 p-1">
              <button
                onClick={() => setView("all")}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-sm font-display font-medium transition-all ${
                  view === "all"
                    ? "bg-surface-3 text-gray-100"
                    : "text-gray-500 hover:text-gray-300"
                }`}
              >
                <LayoutList className="w-3.5 h-3.5" />
                All Tools
              </button>
              <button
                onClick={() => setView("favorites")}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-sm font-display font-medium transition-all ${
                  view === "favorites"
                    ? "bg-surface-3 text-gray-100"
                    : "text-gray-500 hover:text-gray-300"
                }`}
              >
                <Heart className="w-3.5 h-3.5" />
                Favorites
                {favCount > 0 && (
                  <span className="text-[10px] font-mono bg-fav/15 text-fav px-1.5 py-0.5 rounded-full">
                    {favCount}
                  </span>
                )}
              </button>
            </div>

            {/* Section filter */}
            <div className="flex items-center bg-surface-1 rounded-xl border border-surface-3 p-1">
              {(["all", "daily", "notable"] as SectionFilter[]).map((s) => (
                <button
                  key={s}
                  onClick={() => setSectionFilter(s)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-mono uppercase tracking-wider transition-all ${
                    sectionFilter === s
                      ? "bg-surface-3 text-gray-100"
                      : "text-gray-500 hover:text-gray-300"
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>

            {/* Search */}
            <div className="flex-1">
              <SearchBar value={search} onChange={setSearch} />
            </div>
          </div>

          {/* Category chips */}
          <CategoryFilter
            categories={
              categories.length > 0
                ? categories
                : [
                    "Productivity",
                    "Creative",
                    "Marketing",
                    "Finance",
                    "Developer",
                    "Data & Analytics",
                    "Sales",
                    "HR & Recruiting",
                    "Communication",
                    "Other",
                  ]
            }
            selected={selectedCategories}
            onToggle={toggleCategory}
            onClear={() => setSelectedCategories([])}
          />
        </div>

        {/* Results */}
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <div className="text-center">
              <div className="w-8 h-8 border-2 border-accent/30 border-t-accent rounded-full animate-spin mx-auto mb-3" />
              <p className="text-sm text-gray-500 font-mono">
                Loading tools...
              </p>
            </div>
          </div>
        ) : filteredTools.length === 0 ? (
          <div className="text-center py-20">
            <div className="w-16 h-16 rounded-2xl bg-surface-2 flex items-center justify-center mx-auto mb-4">
              {view === "favorites" ? (
                <Heart className="w-7 h-7 text-gray-600" />
              ) : (
                <Search className="w-7 h-7 text-gray-600" />
              )}
            </div>
            <p className="text-gray-400 font-display font-medium mb-1">
              {view === "favorites"
                ? "No favorites yet"
                : tools.length === 0
                ? "No tools synced yet"
                : "No tools match your filters"}
            </p>
            <p className="text-sm text-gray-600">
              {view === "favorites"
                ? "Heart some tools to see them here"
                : tools.length === 0
                ? "Connect Gmail and sync to get started"
                : "Try adjusting your search or category filters"}
            </p>
          </div>
        ) : (
          <>
            <p className="text-xs font-mono text-gray-500 mb-4">
              {filteredTools.length} tool
              {filteredTools.length !== 1 ? "s" : ""}{" "}
              {search || selectedCategories.length > 0 ? "matching" : ""}
            </p>
            <div className="grid gap-3">
              {filteredTools.map((tool, i) => (
                <ToolCard
                  key={tool.id}
                  tool={tool}
                  index={i}
                  onToggleFavorite={toggleFavorite}
                  onUpdateCategory={updateCategory}
                />
              ))}
            </div>
          </>
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-surface-3 mt-16">
        <div className="max-w-6xl mx-auto px-6 py-6">
          <p className="text-xs font-mono text-gray-600 text-center">
            Parsed from There&apos;s An AI For That newsletter • Built with
            Next.js
          </p>
        </div>
      </footer>
    </div>
  );
}
ENDOFFILE_009
echo "  ✅ src/app/page.tsx"

# ── src/app/api/auth/route.ts ──
cat > "src/app/api/auth/route.ts" << 'ENDOFFILE_010'
import { NextResponse } from "next/server";
import { getAuthUrl, isAuthenticated } from "@/lib/gmail";

export async function GET() {
  if (isAuthenticated()) {
    return NextResponse.json({ authenticated: true });
  }

  const url = getAuthUrl();
  return NextResponse.json({ authenticated: false, authUrl: url });
}
ENDOFFILE_010
echo "  ✅ src/app/api/auth/route.ts"

# ── src/app/api/callback/route.ts ──
cat > "src/app/api/callback/route.ts" << 'ENDOFFILE_011'
import { NextRequest, NextResponse } from "next/server";
import { getOAuthClient } from "@/lib/gmail";
import { saveTokens } from "@/lib/db";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");

  if (!code) {
    return NextResponse.redirect(
      new URL("/?error=no_code", process.env.NEXT_PUBLIC_BASE_URL!)
    );
  }

  try {
    const client = getOAuthClient();
    const { tokens } = await client.getToken(code);

    saveTokens(
      tokens.access_token!,
      tokens.refresh_token!,
      tokens.expiry_date
        ? new Date(tokens.expiry_date).toISOString()
        : new Date(Date.now() + 3600 * 1000).toISOString()
    );

    return NextResponse.redirect(
      new URL("/?auth=success", process.env.NEXT_PUBLIC_BASE_URL!)
    );
  } catch (error) {
    console.error("OAuth callback error:", error);
    return NextResponse.redirect(
      new URL("/?error=auth_failed", process.env.NEXT_PUBLIC_BASE_URL!)
    );
  }
}
ENDOFFILE_011
echo "  ✅ src/app/api/callback/route.ts"

# ── src/app/api/sync/route.ts ──
cat > "src/app/api/sync/route.ts" << 'ENDOFFILE_012'
import { NextResponse } from "next/server";
import { google } from "googleapis";
import { getOAuthClient, isAuthenticated } from "@/lib/gmail";
import { insertTool, getDb } from "@/lib/db";
import { parseNewsletter, parseNewsletterPlainText } from "@/lib/parser";

export async function POST() {
  if (!isAuthenticated()) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }

  try {
    const auth = getOAuthClient();
    const gmail = google.gmail({ version: "v1", auth });

    // Search for emails from the newsletter sender
    const query = "from:hi@mail.theresanaiforthat.com";

    const listResponse = await gmail.users.messages.list({
      userId: "me",
      q: query,
      maxResults: 50, // Adjust as needed
    });

    const messages = listResponse.data.messages || [];
    let newToolsCount = 0;
    let processedEmails = 0;

    for (const msg of messages) {
      if (!msg.id) continue;

      // Check if we've already processed this email
      const db = getDb();
      const existing = db
        .prepare("SELECT 1 FROM tools WHERE email_id = ? LIMIT 1")
        .get(msg.id);
      if (existing) continue;

      // Fetch full email
      const email = await gmail.users.messages.get({
        userId: "me",
        id: msg.id,
        format: "full",
      });

      // Extract date from headers
      const headers = email.data.payload?.headers || [];
      const dateHeader = headers.find(
        (h) => h.name?.toLowerCase() === "date"
      );
      const emailDate = dateHeader?.value
        ? new Date(dateHeader.value).toISOString().split("T")[0]
        : new Date().toISOString().split("T")[0];

      // Extract body (HTML preferred, fall back to plain text)
      const { html, text } = extractBody(email.data.payload);

      let tools;
      if (html) {
        tools = parseNewsletter(html);
      } else if (text) {
        tools = parseNewsletterPlainText(text);
      } else {
        continue;
      }

      // Insert tools
      for (const tool of tools) {
        const result = insertTool({
          ...tool,
          email_date: emailDate,
          email_id: msg.id,
        });
        if (result.changes > 0) newToolsCount++;
      }

      processedEmails++;
    }

    // Update sync state
    const db = getDb();
    db.prepare(
      `INSERT INTO sync_state (id, last_synced)
       VALUES (1, datetime('now'))
       ON CONFLICT(id) DO UPDATE SET last_synced = excluded.last_synced`
    ).run();

    return NextResponse.json({
      success: true,
      processedEmails,
      newTools: newToolsCount,
      totalEmails: messages.length,
    });
  } catch (error: any) {
    console.error("Sync error:", error);
    return NextResponse.json(
      { error: error.message || "Sync failed" },
      { status: 500 }
    );
  }
}

// ── Helper to extract HTML and plain text body from Gmail message payload ──

function extractBody(payload: any): { html: string; text: string } {
  let html = "";
  let text = "";

  if (!payload) return { html, text };

  // Simple single-part message
  if (payload.body?.data) {
    const decoded = Buffer.from(payload.body.data, "base64url").toString(
      "utf-8"
    );
    if (payload.mimeType === "text/html") html = decoded;
    else if (payload.mimeType === "text/plain") text = decoded;
  }

  // Multipart message - recurse through parts
  if (payload.parts) {
    for (const part of payload.parts) {
      if (part.mimeType === "text/html" && part.body?.data) {
        html = Buffer.from(part.body.data, "base64url").toString("utf-8");
      } else if (part.mimeType === "text/plain" && part.body?.data) {
        text = Buffer.from(part.body.data, "base64url").toString("utf-8");
      } else if (part.parts) {
        // Nested multipart (e.g., multipart/alternative inside multipart/mixed)
        const nested = extractBody(part);
        if (nested.html) html = nested.html;
        if (nested.text) text = nested.text;
      }
    }
  }

  return { html, text };
}
ENDOFFILE_012
echo "  ✅ src/app/api/sync/route.ts"

# ── src/app/api/tools/route.ts ──
cat > "src/app/api/tools/route.ts" << 'ENDOFFILE_013'
import { NextRequest, NextResponse } from "next/server";
import { getAllTools, getDistinctCategories } from "@/lib/db";

export async function GET(request: NextRequest) {
  try {
    const tools = getAllTools();
    const categories = getDistinctCategories();

    return NextResponse.json({ tools, categories });
  } catch (error: any) {
    console.error("Error fetching tools:", error);
    return NextResponse.json(
      { error: error.message || "Failed to fetch tools" },
      { status: 500 }
    );
  }
}
ENDOFFILE_013
echo "  ✅ src/app/api/tools/route.ts"

# ── src/app/api/favorites/route.ts ──
cat > "src/app/api/favorites/route.ts" << 'ENDOFFILE_014'
import { NextRequest, NextResponse } from "next/server";
import { toggleFavorite, updateCategory } from "@/lib/db";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, id, category } = body;

    if (action === "toggle_favorite" && id) {
      toggleFavorite(id);
      return NextResponse.json({ success: true });
    }

    if (action === "update_category" && id && category) {
      updateCategory(id, category);
      return NextResponse.json({ success: true });
    }

    return NextResponse.json({ error: "Invalid action" }, { status: 400 });
  } catch (error: any) {
    console.error("Favorites error:", error);
    return NextResponse.json(
      { error: error.message || "Failed" },
      { status: 500 }
    );
  }
}
ENDOFFILE_014
echo "  ✅ src/app/api/favorites/route.ts"

# ── src/components/ToolCard.tsx ──
cat > "src/components/ToolCard.tsx" << 'ENDOFFILE_015'
"use client";

import { Heart, ExternalLink, Tag } from "lucide-react";
import { AITool, CATEGORIES } from "@/lib/types";

interface ToolCardProps {
  tool: AITool;
  index: number;
  onToggleFavorite: (id: number) => void;
  onUpdateCategory: (id: number, category: string) => void;
}

export default function ToolCard({
  tool,
  index,
  onToggleFavorite,
  onUpdateCategory,
}: ToolCardProps) {
  return (
    <div
      className={`card-hover p-5 group animate-fade-up`}
      style={{ animationDelay: `${Math.min(index * 0.03, 0.3)}s` }}
    >
      <div className="flex items-start justify-between gap-3">
        {/* Emoji + Name + Description */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2.5 mb-2">
            <span className="text-xl flex-shrink-0">{tool.emoji}</span>
            <h3 className="font-display font-bold text-gray-100 text-base truncate">
              {tool.name}
            </h3>
            <span
              className={`text-[10px] font-mono uppercase tracking-wider px-1.5 py-0.5 rounded ${
                tool.section === "daily"
                  ? "bg-accent/10 text-accent"
                  : "bg-warn/10 text-warn"
              }`}
            >
              {tool.section === "daily" ? "daily" : "notable"}
            </span>
          </div>

          <p className="text-sm text-gray-400 leading-relaxed line-clamp-2 mb-3">
            {tool.description}
          </p>

          <div className="flex items-center gap-2 flex-wrap">
            {/* Category chip */}
            <div className="relative">
              <select
                value={tool.category}
                onChange={(e) => onUpdateCategory(tool.id, e.target.value)}
                className="chip appearance-none cursor-pointer pr-6 bg-surface-3 border-surface-4
                           hover:border-accent/30 hover:text-accent transition-colors"
                title="Change category"
              >
                {CATEGORIES.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
              <Tag className="absolute right-1.5 top-1/2 -translate-y-1/2 w-3 h-3 text-gray-500 pointer-events-none" />
            </div>

            {/* Date */}
            <span className="text-[11px] font-mono text-gray-600">
              {tool.email_date}
            </span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-col items-center gap-2 flex-shrink-0">
          <button
            onClick={() => onToggleFavorite(tool.id)}
            className={`p-2 rounded-lg transition-all duration-200 ${
              tool.favorited
                ? "text-fav bg-fav/10"
                : "text-gray-600 hover:text-fav hover:bg-fav/5"
            }`}
            title={tool.favorited ? "Remove from favorites" : "Add to favorites"}
          >
            <Heart
              className="w-4 h-4"
              fill={tool.favorited ? "currentColor" : "none"}
            />
          </button>

          {tool.url && (
            <a
              href={tool.url}
              target="_blank"
              rel="noopener noreferrer"
              className="p-2 rounded-lg text-gray-600 hover:text-accent hover:bg-accent/5 transition-all duration-200"
              title="Visit tool"
            >
              <ExternalLink className="w-4 h-4" />
            </a>
          )}
        </div>
      </div>
    </div>
  );
}
ENDOFFILE_015
echo "  ✅ src/components/ToolCard.tsx"

# ── src/components/SearchBar.tsx ──
cat > "src/components/SearchBar.tsx" << 'ENDOFFILE_016'
"use client";

import { Search, X } from "lucide-react";

interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
}

export default function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <div className="relative">
      <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Search tools by name or description..."
        className="search-input"
      />
      {value && (
        <button
          onClick={() => onChange("")}
          className="absolute right-3 top-1/2 -translate-y-1/2 p-1 rounded-md
                     text-gray-500 hover:text-gray-300 hover:bg-surface-3 transition-colors"
        >
          <X className="w-3.5 h-3.5" />
        </button>
      )}
    </div>
  );
}
ENDOFFILE_016
echo "  ✅ src/components/SearchBar.tsx"

# ── src/components/CategoryFilter.tsx ──
cat > "src/components/CategoryFilter.tsx" << 'ENDOFFILE_017'
"use client";

interface CategoryFilterProps {
  categories: string[];
  selected: string[];
  onToggle: (category: string) => void;
  onClear: () => void;
}

export default function CategoryFilter({
  categories,
  selected,
  onToggle,
  onClear,
}: CategoryFilterProps) {
  return (
    <div className="flex items-center gap-2 flex-wrap">
      <button
        onClick={onClear}
        className={selected.length === 0 ? "chip-active" : "chip hover:text-gray-200"}
      >
        All
      </button>
      {categories.map((cat) => (
        <button
          key={cat}
          onClick={() => onToggle(cat)}
          className={
            selected.includes(cat)
              ? "chip-active"
              : "chip hover:text-gray-200 hover:border-gray-500"
          }
        >
          {cat}
        </button>
      ))}
    </div>
  );
}
ENDOFFILE_017
echo "  ✅ src/components/CategoryFilter.tsx"

# ── src/components/SyncButton.tsx ──
cat > "src/components/SyncButton.tsx" << 'ENDOFFILE_018'
"use client";

import { RefreshCw, LogIn } from "lucide-react";
import { useState } from "react";

interface SyncButtonProps {
  authenticated: boolean;
  authUrl?: string;
  onSyncComplete: () => void;
}

export default function SyncButton({
  authenticated,
  authUrl,
  onSyncComplete,
}: SyncButtonProps) {
  const [syncing, setSyncing] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  const handleSync = async () => {
    setSyncing(true);
    setResult(null);
    try {
      const res = await fetch("/api/sync", { method: "POST" });
      const data = await res.json();
      if (data.success) {
        setResult(
          `Synced ${data.processedEmails} emails → ${data.newTools} new tools`
        );
        onSyncComplete();
      } else {
        setResult(data.error || "Sync failed");
      }
    } catch (err) {
      setResult("Sync failed — check console");
    } finally {
      setSyncing(false);
      setTimeout(() => setResult(null), 4000);
    }
  };

  if (!authenticated) {
    return (
      <a href={authUrl} className="btn-primary">
        <LogIn className="w-4 h-4" />
        Connect Gmail
      </a>
    );
  }

  return (
    <div className="flex items-center gap-3">
      <button
        onClick={handleSync}
        disabled={syncing}
        className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <RefreshCw className={`w-4 h-4 ${syncing ? "animate-spin" : ""}`} />
        {syncing ? "Syncing..." : "Sync Emails"}
      </button>
      {result && (
        <span className="text-xs font-mono text-gray-400 animate-fade-up">
          {result}
        </span>
      )}
    </div>
  );
}
ENDOFFILE_018
echo "  ✅ src/components/SyncButton.tsx"

# ── src/lib/types.ts ──
cat > "src/lib/types.ts" << 'ENDOFFILE_019'
export interface AITool {
  id: number;
  name: string;
  url: string;
  description: string;
  section: "daily" | "notable";
  category: string;
  emoji: string;
  email_date: string;
  email_id: string;
  favorited: boolean;
  created_at: string;
}

export interface ToolFilters {
  search: string;
  categories: string[];
  section: "all" | "daily" | "notable";
}

export const CATEGORIES = [
  "Productivity",
  "Creative",
  "Marketing",
  "Finance",
  "Health",
  "Developer",
  "Data & Analytics",
  "Sales",
  "HR & Recruiting",
  "Education",
  "Communication",
  "Security",
  "Other",
] as const;

export type Category = (typeof CATEGORIES)[number];

// Simple keyword → category mapping for auto-tagging
export const CATEGORY_KEYWORDS: Record<string, Category> = {
  // Productivity
  workspace: "Productivity",
  task: "Productivity",
  automate: "Productivity",
  workflow: "Productivity",
  planning: "Productivity",
  organiz: "Productivity",
  project: "Productivity",
  // Creative
  design: "Creative",
  art: "Creative",
  image: "Creative",
  video: "Creative",
  music: "Creative",
  photo: "Creative",
  creative: "Creative",
  generate: "Creative",
  // Marketing
  marketing: "Marketing",
  seo: "Marketing",
  social: "Marketing",
  brand: "Marketing",
  content: "Marketing",
  competitor: "Marketing",
  advertis: "Marketing",
  campaign: "Marketing",
  // Finance
  trading: "Finance",
  financ: "Finance",
  invest: "Finance",
  crypto: "Finance",
  defi: "Finance",
  wallet: "Finance",
  money: "Finance",
  revenue: "Finance",
  monetiz: "Finance",
  // Health
  health: "Health",
  medical: "Health",
  fitness: "Health",
  wellness: "Health",
  mental: "Health",
  // Developer
  code: "Developer",
  api: "Developer",
  github: "Developer",
  deploy: "Developer",
  debug: "Developer",
  developer: "Developer",
  open-source: "Developer",
  sdk: "Developer",
  programming: "Developer",
  // Data & Analytics
  data: "Data & Analytics",
  analyt: "Data & Analytics",
  dashboard: "Data & Analytics",
  chart: "Data & Analytics",
  insight: "Data & Analytics",
  report: "Data & Analytics",
  sql: "Data & Analytics",
  // Sales
  sales: "Sales",
  crm: "Sales",
  lead: "Sales",
  outreach: "Sales",
  prospect: "Sales",
  pipeline: "Sales",
  // HR & Recruiting
  hiring: "HR & Recruiting",
  recruit: "HR & Recruiting",
  interview: "HR & Recruiting",
  resume: "HR & Recruiting",
  talent: "HR & Recruiting",
  hr: "HR & Recruiting",
  job: "HR & Recruiting",
  // Education
  learn: "Education",
  course: "Education",
  education: "Education",
  study: "Education",
  tutor: "Education",
  teach: "Education",
  // Communication
  meeting: "Communication",
  chat: "Communication",
  slack: "Communication",
  teams: "Communication",
  email: "Communication",
  message: "Communication",
  // Security
  security: "Security",
  privacy: "Security",
  encrypt: "Security",
  threat: "Security",
  vulnerab: "Security",
};

export function inferCategory(name: string, description: string): Category {
  const text = `${name} ${description}`.toLowerCase();

  // Score each category by keyword matches
  const scores: Partial<Record<Category, number>> = {};

  for (const [keyword, category] of Object.entries(CATEGORY_KEYWORDS)) {
    if (text.includes(keyword.toLowerCase())) {
      scores[category] = (scores[category] || 0) + 1;
    }
  }

  // Return highest-scoring category, or "Other"
  const sorted = Object.entries(scores).sort(
    ([, a], [, b]) => (b as number) - (a as number)
  );

  return sorted.length > 0 ? (sorted[0][0] as Category) : "Other";
}
ENDOFFILE_019
echo "  ✅ src/lib/types.ts"

# ── src/lib/db.ts ──
cat > "src/lib/db.ts" << 'ENDOFFILE_020'
import Database from "better-sqlite3";
import path from "path";

const DB_PATH = path.join(process.cwd(), "data", "tools.db");

let db: Database.Database | null = null;

export function getDb(): Database.Database {
  if (!db) {
    // Ensure data directory exists
    const fs = require("fs");
    const dir = path.dirname(DB_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    db = new Database(DB_PATH);
    db.pragma("journal_mode = WAL");
    db.pragma("foreign_keys = ON");

    // Create tables
    db.exec(`
      CREATE TABLE IF NOT EXISTS tools (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        section TEXT NOT NULL CHECK(section IN ('daily', 'notable')),
        category TEXT NOT NULL DEFAULT 'Other',
        emoji TEXT NOT NULL DEFAULT '',
        email_date TEXT NOT NULL,
        email_id TEXT NOT NULL,
        favorited INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(name, email_id)
      );

      CREATE TABLE IF NOT EXISTS auth (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        access_token TEXT,
        refresh_token TEXT,
        expiry TEXT,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );

      CREATE TABLE IF NOT EXISTS sync_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        last_synced TEXT,
        last_history_id TEXT
      );

      CREATE INDEX IF NOT EXISTS idx_tools_category ON tools(category);
      CREATE INDEX IF NOT EXISTS idx_tools_favorited ON tools(favorited);
      CREATE INDEX IF NOT EXISTS idx_tools_email_date ON tools(email_date);
    `);
  }

  return db;
}

// ── Auth helpers ──

export function getTokens() {
  const db = getDb();
  return db.prepare("SELECT * FROM auth WHERE id = 1").get() as
    | { access_token: string; refresh_token: string; expiry: string }
    | undefined;
}

export function saveTokens(
  accessToken: string,
  refreshToken: string,
  expiry: string
) {
  const db = getDb();
  db.prepare(
    `INSERT INTO auth (id, access_token, refresh_token, expiry, updated_at)
     VALUES (1, ?, ?, ?, datetime('now'))
     ON CONFLICT(id) DO UPDATE SET
       access_token = excluded.access_token,
       refresh_token = excluded.refresh_token,
       expiry = excluded.expiry,
       updated_at = excluded.updated_at`
  ).run(accessToken, refreshToken, expiry);
}

// ── Tool helpers ──

export function insertTool(tool: {
  name: string;
  url: string;
  description: string;
  section: string;
  category: string;
  emoji: string;
  email_date: string;
  email_id: string;
}) {
  const db = getDb();
  return db
    .prepare(
      `INSERT OR IGNORE INTO tools (name, url, description, section, category, emoji, email_date, email_id)
     VALUES (@name, @url, @description, @section, @category, @emoji, @email_date, @email_id)`
    )
    .run(tool);
}

export function getAllTools() {
  const db = getDb();
  return db
    .prepare("SELECT * FROM tools ORDER BY email_date DESC, id DESC")
    .all();
}

export function toggleFavorite(id: number) {
  const db = getDb();
  return db
    .prepare("UPDATE tools SET favorited = NOT favorited WHERE id = ?")
    .run(id);
}

export function updateCategory(id: number, category: string) {
  const db = getDb();
  return db
    .prepare("UPDATE tools SET category = ? WHERE id = ?")
    .run(category, id);
}

export function getDistinctCategories(): string[] {
  const db = getDb();
  const rows = db
    .prepare("SELECT DISTINCT category FROM tools ORDER BY category")
    .all() as { category: string }[];
  return rows.map((r) => r.category);
}
ENDOFFILE_020
echo "  ✅ src/lib/db.ts"

# ── src/lib/gmail.ts ──
cat > "src/lib/gmail.ts" << 'ENDOFFILE_021'
import { google } from "googleapis";
import { getTokens, saveTokens } from "./db";

const SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"];

export function getOAuthClient() {
  const client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    `${process.env.NEXT_PUBLIC_BASE_URL}/api/callback`
  );

  // Load saved tokens if available
  const tokens = getTokens();
  if (tokens) {
    client.setCredentials({
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expiry_date: new Date(tokens.expiry).getTime(),
    });

    // Auto-save refreshed tokens
    client.on("tokens", (newTokens) => {
      saveTokens(
        newTokens.access_token || tokens.access_token,
        newTokens.refresh_token || tokens.refresh_token,
        newTokens.expiry_date
          ? new Date(newTokens.expiry_date).toISOString()
          : tokens.expiry
      );
    });
  }

  return client;
}

export function getAuthUrl() {
  const client = getOAuthClient();
  return client.generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: SCOPES,
  });
}

export function isAuthenticated(): boolean {
  const tokens = getTokens();
  return !!tokens?.access_token;
}
ENDOFFILE_021
echo "  ✅ src/lib/gmail.ts"

# ── src/lib/parser.ts ──
cat > "src/lib/parser.ts" << 'ENDOFFILE_022'
import * as cheerio from "cheerio";
import { inferCategory } from "./types";

export interface ParsedTool {
  name: string;
  url: string;
  description: string;
  section: "daily" | "notable";
  category: string;
  emoji: string;
}

/**
 * Parse the "There's an AI for That" newsletter HTML to extract tools
 * from "AI Tools of the Day" and "Notable AI Tools" sections.
 *
 * The email structure (from analyzing multiple issues):
 * - Each tool entry is a line starting with an emoji
 * - The tool name is usually bold or linked
 * - The description follows after the name
 * - Sections are separated by headers containing "AI Tools of the Day" / "Notable AI Tools"
 */
export function parseNewsletter(html: string): ParsedTool[] {
  const tools: ParsedTool[] = [];

  // Strategy: use cheerio to extract text + links, then parse line by line
  const $ = cheerio.load(html);

  // Get the full text to find section boundaries
  const fullText = $("body").text();

  // Find section markers
  const dailyMarker = "AI Tools of the Day";
  const notableMarker = "Notable AI Tools";

  // We'll work with the raw HTML to extract links alongside text
  // Find all table cells / divs that contain tool entries
  // The newsletter is typically table-based email HTML

  // Approach: iterate through all text nodes and links,
  // building a line-by-line representation with link targets preserved

  const lines = extractLinesWithLinks($);

  let currentSection: "daily" | "notable" | null = null;

  for (const line of lines) {
    const text = line.text.trim();

    // Detect section headers
    if (text.includes(dailyMarker)) {
      currentSection = "daily";
      continue;
    }
    if (text.includes(notableMarker)) {
      currentSection = "notable";
      continue;
    }

    // Stop parsing at known section terminators
    if (
      currentSection &&
      (text.includes("Submit your AI tool") ||
        text.includes("Interesting AI") ||
        text.includes("AI Finds") ||
        text.includes("Beyond the Feed") ||
        text.includes("Open Source Finds") ||
        text.includes("Prompt of the Day"))
    ) {
      if (currentSection === "daily" && !text.includes(notableMarker)) {
        currentSection = null;
      }
      if (currentSection === "notable") {
        currentSection = null;
      }
    }

    if (!currentSection) continue;

    // Tool entries start with an emoji
    const emojiMatch = text.match(
      /^([\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FEFF}]|[\u{1F900}-\u{1F9FF}]|[🤖⚽📍📊🎙️🔎🎨🦾🎯💡🧠🩺🍎🖥️📦🔧✨🚀💰🎵📱🔒🏥📈🛡️📝🎮🏠🌍📸🎬🤝💬📧🛒🔗⭐🏆🎯])/u
    );

    if (!emojiMatch) continue;

    const emoji = emojiMatch[1];
    const afterEmoji = text.slice(emojiMatch[0].length).trim();

    // Extract tool name and description
    // Pattern: "ToolName description that explains what it does."
    // The tool name is typically the first few words (often bold/linked in HTML)
    const toolData = extractToolNameAndDescription(afterEmoji, line.links);

    if (toolData) {
      const category = inferCategory(toolData.name, toolData.description);

      tools.push({
        name: toolData.name,
        url: toolData.url,
        description: toolData.description,
        section: currentSection,
        category,
        emoji,
      });
    }
  }

  return tools;
}

interface LineWithLinks {
  text: string;
  links: { text: string; href: string }[];
}

function extractLinesWithLinks($: cheerio.CheerioAPI): LineWithLinks[] {
  const lines: LineWithLinks[] = [];

  // Process the body content, splitting by common email structure elements
  // Newsletter emails use <tr>, <td>, <p>, <div> for structure
  const blocks: cheerio.Cheerio<cheerio.Element>[] = [];

  $("td, p, div, li").each((_, el) => {
    const $el = $(el);
    // Only process leaf-ish elements (ones that directly contain text)
    const directText = $el
      .contents()
      .filter((_, node) => node.type === "text")
      .text()
      .trim();
    const hasDirectContent =
      directText.length > 0 || $el.find("a, strong, b, span").length > 0;

    if (hasDirectContent) {
      const text = $el.text().trim();
      if (text.length > 10) {
        // Skip tiny fragments
        const links: { text: string; href: string }[] = [];
        $el.find("a").each((_, a) => {
          const href = $(a).attr("href") || "";
          const linkText = $(a).text().trim();
          if (href && linkText) {
            links.push({ text: linkText, href });
          }
        });
        lines.push({ text, links });
      }
    }
  });

  return lines;
}

function extractToolNameAndDescription(
  text: string,
  links: { text: string; href: string }[]
): { name: string; url: string; description: string } | null {
  if (text.length < 10) return null;

  // Try to find the tool name from links first (it's usually the linked text)
  let name = "";
  let url = "";
  let description = text;

  // Check if any link text appears at the start of the line
  for (const link of links) {
    if (link.text.length > 2 && text.startsWith(link.text)) {
      name = link.text;
      url = cleanTrackingUrl(link.href);
      description = text.slice(link.text.length).trim();
      break;
    }
  }

  // If no link match, try to extract name from text pattern
  // Pattern: "Name does something..." - name is typically 1-3 words before a verb
  if (!name) {
    const verbPattern =
      /^(.+?)\s+(is|does|helps|lets|finds|maps|tracks|connects|analyzes|monitors|listens|replaces|lives|gives|scans|runs|writes|turns|converts|creates|provides|offers|makes|builds|uses|shows|generates|automates|manages|detects|identifies|discovers|surfaces|streamlines|simplifies|transforms|combines|enables)/i;
    const match = text.match(verbPattern);
    if (match) {
      name = match[1].trim();
      description = text;
      // Try to find URL from any link
      if (links.length > 0) {
        url = cleanTrackingUrl(links[0].href);
      }
    }
  }

  // Last resort: first word(s) as name
  if (!name) {
    const words = text.split(/\s+/);
    name = words.slice(0, 2).join(" ");
    description = text;
    if (links.length > 0) {
      url = cleanTrackingUrl(links[0].href);
    }
  }

  // Clean up description
  description = description.replace(/^\s*[-–—:,]\s*/, "").trim();

  return { name, url, description };
}

/**
 * Attempt to extract the final destination URL from newsletter tracking URLs.
 * Many newsletters wrap links in tracking redirects.
 */
function cleanTrackingUrl(url: string): string {
  try {
    const parsed = new URL(url);
    // Common tracking URL parameter names for the final destination
    const destParams = ["url", "redirect", "dest", "destination", "u", "link"];
    for (const param of destParams) {
      const dest = parsed.searchParams.get(param);
      if (dest && dest.startsWith("http")) {
        return dest;
      }
    }
  } catch {
    // Not a valid URL, return as-is
  }
  return url;
}

/**
 * Parse from plain text (fallback when HTML isn't available).
 * Less reliable since links are stripped, but captures names and descriptions.
 */
export function parseNewsletterPlainText(text: string): ParsedTool[] {
  const tools: ParsedTool[] = [];
  const lines = text.split("\n");

  let currentSection: "daily" | "notable" | null = null;

  for (const line of lines) {
    const trimmed = line.trim();

    if (trimmed.includes("AI Tools of the Day")) {
      currentSection = "daily";
      continue;
    }
    if (trimmed.includes("Notable AI Tools")) {
      currentSection = "notable";
      continue;
    }
    if (
      currentSection &&
      (trimmed.includes("Submit your AI tool") ||
        trimmed.includes("Interesting AI") ||
        trimmed.includes("AI Finds") ||
        trimmed.includes("Beyond the Feed") ||
        trimmed.includes("Open Source Finds"))
    ) {
      currentSection = null;
    }

    if (!currentSection) continue;

    // Match emoji-prefixed lines
    const emojiMatch = trimmed.match(
      /^([\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FEFF}]|[\u{1F900}-\u{1F9FF}]|[🤖⚽📍📊🎙️🔎🎨🦾🎯💡🧠🩺🍎🖥️📦🔧✨🚀💰🎵📱🔒🏥📈🛡️📝🎮🏠🌍📸🎬🤝💬📧🛒🔗⭐🏆])\s*/u
    );

    if (!emojiMatch) continue;

    const emoji = emojiMatch[1];
    const afterEmoji = trimmed.slice(emojiMatch[0].length).trim();

    // Try verb-based split
    const verbPattern =
      /^(.+?)\s+(is|does|helps|lets|finds|maps|tracks|connects|analyzes|monitors|listens|replaces|lives|gives|scans|runs|writes|turns|converts|creates|provides|offers|makes|builds|uses|shows|generates|automates|manages|detects|identifies|discovers|surfaces|streamlines|simplifies|transforms|combines|enables)/i;
    const match = afterEmoji.match(verbPattern);

    let name: string;
    let description: string;

    if (match) {
      name = match[1].trim();
      description = afterEmoji;
    } else {
      const words = afterEmoji.split(/\s+/);
      name = words.slice(0, 2).join(" ");
      description = afterEmoji;
    }

    const category = inferCategory(name, description);

    tools.push({
      name,
      url: "",
      description,
      section: currentSection,
      category,
      emoji,
    });
  }

  return tools;
}
ENDOFFILE_022
echo "  ✅ src/lib/parser.ts"

# ── README.md ──
cat > "README.md" << 'ENDOFFILE_023'
# AI Tool Tracker

A personal dashboard that pulls AI tools from the **"There's an AI for That"** newsletter in your Gmail, parses them, and gives you a searchable, filterable, favoritable interface.

## Features

- **Gmail integration** — connects via OAuth, reads only emails from `hi@mail.theresanaiforthat.com`
- **Auto-parsing** — extracts tool name, link, and description from "AI Tools of the Day" and "Notable AI Tools" sections
- **Auto-categorization** — keyword-based category inference (Productivity, Creative, Finance, etc.)
- **Search** — full-text search across tool names and descriptions
- **Category filtering** — filter by one or more categories
- **Section filtering** — filter by Daily vs Notable
- **Favorites** — heart tools to build your curated list
- **Re-categorize** — change any tool's category via dropdown

## Setup

### 1. Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or use existing)
3. **Enable the Gmail API**: APIs & Services → Library → search "Gmail API" → Enable
4. **Create OAuth credentials**:
   - APIs & Services → Credentials → Create Credentials → OAuth client ID
   - Application type: **Web application**
   - Authorized redirect URIs: `http://localhost:3000/api/callback`
   - Copy the **Client ID** and **Client Secret**
5. **Configure OAuth consent screen**:
   - Set to "External" (or "Internal" if using Google Workspace)
   - Add your email as a test user
   - Add scope: `https://www.googleapis.com/auth/gmail.readonly`

### 2. Local Setup

```bash
# Clone and install
cd ai-tool-tracker
npm install

# Configure environment
cp .env.local.example .env.local
# Edit .env.local with your Google Client ID and Secret

# Run dev server
npm run dev
```

### 3. First Use

1. Open `http://localhost:3000`
2. Click **"Connect Gmail"** → authenticate with Google
3. Click **"Sync Emails"** → pulls and parses your newsletter emails
4. Browse, search, filter, and favorite your tools

## Tech Stack

- **Next.js 14** (App Router)
- **SQLite** via better-sqlite3 (local, zero-config database)
- **Gmail API** via googleapis
- **Cheerio** for HTML parsing
- **Tailwind CSS** for styling
- **Lucide** for icons

## Deployment Notes

For Vercel deployment, you'll need to swap SQLite for a hosted database (Supabase, PlanetScale, Turso, etc.) since Vercel's serverless functions don't persist filesystem state. The `db.ts` file is the only file that needs updating.

For production OAuth, update your Google Cloud redirect URI to `https://yourdomain.com/api/callback` and update `NEXT_PUBLIC_BASE_URL` in your env vars.

## Project Structure

```
src/
├── app/
│   ├── api/
│   │   ├── auth/       # GET: check auth status, return OAuth URL
│   │   ├── callback/   # GET: OAuth callback handler
│   │   ├── sync/       # POST: fetch & parse Gmail emails
│   │   ├── tools/      # GET: list all tools
│   │   └── favorites/  # POST: toggle favorite, update category
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx        # Main dashboard UI
├── components/
│   ├── CategoryFilter.tsx
│   ├── SearchBar.tsx
│   ├── SyncButton.tsx
│   └── ToolCard.tsx
└── lib/
    ├── db.ts           # SQLite database + helpers
    ├── gmail.ts        # OAuth client setup
    ├── parser.ts       # Newsletter HTML/text parser
    └── types.ts        # Types + category inference
```
ENDOFFILE_023
echo "  ✅ README.md"

echo ""
echo "📦 Installing dependencies..."
npm install

echo ""
echo "============================================================"
echo "✅ Project created successfully!"
echo ""
echo "Next steps:"
echo "  1. Copy .env.local.example to .env.local:"
echo "     cp .env.local.example .env.local"
echo ""
echo "  2. Add your Google OAuth credentials to .env.local"
echo "     (See README.md for Google Cloud Console setup)"
echo ""
echo "  3. Start the dev server:"
echo "     npm run dev"
echo ""
echo "  4. Open http://localhost:3000"
echo "     Connect Gmail → Sync Emails → browse tools"
echo "============================================================"
