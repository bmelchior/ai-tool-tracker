import * as cheerio from "cheerio";
import { inferCategory } from "./types";

export interface ParsedTool {
  name: string;
  url: string;
  description: string;
  section: "daily" | "notable";
  category: string;
  emoji: string;
}

/**
 * Parse the "There's an AI for That" newsletter HTML to extract tools
 * from "AI Tools of the Day" and "Notable AI Tools" sections.
 *
 * The email structure (from analyzing multiple issues):
 * - Each tool entry is a line starting with an emoji
 * - The tool name is usually bold or linked
 * - The description follows after the name
 * - Sections are separated by headers containing "AI Tools of the Day" / "Notable AI Tools"
 */
export function parseNewsletter(html: string): ParsedTool[] {
  const tools: ParsedTool[] = [];

  // Strategy: use cheerio to extract text + links, then parse line by line
  const $ = cheerio.load(html);

  // Get the full text to find section boundaries
  const fullText = $("body").text();

  // Find section markers
  const dailyMarker = "AI Tools of the Day";
  const notableMarker = "Notable AI Tools";

  // We'll work with the raw HTML to extract links alongside text
  // Find all table cells / divs that contain tool entries
  // The newsletter is typically table-based email HTML

  // Approach: iterate through all text nodes and links,
  // building a line-by-line representation with link targets preserved

  const lines = extractLinesWithLinks($);

  let currentSection: "daily" | "notable" | null = null;

  for (const line of lines) {
    const text = line.text.trim();

    // Detect section headers
    if (text.includes(dailyMarker)) {
      currentSection = "daily";
      continue;
    }
    if (text.includes(notableMarker)) {
      currentSection = "notable";
      continue;
    }

    // Stop parsing at known section terminators
    if (
      currentSection &&
      (text.includes("Submit your AI tool") ||
        text.includes("Interesting AI") ||
        text.includes("AI Finds") ||
        text.includes("Beyond the Feed") ||
        text.includes("Open Source Finds") ||
        text.includes("Prompt of the Day") ||
        text.includes("Breaking News") ||
        text.includes("The Latest AI") ||
        text.includes("Deep Dive") ||
        text.includes("Coming in Hot") ||
        text.includes("From the Source") ||
        text.includes("Open Source Finds") ||
        text.includes("Feedback"))
    ) {
      currentSection = null;
      continue;
    }

    if (!currentSection) continue;

    // Tool entries start with an emoji
    const emojiMatch = text.match(
      /^([\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FEFF}]|[\u{1F900}-\u{1F9FF}]|[🤖⚽📍📊🎙️🔎🎨🦾🎯💡🧠🩺🍎🖥️📦🔧✨🚀💰🎵📱🔒🏥📈🛡️📝🎮🏠🌍📸🎬🤝💬📧🛒🔗⭐🏆🎯])/u
    );

    if (!emojiMatch) continue;

    const emoji = emojiMatch[1];
    const afterEmoji = text.slice(emojiMatch[0].length).trim();

    // Extract tool name and description
    // Pattern: "ToolName description that explains what it does."
    // The tool name is typically the first few words (often bold/linked in HTML)
    const toolData = extractToolNameAndDescription(afterEmoji, line.links);

    if (toolData) {
      const category = inferCategory(toolData.name, toolData.description);

      tools.push({
        name: toolData.name,
        url: toolData.url,
        description: toolData.description,
        section: currentSection,
        category,
        emoji,
      });
    }
  }

  return tools;
}

interface LineWithLinks {
  text: string;
  links: { text: string; href: string }[];
}

function extractLinesWithLinks($: cheerio.CheerioAPI): LineWithLinks[] {
  const lines: LineWithLinks[] = [];

  // Process the body content, splitting by common email structure elements
  // Newsletter emails use <tr>, <td>, <p>, <div> for structure
  const blocks: cheerio.Cheerio<cheerio.Element>[] = [];

  $("td, p, div, li").each((_, el) => {
    const $el = $(el);
    // Only process leaf-ish elements (ones that directly contain text)
    const directText = $el
      .contents()
      .filter((_, node) => node.type === "text")
      .text()
      .trim();
    const hasDirectContent =
      directText.length > 0 || $el.find("a, strong, b, span").length > 0;

    if (hasDirectContent) {
      const text = $el.text().trim();
      if (text.length > 10) {
        // Skip tiny fragments
        const links: { text: string; href: string }[] = [];
        $el.find("a").each((_, a) => {
          const href = $(a).attr("href") || "";
          const linkText = $(a).text().trim();
          if (href && linkText) {
            links.push({ text: linkText, href });
          }
        });
        lines.push({ text, links });
      }
    }
  });

  return lines;
}

function extractToolNameAndDescription(
  text: string,
  links: { text: string; href: string }[]
): { name: string; url: string; description: string } | null {
  if (text.length < 10) return null;

  // Try to find the tool name from links first (it's usually the linked text)
  let name = "";
  let url = "";
  let description = text;

  // Check if any link text appears at the start of the line
  for (const link of links) {
    if (link.text.length > 2 && text.startsWith(link.text)) {
      name = link.text;
      url = cleanTrackingUrl(link.href);
      description = text.slice(link.text.length).trim();
      break;
    }
  }

  // If no link match, try to extract name from text pattern
  // Pattern: "Name does something..." - name is typically 1-3 words before a verb
  if (!name) {
    const verbPattern =
      /^(.+?)\s+(is|does|helps|lets|finds|maps|tracks|connects|analyzes|monitors|listens|replaces|lives|gives|scans|runs|writes|turns|converts|creates|provides|offers|makes|builds|uses|shows|generates|automates|manages|detects|identifies|discovers|surfaces|streamlines|simplifies|transforms|combines|enables)/i;
    const match = text.match(verbPattern);
    if (match) {
      name = match[1].trim();
      description = text;
      // Try to find URL from any link
      if (links.length > 0) {
        url = cleanTrackingUrl(links[0].href);
      }
    }
  }

  // Last resort: first word(s) as name
  if (!name) {
    const words = text.split(/\s+/);
    name = words.slice(0, 2).join(" ");
    description = text;
    if (links.length > 0) {
      url = cleanTrackingUrl(links[0].href);
    }
  }

  // Clean up description
  description = description.replace(/^\s*[-–—:,]\s*/, "").trim();

  return { name, url, description };
}

/**
 * Attempt to extract the final destination URL from newsletter tracking URLs.
 * Many newsletters wrap links in tracking redirects.
 */
function cleanTrackingUrl(url: string): string {
  try {
    const parsed = new URL(url);
    // Common tracking URL parameter names for the final destination
    const destParams = ["url", "redirect", "dest", "destination", "u", "link"];
    for (const param of destParams) {
      const dest = parsed.searchParams.get(param);
      if (dest && dest.startsWith("http")) {
        return dest;
      }
    }
  } catch {
    // Not a valid URL, return as-is
  }
  return url;
}

/**
 * Parse from plain text (fallback when HTML isn't available).
 * Less reliable since links are stripped, but captures names and descriptions.
 */
export function parseNewsletterPlainText(text: string): ParsedTool[] {
  const tools: ParsedTool[] = [];
  const lines = text.split("\n");

  let currentSection: "daily" | "notable" | null = null;

  for (const line of lines) {
    const trimmed = line.trim();

    if (trimmed.includes("AI Tools of the Day")) {
      currentSection = "daily";
      continue;
    }
    if (trimmed.includes("Notable AI Tools")) {
      currentSection = "notable";
      continue;
    }
    if (
      currentSection &&
      (trimmed.includes("Submit your AI tool") ||
        trimmed.includes("Interesting AI") ||
        trimmed.includes("AI Finds") ||
        trimmed.includes("Beyond the Feed") ||
        trimmed.includes("Open Source Finds") ||
        trimmed.includes("Prompt of the Day") ||
        trimmed.includes("Breaking News") ||
        trimmed.includes("The Latest AI") ||
        trimmed.includes("Deep Dive") ||
        trimmed.includes("Coming in Hot") ||
        trimmed.includes("From the Source") ||
        trimmed.includes("Feedback"))
    ) {
      currentSection = null;
      continue;
    }

    if (!currentSection) continue;

    // Match emoji-prefixed lines
    const emojiMatch = trimmed.match(
      /^([\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FEFF}]|[\u{1F900}-\u{1F9FF}]|[🤖⚽📍📊🎙️🔎🎨🦾🎯💡🧠🩺🍎🖥️📦🔧✨🚀💰🎵📱🔒🏥📈🛡️📝🎮🏠🌍📸🎬🤝💬📧🛒🔗⭐🏆])\s*/u
    );

    if (!emojiMatch) continue;

    const emoji = emojiMatch[1];
    const afterEmoji = trimmed.slice(emojiMatch[0].length).trim();

    // Try verb-based split
    const verbPattern =
      /^(.+?)\s+(is|does|helps|lets|finds|maps|tracks|connects|analyzes|monitors|listens|replaces|lives|gives|scans|runs|writes|turns|converts|creates|provides|offers|makes|builds|uses|shows|generates|automates|manages|detects|identifies|discovers|surfaces|streamlines|simplifies|transforms|combines|enables)/i;
    const match = afterEmoji.match(verbPattern);

    let name: string;
    let description: string;

    if (match) {
      name = match[1].trim();
      description = afterEmoji;
    } else {
      const words = afterEmoji.split(/\s+/);
      name = words.slice(0, 2).join(" ");
      description = afterEmoji;
    }

    const category = inferCategory(name, description);

    tools.push({
      name,
      url: "",
      description,
      section: currentSection,
      category,
      emoji,
    });
  }

  return tools;
}
