import type { Metadata } from "next";
import { SITE_URL, projectMetadata, breadcrumbSchema } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import ProjectTour from "@/components/workshop/ProjectTour";
import ProjectShare from "@/components/workshop/ProjectShare";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getPortfolio, slugify, getProjectReadme } from "@/lib/portfolio";
import { ProjectVisual } from "@/components/workshop/Projects";
import { ArrowLeft, ArrowUpRight, Github } from "lucide-react";
import { Reveal } from "@/components/workshop/MotionKit";
export const dynamicParams = false;
export async function generateStaticParams() {
  const content = await getPortfolio();
  return content.projects.map((project) => ({ slug: slugify(project.title) }));
}
type Props = { params: Promise<{ slug: string }> };
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const content = await getPortfolio();
  const project = content.projects.find((p) => slugify(p.title) === slug);
  if (!project) notFound();
  return projectMetadata(project);
}
export default async function Project({ params }: Props) {
  const { slug } = await params;
  const content = await getPortfolio();
  const index = content.projects.findIndex((p) => slugify(p.title) === slug);
  if (index < 0) notFound();
  const p = content.projects[index],
    next = content.projects[(index + 1) % content.projects.length];
  const readme = await getProjectReadme(p.githubUrl);
  return (
    <article className="project-detail">
      <StructuredData
        data={[
          breadcrumbSchema([
            { name: "Home", path: "/" },
            { name: "Projects", path: "/projects" },
            { name: p.title, path: `/projects/${slug}` },
          ]),
          {
            "@context": "https://schema.org",
            "@type": "CreativeWork",
            "@id": `${SITE_URL}/projects/${slug}/#project`,
            name: p.title,
            description: p.description,
            url: `${SITE_URL}/projects/${slug}`,
            image: `${SITE_URL}/share/project-${slug}.png`,
            author: { "@id": `${SITE_URL}/#person` },
            inLanguage: "en",
            ...(p.liveUrl
              ? { sameAs: p.liveUrl }
              : p.githubUrl
                ? { sameAs: p.githubUrl }
                : {}),
          },
        ]}
      />

      <Link href="/projects" className="text-link">
        <ArrowLeft size={16} /> Back to the archive
      </Link>
      <Reveal>
        <div className="detail-title">
          <span className="eyebrow">
            BUILD {String(index + 1).padStart(2, "0")} /{" "}
            {p.liveUrl ? "LIVE PRODUCT" : "OPEN SOURCE"}
          </span>
          <h1>
            {p.title}
            <span className="title-period">.</span>
          </h1>
        </div>
      </Reveal>
      <Reveal className="detail-visual">
        <ProjectVisual project={p} index={index} />
      </Reveal>
      <div className="detail-body">
        <Reveal>
          <span className="eyebrow">THE IDEA & THE BUILD</span>
          <h2>
            From concept
            <br />
            to <span className="serif-word">something real.</span>
          </h2>
        </Reveal>
        <Reveal>
          <p>{p.description}</p>
          {!!p.tags?.length && (
            <div className="detail-tags">
              {p.tags.map((tag) => (
                <span key={tag}>{tag}</span>
              ))}
            </div>
          )}
          <div className="detail-actions">
            {p.liveUrl && (
              <a
                href={p.liveUrl}
                className="button button-blue"
                target="_blank"
                rel="noreferrer"
              >
                Experience the product <ArrowUpRight size={19} />
              </a>
            )}
            {p.githubUrl && (
              <a
                href={p.githubUrl}
                className="button button-outline"
                target="_blank"
                rel="noreferrer"
              >
                <Github size={17} /> Explore the source{" "}
                <ArrowUpRight size={18} />
              </a>
            )}
          </div>
        </Reveal>
      </div>
      <ProjectTour project={p} />
      {readme && (
        <details className="readme-preview">
          <summary>
            <span className="mono">FROM THE REPOSITORY / README.md</span>
            <span>
              Open the source notes <ArrowUpRight size={18} />
            </span>
          </summary>
          <pre>{readme}</pre>
          <a
            className="text-link"
            href={p.githubUrl}
            target="_blank"
            rel="noreferrer"
          >
            Continue on GitHub <ArrowUpRight size={16} />
          </a>
        </details>
      )}
      <ProjectShare title={p.title} description={p.description} slug={slug} />
      {next.title !== p.title && (
        <Link
          href={`/projects/${slugify(next.title)}`}
          className="next-project"
        >
          <span className="mono">UP NEXT / KEEP EXPLORING</span>
          <strong>{next.title}</strong>
          <ArrowUpRight size={38} />
        </Link>
      )}
    </article>
  );
}
