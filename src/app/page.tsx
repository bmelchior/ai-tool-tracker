"use client";

import { useState, useEffect, useMemo, useCallback } from "react";
import {
  Search,
  Heart,
  Layers,
  Sparkles,
  Star,
  LayoutList,
} from "lucide-react";
import { AITool } from "@/lib/types";
import ToolCard from "@/components/ToolCard";
import SearchBar from "@/components/SearchBar";
import CategoryFilter from "@/components/CategoryFilter";
import SyncButton from "@/components/SyncButton";

type View = "all" | "favorites";
type SectionFilter = "all" | "daily" | "notable";

export default function Home() {
  const [tools, setTools] = useState<AITool[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const [authUrl, setAuthUrl] = useState("");

  // Filters
  const [search, setSearch] = useState("");
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [sectionFilter, setSectionFilter] = useState<SectionFilter>("all");
  const [view, setView] = useState<View>("all");

  const refreshAuth = useCallback(() => {
    fetch("/api/auth")
      .then((r) => r.json())
      .then((data) => {
        setAuthenticated(data.authenticated);
        if (data.authUrl) setAuthUrl(data.authUrl);
      })
      .catch(console.error);
  }, []);

  useEffect(() => {
    refreshAuth();
  }, [refreshAuth]);

  // Fetch tools (no-cache so favorites and list stay in sync with server)
  const fetchTools = useCallback((showLoading = true) => {
    if (showLoading) setLoading(true);
    fetch("/api/tools", { cache: "no-store" })
      .then((r) => r.json())
      .then((data) => {
        setTools(
          (data.tools || []).map((t: any) => ({
            ...t,
            favorited: !!t.favorited,
          }))
        );
        setCategories(data.categories || []);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    fetchTools();
  }, [fetchTools]);

  // Filter logic
  const filteredTools = useMemo(() => {
    let result = [...tools];

    // View filter
    if (view === "favorites") {
      result = result.filter((t) => t.favorited);
    }

    // Section filter
    if (sectionFilter !== "all") {
      result = result.filter((t) => t.section === sectionFilter);
    }

    // Category filter
    if (selectedCategories.length > 0) {
      result = result.filter((t) => selectedCategories.includes(t.category));
    }

    // Search
    if (search.trim()) {
      const q = search.toLowerCase();
      result = result.filter(
        (t) =>
          t.name.toLowerCase().includes(q) ||
          t.description.toLowerCase().includes(q)
      );
    }

    return result;
  }, [tools, view, sectionFilter, selectedCategories, search]);

  // Actions
  const toggleFavorite = async (id: number) => {
    setTools((prev) =>
      prev.map((t) => (t.id === id ? { ...t, favorited: !t.favorited } : t))
    );
    const res = await fetch("/api/favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "toggle_favorite", id }),
    });
    if (res.ok) {
      fetchTools(false);
    } else {
      setTools((prev) =>
        prev.map((t) => (t.id === id ? { ...t, favorited: !t.favorited } : t))
      );
    }
  };

  const updateCategory = async (id: number, category: string) => {
    setTools((prev) =>
      prev.map((t) => (t.id === id ? { ...t, category } : t))
    );
    await fetch("/api/favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action: "update_category", id, category }),
    });
  };

  const toggleCategory = (cat: string) => {
    setSelectedCategories((prev) =>
      prev.includes(cat) ? prev.filter((c) => c !== cat) : [...prev, cat]
    );
  };

  const favCount = tools.filter((t) => t.favorited).length;

  return (
    <div className="min-h-screen min-w-0 max-w-full overflow-x-hidden">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-surface-0/80 backdrop-blur-xl border-b border-surface-3">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-accent to-cyan-600 flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-surface-0" />
              </div>
              <div>
                <h1 className="font-display font-bold text-lg text-gray-100">
                  AI Tool DB
                </h1>
                <p className="text-[11px] font-mono text-gray-500 -mt-0.5">
                  {tools.length} tools indexed
                </p>
              </div>
            </div>

            <SyncButton
              authenticated={authenticated}
              authUrl={authUrl}
              onSyncComplete={fetchTools}
              onSessionInvalid={refreshAuth}
            />
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8 w-full min-w-0">
        {/* Controls bar */}
        <div className="flex flex-col gap-5 mb-8">
          {/* Search */}
          <div className="w-full min-w-0">
            <SearchBar value={search} onChange={setSearch} />
          </div>

          {/* View toggle + Section filter */}
          <div className="flex items-center gap-4 flex-wrap">
            {/* View tabs */}
            <div className="flex items-center bg-surface-1 rounded-xl border border-surface-3 p-1">
              <button
                onClick={() => setView("all")}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-sm font-display font-medium transition-all ${
                  view === "all"
                    ? "bg-surface-3 text-gray-100"
                    : "text-gray-500 hover:text-gray-300"
                }`}
              >
                <LayoutList className="w-3.5 h-3.5" />
                All Tools
              </button>
              <button
                onClick={() => setView("favorites")}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-sm font-display font-medium transition-all ${
                  view === "favorites"
                    ? "bg-surface-3 text-gray-100"
                    : "text-gray-500 hover:text-gray-300"
                }`}
              >
                <Heart className="w-3.5 h-3.5" />
                Favorites
                {favCount > 0 && (
                  <span className="text-[10px] font-mono bg-fav/15 text-fav px-1.5 py-0.5 rounded-full">
                    {favCount}
                  </span>
                )}
              </button>
            </div>

            {/* Section filter — 3 themes: ALL = white, DAILY = teal, NOTABLE = orange */}
            <div className="flex items-center bg-surface-1 rounded-xl border border-surface-3 p-1">
              {(["all", "daily", "notable"] as SectionFilter[]).map((s) => (
                <button
                  key={s}
                  onClick={() => setSectionFilter(s)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-mono uppercase tracking-wider transition-all ${
                    sectionFilter === s
                      ? s === "all"
                        ? "bg-surface-3 text-white"
                        : s === "daily"
                          ? "bg-accent/10 text-accent"
                          : "bg-warn/10 text-warn"
                      : "text-gray-500 hover:text-gray-300"
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>

          {/* Category chips */}
          <CategoryFilter
            categories={
              categories.length > 0
                ? categories
                : [
                    "Productivity",
                    "Creative",
                    "Marketing",
                    "Finance",
                    "Developer",
                    "Data & Analytics",
                    "Sales",
                    "HR & Recruiting",
                    "Communication",
                    "Other",
                  ]
            }
            selected={selectedCategories}
            onToggle={toggleCategory}
            onClear={() => setSelectedCategories([])}
            sectionTheme={sectionFilter}
          />
        </div>

        {/* Results */}
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <div className="text-center">
              <div className="w-8 h-8 border-2 border-accent/30 border-t-accent rounded-full animate-spin mx-auto mb-3" />
              <p className="text-sm text-gray-500 font-mono">
                Loading tools...
              </p>
            </div>
          </div>
        ) : filteredTools.length === 0 ? (
          <div className="text-center py-20">
            <div className="w-16 h-16 rounded-2xl bg-surface-2 flex items-center justify-center mx-auto mb-4">
              {view === "favorites" ? (
                <Heart className="w-7 h-7 text-gray-600" />
              ) : (
                <Search className="w-7 h-7 text-gray-600" />
              )}
            </div>
            <p className="text-gray-400 font-display font-medium mb-1">
              {view === "favorites"
                ? "No favorites yet"
                : tools.length === 0
                ? "No tools synced yet"
                : "No tools match your filters"}
            </p>
            <p className="text-sm text-gray-600">
              {view === "favorites"
                ? "Heart some tools to see them here"
                : tools.length === 0
                ? "Connect Gmail and sync to get started"
                : "Try adjusting your search or category filters"}
            </p>
          </div>
        ) : (
          <>
            <p className="text-xs font-mono text-gray-500 mb-4">
              {filteredTools.length} tool
              {filteredTools.length !== 1 ? "s" : ""}{" "}
              {search || selectedCategories.length > 0 ? "matching" : ""}
            </p>
            <div className="grid gap-3 min-w-0 w-full">
              {filteredTools.map((tool, i) => (
                <ToolCard
                  key={tool.id}
                  tool={tool}
                  index={i}
                  onToggleFavorite={toggleFavorite}
                  onUpdateCategory={updateCategory}
                />
              ))}
            </div>
          </>
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-surface-3 mt-16">
        <div className="max-w-6xl mx-auto px-6 py-6">
          <p className="text-xs font-mono text-gray-600 text-center">
            Parsed from There&apos;s An AI For That newsletter • Built with
            Next.js
          </p>
        </div>
      </footer>
    </div>
  );
}
