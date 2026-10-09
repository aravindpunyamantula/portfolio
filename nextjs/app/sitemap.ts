export const dynamic = "force-static";
import { SITE_URL } from "@/lib/seo";
import type { MetadataRoute } from "next";
import { getPortfolio, slugify } from "@/lib/portfolio";
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const content = await getPortfolio();
  return [
    "",
    "/projects",
    "/certifications",
    "/reviews",
    "/contact",
    ...content.projects.map((p) => `/projects/${slugify(p.title)}`),
  ].map((path) => ({
    url: `${SITE_URL}${path}`,
    changeFrequency: "weekly",
    priority: path ? 0.7 : 1,
  }));
}
