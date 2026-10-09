import { ArrowUpRight } from "lucide-react";
import {
  pageMetadata,
  webpageSchema,
  breadcrumbSchema,
  SITE_URL,
} from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import { getPortfolio } from "@/lib/portfolio";
import { ProjectArchive } from "@/components/workshop/Projects";
import PageHeading from "@/components/workshop/PageHeading";
import Link from "next/link";
import { slugify } from "@/lib/slug";
export const metadata = pageMetadata("projects");
export default async function Projects() {
  const content = await getPortfolio();
  return (
    <div className="archive-page">
      <StructuredData
        data={[
          webpageSchema("projects"),
          breadcrumbSchema([
            { name: "Home", path: "/" },
            { name: "Projects", path: "/projects" },
          ]),
        ]}
      />
      <PageHeading
        index="01"
        title="Projects"
        accent="made real"
        description={content.sections.projects.subtitle}
      />
      <StructuredData
        data={{
          "@context": "https://schema.org",
          "@type": "ItemList",
          name: "Projects by Aravind Kumar",
          itemListElement: content.projects.map((project, index) => ({
            "@type": "ListItem",
            position: index + 1,
            name: project.title,
            url: `${SITE_URL}/projects/${slugify(project.title)}`,
          })),
        }}
      />
      <ProjectArchive projects={content.projects} />
      <div className="archive-end">
        <span className="mono">EVERY BUILD BEGINS WITH A CONVERSATION.</span>
        <Link href="/contact">
          What should we build next? <ArrowUpRight size={22} />
        </Link>
      </div>
    </div>
  );
}
