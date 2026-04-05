import { NextResponse } from "next/server";
import { google } from "googleapis";
import { getOAuthClient, isAuthenticated } from "@/lib/gmail";
import {
  insertTool,
  checkEmailProcessed,
  updateSyncState,
  clearAuth,
} from "@/lib/db";
import { parseNewsletter, parseNewsletterPlainText } from "@/lib/parser";

export async function POST() {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: "Not authenticated" }, { status: 401 });
  }

  try {
    const auth = await getOAuthClient();
    const gmail = google.gmail({ version: "v1", auth });

    const query = "from:hi@mail.theresanaiforthat.com";

    const listResponse = await gmail.users.messages.list({
      userId: "me",
      q: query,
      maxResults: 50,
    });

    const messages = listResponse.data.messages || [];
    let newToolsCount = 0;
    let processedEmails = 0;

    for (const msg of messages) {
      if (!msg.id) continue;

      const alreadyProcessed = await checkEmailProcessed(msg.id);
      if (alreadyProcessed) continue;

      const email = await gmail.users.messages.get({
        userId: "me",
        id: msg.id,
        format: "full",
      });

      const headers = email.data.payload?.headers || [];
      const dateHeader = headers.find(
        (h) => h.name?.toLowerCase() === "date"
      );
      const emailDate = dateHeader?.value
        ? new Date(dateHeader.value).toISOString().split("T")[0]
        : new Date().toISOString().split("T")[0];

      const { html, text } = extractBody(email.data.payload);

      let tools;
      if (html) {
        tools = parseNewsletter(html);
      } else if (text) {
        tools = parseNewsletterPlainText(text);
      } else {
        continue;
      }

      for (const tool of tools) {
        const result = await insertTool({
          ...tool,
          email_date: emailDate,
          email_id: msg.id,
        });
        if (result.changes > 0) newToolsCount++;
      }

      processedEmails++;
    }

    await updateSyncState();

    return NextResponse.json({
      success: true,
      processedEmails,
      newTools: newToolsCount,
      totalEmails: messages.length,
    });
  } catch (error: unknown) {
    console.error("Sync error:", error);
    if (isInvalidGrantError(error)) {
      await clearAuth();
      return NextResponse.json(
        {
          error:
            "Google access expired or was revoked. Use Connect Gmail to sign in again.",
          code: "REAUTH_REQUIRED",
        },
        { status: 401 }
      );
    }
    const message =
      error instanceof Error ? error.message : "Sync failed";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

function isInvalidGrantError(error: unknown): boolean {
  const data = (error as { response?: { data?: { error?: string } } })
    ?.response?.data;
  return data?.error === "invalid_grant";
}

function extractBody(payload: any): { html: string; text: string } {
  let html = "";
  let text = "";

  if (!payload) return { html, text };

  if (payload.body?.data) {
    const decoded = Buffer.from(payload.body.data, "base64url").toString("utf-8");
    if (payload.mimeType === "text/html") html = decoded;
    else if (payload.mimeType === "text/plain") text = decoded;
  }

  if (payload.parts) {
    for (const part of payload.parts) {
      if (part.mimeType === "text/html" && part.body?.data) {
        html = Buffer.from(part.body.data, "base64url").toString("utf-8");
      } else if (part.mimeType === "text/plain" && part.body?.data) {
        text = Buffer.from(part.body.data, "base64url").toString("utf-8");
      } else if (part.parts) {
        const nested = extractBody(part);
        if (nested.html) html = nested.html;
        if (nested.text) text = nested.text;
      }
    }
  }

  return { html, text };
}