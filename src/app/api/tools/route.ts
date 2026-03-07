import { NextRequest, NextResponse } from "next/server";
import { getAllTools, getDistinctCategories } from "@/lib/db";

export async function GET(request: NextRequest) {
  try {
    const tools = await getAllTools();
    const categories = await getDistinctCategories();

    return NextResponse.json({ tools, categories });
  } catch (error: any) {
    console.error("Error fetching tools:", error);
    return NextResponse.json(
      { error: error.message || "Failed to fetch tools" },
      { status: 500 }
    );
  }
}