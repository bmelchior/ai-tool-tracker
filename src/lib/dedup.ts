import type { AITool } from "./types";

/** Normalize tool name for grouping (trim + lowercase). */
function normalizeName(name: string): string {
  return name.trim().toLowerCase();
}

/**
 * Dedupe tools by normalized name. Keeps the most recent row per tool
 * (by email_date then id) and merges favorited state (true if any duplicate is favorited).
 */
export function dedupeTools(tools: AITool[]): AITool[] {
  const byKey = new Map<string, AITool[]>();

  for (const t of tools) {
    const key = normalizeName(t.name);
    if (!byKey.has(key)) byKey.set(key, []);
    byKey.get(key)!.push(t);
  }

  const deduped: AITool[] = [];

  for (const group of byKey.values()) {
    const sorted = [...group].sort((a, b) => {
      const d = (b.email_date as string).localeCompare(a.email_date as string);
      if (d !== 0) return d;
      return (b.id as number) - (a.id as number);
    });
    const representative = sorted[0];
    const favorited = group.some((t) => !!t.favorited);
    deduped.push({
      ...representative,
      favorited,
    });
  }

  // Keep "by most recent" order
  deduped.sort((a, b) => {
    const d = b.email_date.localeCompare(a.email_date);
    if (d !== 0) return d;
    return b.id - a.id;
  });

  return deduped;
}
