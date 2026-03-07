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
