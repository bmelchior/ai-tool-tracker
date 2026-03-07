import { NextRequest, NextResponse } from "next/server";
import { toggleFavorite, updateCategory } from "@/lib/db";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, id, category } = body;

    if (action === "toggle_favorite" && id) {
      await toggleFavorite(id);
      return NextResponse.json({ success: true });
    }

    if (action === "update_category" && id && category) {
      await updateCategory(id, category);
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