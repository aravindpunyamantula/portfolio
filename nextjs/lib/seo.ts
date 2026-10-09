import type { Metadata } from "next";
import type { ProjectModel } from "./types";
import { slugify } from "./slug";
export const SITE_URL = (
  process.env.NEXT_PUBLIC_SITE_URL || "https://aravindkumar.tech"
).replace(/\/$/, "");
export const SITE_NAME = "Aravind Kumar — The Digital Workshop";
export const pageInfo = {
  home: {
    path: "/",
    title: "Aravind Kumar — Full Stack & Flutter Developer",
    headline: "Ideas become working products.",
    description:
      "Explore Aravind Kumar’s full-stack websites, Flutter apps, backend systems, and AI projects. View certifications, client reviews, and contact details.",
    label: "Full Stack / Flutter / Backend / AI",
  },
  projects: {
    path: "/projects",
    title: "Projects & Open Source",
    headline: "Built with purpose. Made real.",
    description:
      "Explore live websites, Flutter applications, backend systems, and open-source AI projects built by Aravind Kumar. Discover the work and explore the source.",
    label: "Projects / Web / Mobile / Open source",
  },
  certifications: {
    path: "/certifications",
    title: "Certifications & Technical Credentials",
    headline: "Always learning. Always building.",
    description:
      "View Aravind Kumar’s MongoDB, GitHub, Oracle, and Cisco certifications. Explore technical credentials, skills, certificate previews, and verification links.",
    label: "Learning / Credentials / Technical skills",
  },
  reviews: {
    path: "/reviews",
    title: "Client Reviews & Testimonials",
    headline: "Good work. Good people.",
    description:
      "Read client reviews of Aravind Kumar’s website and Flutter app development, including feedback from Glamup Gifts and Cherries Cafe.",
    label: "Client experiences / Real feedback",
  },
  contact: {
    path: "/contact",
    title: "Contact Aravind Kumar",
    headline: "Your next great idea starts here.",
    description:
      "Contact Aravind Kumar about full-stack development, Flutter apps, backend engineering, internships, or collaborations. Send a message or connect directly.",
    label: "Collaborations / Opportunities / New ideas",
  },
} as const;
export type PageKey = keyof typeof pageInfo;
export const excerpt = (text: string, limit = 160) => {
  const clean = text.replace(/\s+/g, " ").trim();
  if (clean.length <= limit) return clean;
  const cut = clean.slice(0, limit - 1);
  const sentenceEnd = cut.lastIndexOf(". ");
  if (sentenceEnd >= Math.min(90, limit * 0.6))
    return cut.slice(0, sentenceEnd + 1);
  return (
    cut.slice(
      0,
      cut.lastIndexOf(" ") > limit * 0.65 ? cut.lastIndexOf(" ") : cut.length,
    ) + "…"
  );
};
export function seoMetadata({
  title,
  description,
  path,
  imageKey,
  keywords = [],
}: {
  title: string;
  description: string;
  path: string;
  imageKey: string;
  keywords?: string[];
}): Metadata {
  const url = `${SITE_URL}${path}`;
  const image = `${SITE_URL}/share/${imageKey}.png`;
  const fullTitle = title.includes("Aravind Kumar")
    ? title
    : `${title} | Aravind Kumar`;
  return {
    title: {
      absolute: fullTitle,
    },
    description: excerpt(description),
    alternates: { canonical: url },
    keywords: [
      "Aravind Kumar",
      "Full Stack Developer",
      "Flutter Developer",
      "Backend Engineer",
      ...keywords,
    ],
    openGraph: {
      type: "website",
      locale: "en_US",
      siteName: SITE_NAME,
      url,
      title: fullTitle,
      description: excerpt(description, 200),
      images: [
        {
          url: image,
          width: 1200,
          height: 630,
          type: "image/png",
          alt: `${title} — Aravind Kumar`,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: fullTitle,
      description: excerpt(description, 200),
      images: [{ url: image, alt: `${title} — Aravind Kumar` }],
    },
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-image-preview": "large",
        "max-snippet": -1,
        "max-video-preview": -1,
      },
    },
  };
}
export const pageMetadata = (key: PageKey) =>
  seoMetadata({ ...pageInfo[key], imageKey: key });
export function projectMetadata(project: ProjectModel): Metadata {
  const slug = slugify(project.title);
  return seoMetadata({
    title: `${project.title} — ${project.liveUrl ? "Web Development Project" : "Software & Open Source Project"}`,
    description: project.description,
    path: `/projects/${slug}`,
    imageKey: `project-${slug}`,
    keywords: [project.title, ...(project.tags || [])],
  });
}
export function breadcrumbSchema(items: { name: string; path: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: `${SITE_URL}${item.path}`,
    })),
  };
}
export function webpageSchema(key: PageKey) {
  const page = pageInfo[key];
  return {
    "@context": "https://schema.org",
    "@type":
      key === "contact"
        ? "ContactPage"
        : key === "home"
          ? "ProfilePage"
          : "CollectionPage",
    name: page.title,
    description: page.description,
    url: `${SITE_URL}${page.path}`,
    isPartOf: { "@id": `${SITE_URL}/#website` },
    about: { "@id": `${SITE_URL}/#person` },
  };
}
