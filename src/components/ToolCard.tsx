"use client";

import { Heart, ExternalLink, Tag } from "lucide-react";
import { AITool, CATEGORIES } from "@/lib/types";

interface ToolCardProps {
  tool: AITool;
  index: number;
  onToggleFavorite: (id: number) => void;
  onUpdateCategory: (id: number, category: string) => void;
}

export default function ToolCard({
  tool,
  index,
  onToggleFavorite,
  onUpdateCategory,
}: ToolCardProps) {
  return (
    <div
      className={`card-hover p-5 group animate-fade-up min-w-0 max-w-full overflow-hidden`}
      style={{ animationDelay: `${Math.min(index * 0.03, 0.3)}s` }}
    >
      <div className="flex items-start justify-between gap-3">
        {/* Emoji + Name + Description */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2.5 mb-2">
            <span className="text-xl flex-shrink-0">{tool.emoji}</span>
            <h3 className="font-display font-bold text-gray-100 text-base truncate">
              {tool.name}
            </h3>
            <span
              className={`text-[10px] font-mono uppercase tracking-wider px-1.5 py-0.5 rounded ${
                tool.section === "daily"
                  ? "bg-accent/10 text-accent"
                  : "bg-warn/10 text-warn"
              }`}
            >
              {tool.section === "daily" ? "daily" : "notable"}
            </span>
          </div>

          <p className="text-sm text-gray-400 leading-relaxed line-clamp-2 mb-3">
            {tool.description}
          </p>

          <div className="flex items-center gap-2 flex-wrap">
            {/* Category chip */}
            <div className="relative">
              <select
                value={tool.category}
                onChange={(e) => onUpdateCategory(tool.id, e.target.value)}
                className="chip appearance-none cursor-pointer pr-6 bg-surface-3 border-surface-4
                           hover:border-accent/30 hover:text-accent transition-colors"
                title="Change category"
              >
                {CATEGORIES.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
              <Tag className="absolute right-1.5 top-1/2 -translate-y-1/2 w-3 h-3 text-gray-500 pointer-events-none" />
            </div>

            {/* Date */}
            <span className="text-[11px] font-mono text-gray-600">
              {tool.email_date}
            </span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-col items-center gap-2 flex-shrink-0">
          <button
            onClick={() => onToggleFavorite(tool.id)}
            className={`p-2 rounded-lg transition-all duration-200 ${
              tool.favorited
                ? "text-fav bg-fav/10"
                : "text-gray-600 hover:text-fav hover:bg-fav/5"
            }`}
            title={tool.favorited ? "Remove from favorites" : "Add to favorites"}
          >
            <Heart
              className="w-4 h-4"
              fill={tool.favorited ? "currentColor" : "none"}
            />
          </button>

          {tool.url && (
            <a
              href={tool.url}
              target="_blank"
              rel="noopener noreferrer"
              className="p-2 rounded-lg text-gray-600 hover:text-accent hover:bg-accent/5 transition-all duration-200"
              title="Visit tool"
            >
              <ExternalLink className="w-4 h-4" />
            </a>
          )}
        </div>
      </div>
    </div>
  );
}
