"use client";
import Link from "next/link";
import { useState } from "react";
import {
  ArrowUpRight,
  Github,
  Search,
  ExternalLink,
  Code2,
} from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import type { ProjectModel } from "@/lib/types";
import { slugify } from "@/lib/slug";
import { CollectionFooter } from "./CollectionTools";
import { Reveal } from "./MotionKit";
export function ProjectVisual({
  project,
  index = 0,
}: {
  project: ProjectModel;
  index?: number;
}) {
  const name = project.title.toLowerCase();
  if (project.imageUrl)
    return (
      <div className="project-visual image-visual">
        <img
          src={project.imageUrl}
          alt={`${project.title} project preview`}
          loading="lazy"
        />
      </div>
    );
  if (name.includes("cherries") || name.includes("glamup")) {
    const cafe = name.includes("cherries");
    return (
      <div
        className={`project-visual site-preview-visual ${cafe ? "cafe-screen" : "gift-screen"}`}
      >
        <span className="cover-caption">
          {cafe ? "HOSPITALITY, REIMAGINED." : "SMALL THINGS. BIG FEELINGS."}
        </span>
        <div className="browser-preview">
          <div className="browser-chrome">
            <i />
            <i />
            <i />
            <span>{cafe ? "cherriescafe.in" : "glamupgifts.com"}</span>
            <ArrowUpRight size={11} />
          </div>
          <img
            src={
              cafe
                ? "/projects/cherries-screen.webp"
                : "/projects/glamup-screen.webp"
            }
            alt={`${project.title} live website screenshot`}
            loading="lazy"
          />
        </div>
        <span className="cover-corner">
          {cafe
            ? "CHERRIES CAFE / LIVE WEBSITE"
            : "GLAMUP GIFTS / LIVE WEBSITE"}
        </span>
      </div>
    );
  }
  if (name.includes("civic"))
    return (
      <div className="project-visual civic-visual">
        <span className="cover-caption">COMMUNITIES, CONNECTED.</span>
        <span className="civic-cover-word">
          civic
          <ArrowUpRight size={42} />
        </span>
        <div className="civic-orbit">
          <i />
          <i />
          <i />
        </div>
        <span className="cover-corner">CIVIC PARTICIPATION / MOBILE</span>
      </div>
    );
  return (
    <div className="project-visual code-visual">
      <div className="code-top">
        <span />
        <span />
        <span />
        <small>{project.title}</small>
      </div>
      <div className="terminal-art">
        <span className="terminal-comment">
          // an experiment in possibility
        </span>
        <p>
          <span>const</span> idea = <i>await</i>
        </p>
        <p className="code-indent">
          build(<em>"{project.title}"</em>);
        </p>
        <p className="terminal-result">
          ready for what&apos;s next
          <span className="terminal-cursor" />
        </p>
      </div>
      <Code2 className="code-watermark" />
      <span className="cover-corner">
        OPEN SOURCE / EXPERIMENT {String(index + 1).padStart(2, "0")}
      </span>
    </div>
  );
}
export function ProjectCard({
  project,
  index = 0,
  featured = false,
}: {
  project: ProjectModel;
  index?: number;
  featured?: boolean;
}) {
  return (
    <Reveal
      className={`project-card ${featured ? "project-card-featured" : ""}`}
    >
      <Link
        href={`/projects/${slugify(project.title)}`}
        className="project-image-link"
        aria-label={`Explore ${project.title}`}
      >
        <ProjectVisual project={project} index={index} />
        <span className="project-hover">
          Explore the build <ArrowUpRight size={20} />
        </span>
      </Link>
      <div className="project-card-meta">
        <span className="mono">
          {String(index + 1).padStart(2, "0")} /{" "}
          {project.liveUrl ? "LIVE PRODUCT" : "OPEN SOURCE"}
        </span>
        <h3>
          <Link href={`/projects/${slugify(project.title)}`}>
            {project.title}
            <ArrowUpRight size={25} />
          </Link>
        </h3>
        <p>{project.description}</p>
        <div className="project-card-bottom">
          {project.tags?.length ? (
            <span className="project-tags">
              {project.tags.slice(0, 3).join(" / ")}
            </span>
          ) : (
            <span className="project-tags">
              {project.liveUrl
                ? "Design / development / launch"
                : "Built to explore. Shared to grow."}
            </span>
          )}
          {project.liveUrl ? (
            <a
              href={project.liveUrl}
              target="_blank"
              rel="noreferrer"
              aria-label={`Visit ${project.title}`}
            >
              <ExternalLink size={17} />
            </a>
          ) : project.githubUrl ? (
            <a
              href={project.githubUrl}
              target="_blank"
              rel="noreferrer"
              aria-label={`${project.title} on GitHub`}
            >
              <Github size={18} />
            </a>
          ) : null}
        </div>
      </div>
    </Reveal>
  );
}
export function ProjectArchive({ projects }: { projects: ProjectModel[] }) {
  const [filter, setFilter] = useState("All projects"),
    [query, setQuery] = useState(""),
    [limit, setLimit] = useState(6);
  const shown = projects.filter(
    (p) =>
      (filter === "All projects" ||
        (filter === "Live websites" ? p.liveUrl : !p.liveUrl && p.githubUrl)) &&
      `${p.title} ${p.description} ${p.tags?.join(" ") ?? ""}`
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  return (
    <>
      <div className="archive-toolbar">
        <div className="filter-tabs" role="group" aria-label="Filter projects">
          {["All projects", "Live websites", "Open source"].map((f) => (
            <button
              key={f}
              onClick={() => {
                setFilter(f);
                setLimit(6);
              }}
              aria-pressed={filter === f}
            >
              {f}
              {filter === f && <span>{shown.length}</span>}
            </button>
          ))}
        </div>
        <label className="search-box">
          <Search size={16} />
          <input
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              setLimit(6);
            }}
            placeholder="Search projects…"
            aria-label="Search projects"
          />
        </label>
      </div>
      <motion.div layout className="project-grid">
        <AnimatePresence mode="popLayout">
          {shown.slice(0, limit).map((p) => (
            <motion.div
              layout
              key={p.title}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.25 }}
            >
              <ProjectCard project={p} index={projects.indexOf(p)} />
            </motion.div>
          ))}
        </AnimatePresence>
      </motion.div>
      <CollectionFooter
        total={shown.length}
        visible={limit}
        noun="projects"
        onMore={() => setLimit((v) => v + 6)}
      />
      {!shown.length && (
        <p className="empty-state">
          No builds match that search. Try another term.
        </p>
      )}
    </>
  );
}
