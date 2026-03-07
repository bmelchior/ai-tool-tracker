import { google } from "googleapis";
import { getTokens, saveTokens } from "./db";

const SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"];

export async function getOAuthClient() {
  const client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    `${process.env.NEXT_PUBLIC_BASE_URL}/api/callback`
  );

  // Load saved tokens if available
  const tokens = await getTokens();
  if (tokens) {
    client.setCredentials({
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expiry_date: new Date(tokens.expiry).getTime(),
    });

    // Auto-save refreshed tokens
    client.on("tokens", async (newTokens) => {
      await saveTokens(
        newTokens.access_token || tokens.access_token,
        newTokens.refresh_token || tokens.refresh_token,
        newTokens.expiry_date
          ? new Date(newTokens.expiry_date).toISOString()
          : tokens.expiry
      );
    });
  }

  return client;
}

export function getAuthUrl() {
  const client = new google.auth.OAuth2(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    `${process.env.NEXT_PUBLIC_BASE_URL}/api/callback`
  );
  return client.generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: SCOPES,
  });
}

export async function isAuthenticated(): Promise<boolean> {
  const tokens = await getTokens();
  return !!tokens?.access_token;
}