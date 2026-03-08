import { NextRequest, NextResponse } from "next/server";
import { getAllTools, getDistinctCategories } from "@/lib/db";
import { dedupeTools } from "@/lib/dedup";
import type { AITool } from "@/lib/types";

export const dynamic = "force-dynamic";

function getFavorited(r: Record<string, unknown>): boolean {
  const v = r.favorited ?? (r as any).Favorited;
  return !!(v === true || v === 1 || v === "1");
}

export async function GET(request: NextRequest) {
  try {
    const rows = await getAllTools();
    const toolsMapped: AITool[] = (rows as any[]).map((r) => ({
      id: r.id,
      name: r.name,
      url: r.url ?? "",
      description: r.description ?? "",
      section: r.section,
      category: r.category ?? "Other",
      emoji: r.emoji ?? "",
      email_date: r.email_date,
      email_id: r.email_id,
      favorited: getFavorited(r as Record<string, unknown>),
      created_at: r.created_at,
    }));
    const tools = dedupeTools(toolsMapped);
    const categories = await getDistinctCategories();

    const res = NextResponse.json({ tools, categories });
    res.headers.set(
      "Cache-Control",
      "private, no-store, no-cache, must-revalidate"
    );
    return res;
  } catch (error: any) {
    console.error("Error fetching tools:", error);
    return NextResponse.json(
      { error: error.message || "Failed to fetch tools" },
      { status: 500 }
    );
  }
}