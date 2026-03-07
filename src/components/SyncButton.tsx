"use client";

import { RefreshCw, LogIn } from "lucide-react";
import { useState } from "react";

interface SyncButtonProps {
  authenticated: boolean;
  authUrl?: string;
  onSyncComplete: () => void;
}

export default function SyncButton({
  authenticated,
  authUrl,
  onSyncComplete,
}: SyncButtonProps) {
  const [syncing, setSyncing] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  const handleSync = async () => {
    setSyncing(true);
    setResult(null);
    try {
      const res = await fetch("/api/sync", { method: "POST" });
      const data = await res.json();
      if (data.success) {
        setResult(
          `Synced ${data.processedEmails} emails → ${data.newTools} new tools`
        );
        onSyncComplete();
      } else {
        setResult(data.error || "Sync failed");
      }
    } catch (err) {
      setResult("Sync failed — check console");
    } finally {
      setSyncing(false);
      setTimeout(() => setResult(null), 4000);
    }
  };

  if (!authenticated) {
    return (
      <a href={authUrl} className="btn-primary">
        <LogIn className="w-4 h-4" />
        Connect Gmail
      </a>
    );
  }

  return (
    <div className="flex items-center gap-3">
      <button
        onClick={handleSync}
        disabled={syncing}
        className="btn-ghost disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <RefreshCw className={`w-4 h-4 ${syncing ? "animate-spin" : ""}`} />
        {syncing ? "Syncing..." : "Sync Emails"}
      </button>
      {result && (
        <span className="text-xs font-mono text-gray-400 animate-fade-up">
          {result}
        </span>
      )}
    </div>
  );
}
