import { NextResponse } from "next/server";
import { getAuthUrl, isAuthenticated } from "@/lib/gmail";

export async function GET() {
  const authUrl = getAuthUrl();
  const authenticated = await isAuthenticated();
  return NextResponse.json({ authenticated, authUrl });
}