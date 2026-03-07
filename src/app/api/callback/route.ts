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
    const client = await getOAuthClient();
    const { tokens } = await client.getToken(code);

    await saveTokens(
      tokens.access_token!,
      tokens.refresh_token!,
      tokens.expiry_date
        ? new Date(tokens.expiry_date).toISOString()
        : new Date(Date.now() + 3600 * 1000).toISOString()
    );

    return NextResponse.redirect(
      new URL("/?auth=success", process.env.NEXT_PUBLIC_BASE_URL!)
    );
  } catch (error: any) {
    console.error("OAuth callback error:", error?.message);
    return NextResponse.redirect(
      new URL("/?error=auth_failed", process.env.NEXT_PUBLIC_BASE_URL!)
    );
  }
}