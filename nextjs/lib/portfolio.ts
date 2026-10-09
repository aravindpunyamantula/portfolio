import { cache } from "react";
import { fallbackContent } from "./data";
import type {
  PortfolioContent,
  ProjectModel,
  CertificateModel,
  ReviewModel,
  ProjectStoryContent,
  ProjectStoryLayer,
} from "./types";

export const DATA_URL =
  "https://raw.githubusercontent.com/aravindpunyamantula/portfolio-data/main/data.json";
type RecordValue = Record<string, unknown>;
const record = (v: unknown): RecordValue =>
  v !== null && typeof v === "object" && !Array.isArray(v)
    ? (v as RecordValue)
    : {};
const str = (v: unknown, fallback = "") =>
  typeof v === "string" ? v : fallback;
const strings = (v: unknown, fallback: string[] = []) =>
  Array.isArray(v)
    ? v.filter((x): x is string => typeof x === "string")
    : fallback;
export function safeUrl(v: unknown): string {
  if (typeof v !== "string") return "";
  try {
    const url = new URL(v);
    return ["https:", "http:", "mailto:"].includes(url.protocol) ? v : "";
  } catch {
    return "";
  }
}
function normalizeStory(input: unknown): ProjectStoryContent | undefined {
  const story = record(input);
  if (!Object.keys(story).length) return undefined;
  const layers: ProjectStoryLayer[] = [];
  if (Array.isArray(story.layers))
    for (const inputLayer of story.layers) {
      const layer = record(inputLayer);
      if (
        (layer.id === "interface" ||
          layer.id === "logic" ||
          layer.id === "data") &&
        !layers.some((item) => item.id === layer.id) &&
        str(layer.description).trim()
      ) {
        layers.push({
          id: layer.id,
          title: str(
            layer.title,
            layer.id === "interface"
              ? "Interface"
              : layer.id === "logic"
                ? "Logic"
                : "Data",
          ),
          description: str(layer.description),
          technologies: strings(layer.technologies),
        });
      }
    }
  return {
    audience: str(story.audience),
    contribution: str(story.contribution),
    outcome: str(story.outcome),
    layers,
  };
}
const ordered = <T extends { order?: number }>(items: T[]) =>
  [...items].sort((a, b) => (a.order ?? 9999) - (b.order ?? 9999));
export function normalizeContent(input: unknown): PortfolioContent {
  const data = record(input),
    hero = record(data.hero),
    links = record(data.links);
  const list = (key: string) =>
    Array.isArray(data[key])
      ? (data[key] as unknown[])
          .map(record)
          .filter((x) => Object.keys(x).length)
      : [];
  const projects: ProjectModel[] = list("projects")
    .filter((x) => typeof x.title === "string" && x.title.trim())
    .map((x) => ({
      title: str(x.title),
      description: str(x.description),
      imageUrl: safeUrl(x.imageUrl),
      liveUrl: safeUrl(x.liveUrl),
      githubUrl: safeUrl(x.githubUrl),
      tags: strings(x.tags),
      story: normalizeStory(x.story),
      order: typeof x.order === "number" ? x.order : 9999,
    }));
  const certificates: CertificateModel[] = list("certificates")
    .filter((x) => typeof x.title === "string" && x.title.trim())
    .map((x) => ({
      title: str(x.title),
      organisation: str(x.organisation),
      date: str(x.date),
      imageUrl: safeUrl(x.imageUrl),
      link: safeUrl(x.link),
      skills: strings(x.skills),
      order: typeof x.order === "number" ? x.order : 9999,
    }));
  const reviews: ReviewModel[] = list("reviews")
    .filter((x) => typeof x.message === "string" && typeof x.name === "string")
    .map((x) => ({
      name: str(x.name),
      role: str(x.role),
      company: str(x.company),
      message: str(x.message),
      avatarUrl: safeUrl(x.avatarUrl),
      rating: Math.max(
        0,
        Math.min(5, typeof x.rating === "number" ? Math.round(x.rating) : 5),
      ),
    }));
  const roles = strings(hero.roles, fallbackContent.hero.roles);
  const sections = Object.fromEntries(
    Object.entries(fallbackContent.sections).map(([key, base]) => {
      const value = record(record(data.sections)[key]);
      return [
        key,
        {
          eyebrow: str(value.eyebrow, base.eyebrow),
          title: str(value.title, base.title),
          subtitle: str(value.subtitle, base.subtitle),
        },
      ];
    }),
  );
  const categories = list("skillCategories")
    .map((x) => ({
      title: str(x.title),
      color: str(x.color),
      skills: strings(x.skills),
    }))
    .filter((x) => x.title && x.skills.length);
  return {
    hero: {
      ...fallbackContent.hero,
      ...Object.fromEntries(
        Object.entries(fallbackContent.hero)
          .filter(([, v]) => typeof v === "string")
          .map(([k, v]) => [k, str(hero[k], v as string)]),
      ),
      roles: roles.length ? roles : fallbackContent.hero.roles,
      showAvailability:
        typeof hero.showAvailability === "boolean"
          ? hero.showAvailability
          : true,
    },
    links: Object.fromEntries(
      Object.entries(fallbackContent.links).map(([key, value]) => [
        key,
        safeUrl(links[key]) || value,
      ]),
    ) as unknown as PortfolioContent["links"],
    projects: ordered(projects.length ? projects : fallbackContent.projects),
    certificates: ordered(
      certificates.length ? certificates : fallbackContent.certificates,
    ),
    skillCategories: categories.length
      ? categories
      : fallbackContent.skillCategories,
    reviews: Array.isArray(data.reviews) ? reviews : fallbackContent.reviews,
    sections,
  };
}
export const getPortfolio = cache(async (): Promise<PortfolioContent> => {
  try {
    const response = await fetch(DATA_URL, {
      cache: "force-cache",
      signal: AbortSignal.timeout(8000),
    });
    if (response.ok) return normalizeContent(await response.json());
  } catch {
    /* Remote content unavailable; keep the portfolio usable. */
  }
  return normalizeContent(fallbackContent);
});
export { slugify } from "./slug";

export async function getProjectReadme(
  githubUrl?: string,
): Promise<string | null> {
  if (!githubUrl) return null;
  try {
    const url = new URL(githubUrl);
    if (url.hostname !== "github.com") return null;
    const [owner, repo] = url.pathname.split("/").filter(Boolean);
    if (!owner || !repo) return null;
    for (const branch of ["main", "master"]) {
      const response = await fetch(
        `https://raw.githubusercontent.com/${encodeURIComponent(owner)}/${encodeURIComponent(repo)}/${branch}/README.md`,
        { cache: "force-cache", signal: AbortSignal.timeout(5000) },
      );
      if (response.ok) return (await response.text()).slice(0, 60000);
      if (response.status !== 404) return null;
    }
  } catch {
    /* README preview is optional; project information still renders. */
  }
  return null;
}
