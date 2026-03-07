import { NextResponse } from "next/server";
import { getAuthUrl, isAuthenticated } from "@/lib/gmail";

export async function GET() {
  if (await isAuthenticated()) {
    return NextResponse.json({ authenticated: true });
  }

  const url = getAuthUrl();
  return NextResponse.json({ authenticated: false, authUrl: url });
}