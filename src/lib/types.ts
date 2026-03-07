export interface AITool {
  id: number;
  name: string;
  url: string;
  description: string;
  section: "daily" | "notable";
  category: string;
  emoji: string;
  email_date: string;
  email_id: string;
  favorited: boolean;
  created_at: string;
}

export interface ToolFilters {
  search: string;
  categories: string[];
  section: "all" | "daily" | "notable";
}

export const CATEGORIES = [
  "Productivity",
  "Creative",
  "Marketing",
  "Finance",
  "Health",
  "Developer",
  "Data & Analytics",
  "Sales",
  "HR & Recruiting",
  "Education",
  "Communication",
  "Security",
  "Other",
] as const;

export type Category = (typeof CATEGORIES)[number];

// Simple keyword → category mapping for auto-tagging
export const CATEGORY_KEYWORDS: Record<string, Category> = {
  // Productivity
  workspace: "Productivity",
  task: "Productivity",
  automate: "Productivity",
  workflow: "Productivity",
  planning: "Productivity",
  organiz: "Productivity",
  project: "Productivity",
  // Creative
  design: "Creative",
  art: "Creative",
  image: "Creative",
  video: "Creative",
  music: "Creative",
  photo: "Creative",
  creative: "Creative",
  generate: "Creative",
  // Marketing
  marketing: "Marketing",
  seo: "Marketing",
  social: "Marketing",
  brand: "Marketing",
  content: "Marketing",
  competitor: "Marketing",
  advertis: "Marketing",
  campaign: "Marketing",
  // Finance
  trading: "Finance",
  financ: "Finance",
  invest: "Finance",
  crypto: "Finance",
  defi: "Finance",
  wallet: "Finance",
  money: "Finance",
  revenue: "Finance",
  monetiz: "Finance",
  // Health
  health: "Health",
  medical: "Health",
  fitness: "Health",
  wellness: "Health",
  mental: "Health",
  // Developer
  code: "Developer",
  api: "Developer",
  github: "Developer",
  deploy: "Developer",
  debug: "Developer",
  developer: "Developer",
"open-source": "Developer",
  sdk: "Developer",
  programming: "Developer",
  // Data & Analytics
  data: "Data & Analytics",
  analyt: "Data & Analytics",
  dashboard: "Data & Analytics",
  chart: "Data & Analytics",
  insight: "Data & Analytics",
  report: "Data & Analytics",
  sql: "Data & Analytics",
  // Sales
  sales: "Sales",
  crm: "Sales",
  lead: "Sales",
  outreach: "Sales",
  prospect: "Sales",
  pipeline: "Sales",
  // HR & Recruiting
  hiring: "HR & Recruiting",
  recruit: "HR & Recruiting",
  interview: "HR & Recruiting",
  resume: "HR & Recruiting",
  talent: "HR & Recruiting",
  hr: "HR & Recruiting",
  job: "HR & Recruiting",
  // Education
  learn: "Education",
  course: "Education",
  education: "Education",
  study: "Education",
  tutor: "Education",
  teach: "Education",
  // Communication
  meeting: "Communication",
  chat: "Communication",
  slack: "Communication",
  teams: "Communication",
  email: "Communication",
  message: "Communication",
  // Security
  security: "Security",
  privacy: "Security",
  encrypt: "Security",
  threat: "Security",
  vulnerab: "Security",
};

export function inferCategory(name: string, description: string): Category {
  const text = `${name} ${description}`.toLowerCase();

  // Score each category by keyword matches
  const scores: Partial<Record<Category, number>> = {};

  for (const [keyword, category] of Object.entries(CATEGORY_KEYWORDS)) {
    if (text.includes(keyword.toLowerCase())) {
      scores[category] = (scores[category] || 0) + 1;
    }
  }

  // Return highest-scoring category, or "Other"
  const sorted = Object.entries(scores).sort(
    ([, a], [, b]) => (b as number) - (a as number)
  );

  return sorted.length > 0 ? (sorted[0][0] as Category) : "Other";
}
