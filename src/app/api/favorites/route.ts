import { NextRequest, NextResponse } from "next/server";
import {
  toggleFavorite,
  updateCategory,
  getToolById,
  setFavoritedByNormalizedName,
} from "@/lib/db";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, id, category } = body;

    if (action === "toggle_favorite" && id != null) {
      const toolId = Number(id);
      if (!Number.isInteger(toolId)) {
        return NextResponse.json({ error: "Invalid tool id" }, { status: 400 });
      }
      const tool = await getToolById(toolId);
      if (!tool) {
        return NextResponse.json({ error: "Tool not found" }, { status: 404 });
      }
      await toggleFavorite(toolId);
      const after = await getToolById(toolId);
      if (after) {
        const normalizedName = tool.name.trim().toLowerCase();
        await setFavoritedByNormalizedName(normalizedName, after.favorited);
      }
      return NextResponse.json({ success: true });
    }

    if (action === "update_category" && id != null && category) {
      const toolId = Number(id);
      if (!Number.isInteger(toolId)) {
        return NextResponse.json({ error: "Invalid tool id" }, { status: 400 });
      }
      await updateCategory(toolId, category);
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