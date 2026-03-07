"use client";

type SectionTheme = "all" | "daily" | "notable";

interface CategoryFilterProps {
  categories: string[];
  selected: string[];
  onToggle: (category: string) => void;
  onClear: () => void;
  sectionTheme?: SectionTheme;
}

const selectedChipClasses: Record<SectionTheme, string> = {
  all: "chip bg-surface-3 text-white border-gray-500",
  daily: "chip bg-accent/15 text-accent border-accent/30",
  notable: "chip bg-warn/10 text-warn border-warn/30",
};

export default function CategoryFilter({
  categories,
  selected,
  onToggle,
  onClear,
  sectionTheme = "all",
}: CategoryFilterProps) {
  const activeClasses = selectedChipClasses[sectionTheme];

  return (
    <div className="flex items-center gap-2 flex-wrap">
      <button
        onClick={onClear}
        className={
          selected.length === 0
            ? activeClasses
            : "chip hover:text-gray-200"
        }
      >
        All
      </button>
      {categories.map((cat) => (
        <button
          key={cat}
          onClick={() => onToggle(cat)}
          className={
            selected.includes(cat)
              ? activeClasses
              : "chip hover:text-gray-200 hover:border-gray-500"
          }
        >
          {cat}
        </button>
      ))}
    </div>
  );
}
