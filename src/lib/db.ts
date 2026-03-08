import { createClient } from "@libsql/client";

const db = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
});

// ── Initialize tables ──

let initialized = false;

async function ensureTables() {
  if (initialized) return;

  await db.batch([
    {
      sql: `CREATE TABLE IF NOT EXISTS tools (
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
      )`,
      args: [],
    },
    {
      sql: `CREATE TABLE IF NOT EXISTS auth (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        access_token TEXT,
        refresh_token TEXT,
        expiry TEXT,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )`,
      args: [],
    },
    {
      sql: `CREATE TABLE IF NOT EXISTS sync_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        last_synced TEXT,
        last_history_id TEXT
      )`,
      args: [],
    },
  ]);

  // Create indexes (these are safe to run repeatedly)
  await db.batch([
    { sql: "CREATE INDEX IF NOT EXISTS idx_tools_category ON tools(category)", args: [] },
    { sql: "CREATE INDEX IF NOT EXISTS idx_tools_favorited ON tools(favorited)", args: [] },
    { sql: "CREATE INDEX IF NOT EXISTS idx_tools_email_date ON tools(email_date)", args: [] },
  ]);

  initialized = true;
}

// ── Auth helpers ──

export async function getTokens() {
  await ensureTables();
  const result = await db.execute({
    sql: "SELECT * FROM auth WHERE id = 1",
    args: [],
  });
  if (result.rows.length === 0) return undefined;
  const row = result.rows[0];
  return {
    access_token: row.access_token as string,
    refresh_token: row.refresh_token as string,
    expiry: row.expiry as string,
  };
}

export async function saveTokens(
  accessToken: string,
  refreshToken: string,
  expiry: string
) {
  await ensureTables();
  await db.execute({
    sql: `INSERT INTO auth (id, access_token, refresh_token, expiry, updated_at)
     VALUES (1, ?, ?, ?, datetime('now'))
     ON CONFLICT(id) DO UPDATE SET
       access_token = excluded.access_token,
       refresh_token = excluded.refresh_token,
       expiry = excluded.expiry,
       updated_at = excluded.updated_at`,
    args: [accessToken, refreshToken, expiry],
  });
}

// ── Tool helpers ──

export async function insertTool(tool: {
  name: string;
  url: string;
  description: string;
  section: string;
  category: string;
  emoji: string;
  email_date: string;
  email_id: string;
}) {
  await ensureTables();
  const result = await db.execute({
    sql: `INSERT OR IGNORE INTO tools (name, url, description, section, category, emoji, email_date, email_id)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      tool.name,
      tool.url,
      tool.description,
      tool.section,
      tool.category,
      tool.emoji,
      tool.email_date,
      tool.email_id,
    ],
  });
  return { changes: result.rowsAffected };
}

export async function getAllTools() {
  await ensureTables();
  const result = await db.execute({
    sql: "SELECT * FROM tools ORDER BY email_date DESC, id DESC",
    args: [],
  });
  return result.rows;
}

export async function getToolById(
  id: number
): Promise<{ name: string; favorited: number } | null> {
  await ensureTables();
  const result = await db.execute({
    sql: "SELECT name, favorited FROM tools WHERE id = ?",
    args: [id],
  });
  if (result.rows.length === 0) return null;
  const row = result.rows[0] as Record<string, unknown>;
  const fav = row.favorited ?? row.Favorited;
  const favorited =
    fav === true || fav === 1 || fav === "1" ? 1 : 0;
  return {
    name: row.name as string,
    favorited,
  };
}

export async function toggleFavorite(id: number) {
  await ensureTables();
  await db.execute({
    sql: "UPDATE tools SET favorited = NOT favorited WHERE id = ?",
    args: [id],
  });
}

/** Set favorited (0 or 1) for all rows with the same normalized name. */
export async function setFavoritedByNormalizedName(
  normalizedName: string,
  favorited: number
) {
  await ensureTables();
  await db.execute({
    sql:
      "UPDATE tools SET favorited = ? WHERE LOWER(TRIM(name)) = ?",
    args: [favorited, normalizedName],
  });
}

export async function updateCategory(id: number, category: string) {
  await ensureTables();
  await db.execute({
    sql: "UPDATE tools SET category = ? WHERE id = ?",
    args: [category, id],
  });
}

export async function getDistinctCategories(): Promise<string[]> {
  await ensureTables();
  const result = await db.execute({
    sql: "SELECT DISTINCT category FROM tools ORDER BY category",
    args: [],
  });
  return result.rows.map((r) => r.category as string);
}

export async function checkEmailProcessed(emailId: string): Promise<boolean> {
  await ensureTables();
  const result = await db.execute({
    sql: "SELECT 1 FROM tools WHERE email_id = ? LIMIT 1",
    args: [emailId],
  });
  return result.rows.length > 0;
}

export async function updateSyncState() {
  await ensureTables();
  await db.execute({
    sql: `INSERT INTO sync_state (id, last_synced)
       VALUES (1, datetime('now'))
       ON CONFLICT(id) DO UPDATE SET last_synced = excluded.last_synced`,
    args: [],
  });
}