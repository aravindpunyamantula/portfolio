"use client";
import { useRef, useState } from "react";
import dynamic from "next/dynamic";
import Link from "next/link";
import {
  ArrowUpRight,
  ArrowDown,
  ArrowRight,
  Box,
  GitBranch,
  Cpu,
  Asterisk,
  CornerDownRight,
} from "lucide-react";
import {
  motion,
  useScroll,
  useTransform,
  useMotionValueEvent,
} from "motion/react";
import type { PortfolioContent } from "@/lib/types";
import { useGithubStats } from "@/lib/content";
import { Reveal, useHydratedReducedMotion } from "./MotionKit";
import { Beam, Orb, Metal } from "./Effects";
import { ProjectCard } from "./Projects";
import Contact from "./Contact";
import Reviews from "./Reviews";
import ProjectJourney from "./ProjectJourney";
const ParticleScene = dynamic(() => import("./ParticleScene"), {
  ssr: false,
  loading: () => (
    <div className="scene-loading">
      <Orb label="Loading the 3D preview…" size={64} />
    </div>
  ),
});
function Blueprint({ content }: { content: PortfolioContent }) {
  const target = useRef<HTMLDivElement>(null),
    reduce = useHydratedReducedMotion();
  const { scrollYProgress } = useScroll({
    target,
    offset: ["start start", "end end"],
  });
  const [chapter, setChapter] = useState(0);
  useMotionValueEvent(scrollYProgress, "change", (v) =>
    setChapter(v < 0.33 ? 0 : v < 0.66 ? 1 : 2),
  );
  const topY = useTransform(scrollYProgress, [0, 1], [30, -45]);
  const bottomY = useTransform(scrollYProgress, [0, 1], [-30, 45]);
  const x = useTransform(scrollYProgress, [0, 1], ["12%", "-12%"]);
  const rotate = useTransform(scrollYProgress, [0, 1], [-12, 12]);
  return (
    <section className="blueprint-section">
      <div className="blueprint-story" ref={target}>
        <div className="blueprint-grid" />
        <motion.div
          className="blueprint-ghost"
          style={{ x: reduce ? 0 : x }}
          aria-hidden="true"
        >
          UNDER THE HOOD
        </motion.div>
        <div className="blueprint-layout">
          <div className="blueprint-particles">
            <ParticleScene system dark />
          </div>
          <Reveal className="blueprint-copy">
            <span className="eyebrow">
              <span className="section-index">02</span> HOW I BUILD PRODUCTS
            </span>
            <h2>
              Beautiful outside.
              <br />
              <span className="serif-word">Considered inside.</span>
            </h2>
            <p>
              The interface is only the beginning. I care just as much about the
              architecture, the data, and all the tiny decisions that make a
              product feel effortless.
            </p>
            <Link href="/projects" className="text-link">
              Explore the moving parts <ArrowUpRight size={20} />
            </Link>
            <div className="blueprint-chapters" aria-label="Build layers">
              {["The experience", "The connection", "The foundation"].map(
                (label, i) => (
                  <span
                    key={label}
                    className={chapter === i ? "current-chapter" : ""}
                  >
                    <b>0{i + 1}</b>
                    {label}
                  </span>
                ),
              )}
            </div>
          </Reveal>
          <motion.div
            className="architecture"
            style={{ rotate: reduce ? 0 : rotate }}
          >
            <motion.div
              className="architecture-layer layer-one"
              style={{ y: reduce ? 0 : topY }}
            >
              <Box size={21} />
              <div>
                <span>01 / THE EXPERIENCE</span>
                <strong>Interfaces people love.</strong>
              </div>
              <i />
            </motion.div>
            <span className="architecture-connector" />
            <div className="architecture-layer layer-two">
              <GitBranch size={21} />
              <div>
                <span>02 / THE CONNECTION</span>
                <strong>Logic that makes sense.</strong>
              </div>
              <i />
            </div>
            <span className="architecture-connector" />
            <motion.div style={{ y: reduce ? 0 : bottomY }}>
              <Beam dark>
                <div className="architecture-layer layer-three">
                  <Cpu size={21} />
                  <div>
                    <span>03 / THE FOUNDATION</span>
                    <strong>Systems built to last.</strong>
                  </div>
                  <i />
                </div>
              </Beam>
            </motion.div>
          </motion.div>
          <div className="blueprint-scroll-note mono">
            <span>SCROLL TO UNPACK THE SYSTEM</span>
            <motion.span style={{ scaleX: scrollYProgress }} />
          </div>
        </div>
      </div>
      <div className="skills-table">
        {content.skillCategories.map((category, i) => (
          <Reveal key={category.title} className="skill-row" delay={i * 0.04}>
            <span className="mono">0{i + 1}</span>
            <h3>{category.title}</h3>
            <div>
              {category.skills.map((skill) => (
                <span key={skill}>{skill}</span>
              ))}
            </div>
            <ArrowUpRight size={18} />
          </Reveal>
        ))}
      </div>
      <div className="blueprint-footer mono">
        <span>GOOD DESIGN GOES ALL THE WAY DOWN.</span>
        <span>END OF SCHEMATIC</span>
      </div>
    </section>
  );
}
export default function Workshop({ content }: { content: PortfolioContent }) {
  const heroRef = useRef<HTMLElement>(null),
    reduce = useHydratedReducedMotion();
  const { scrollYProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end start"],
  });
  const titleY = useTransform(scrollYProgress, [0, 1], [0, -85]);
  const username =
    content.links.github.split("/").filter(Boolean).pop() ||
    "aravindpunyamantula";
  const stats = useGithubStats(username);
  return (
    <>
      <section className="hero" ref={heroRef}>
        <div className="hero-topline">
          <span className="mono">
            INDEPENDENT DEVELOPER / CURIOUS BY DEFAULT
          </span>
          {content.hero.showAvailability && (
            <span className="availability">
              <span />
              {content.hero.availability}
            </span>
          )}
        </div>
        <div className="hero-layout">
          <motion.div className="hero-copy" style={{ y: reduce ? 0 : titleY }}>
            <Reveal eager>
              <div className="hero-eyebrow">
                <Asterisk
                  className="welcome-icon"
                  size={22}
                  strokeWidth={1.5}
                  aria-hidden="true"
                />{" "}
                WELCOME TO MY WORKSHOP
              </div>
              <h1>
                Ideas become
                <br />
                <span className="hero-italic">working</span>
                <br />
                products<span className="title-period">.</span>
              </h1>
              <div className="hero-intro">
                <span className="intro-line" />
                <p>
                  I&apos;m <strong>{content.hero.nameShort}</strong>.<br />
                  {content.hero.tagline}
                </p>
              </div>
              <div className="hero-actions">
                <Metal>
                  <Link className="button button-metal" href="/projects">
                    View projects <ArrowUpRight size={19} />
                  </Link>
                </Metal>
                <Link className="hero-contact" href="/contact">
                  Let&apos;s talk <ArrowUpRight size={18} />
                </Link>
              </div>
            </Reveal>
          </motion.div>
          <div className="hero-scene">
            <ProjectJourney projects={content.projects} />
          </div>
        </div>
        <div className="hero-bottom">
          <a href="#selected-work" className="scroll-cue">
            <span className="scroll-cue-icon">
              <ArrowDown size={17} />
            </span>
            <span>SCROLL TO DISCOVER</span>
          </a>
          <span className="hero-building mono">
            {content.hero.currentlyBuilding && (
              <>
                ON THE BENCH{" "}
                <span>
                  <CornerDownRight size={15} />
                  {content.hero.currentlyBuilding}
                </span>
              </>
            )}
          </span>
          <span className="mono hero-edition">PORTFOLIO / VOL. 01</span>
        </div>
      </section>
      <div className="ticker" aria-hidden="true">
        <div>
          {[0, 1].map((n) => (
            <span key={n}>
              THOUGHTFUL INTERFACES <Asterisk size={20} strokeWidth={1.5} />{" "}
              ROBUST SYSTEMS <Asterisk size={20} strokeWidth={1.5} /> REAL-WORLD
              PRODUCTS <Asterisk size={20} strokeWidth={1.5} /> ENDLESS
              CURIOSITY <Asterisk size={20} strokeWidth={1.5} />{" "}
            </span>
          ))}
        </div>
      </div>
      <section className="selected-work section-pad" id="selected-work">
        <div className="section-heading">
          <Reveal>
            <span className="eyebrow">
              <span className="section-index">01</span> SELECTED PROJECTS
            </span>
            <h2>
              A few things
              <br />
              I&apos;ve <span className="serif-word">put into the world.</span>
            </h2>
          </Reveal>
          <Reveal className="heading-aside">
            <p>{content.sections.projects.subtitle}</p>
            <Link className="text-link" href="/projects">
              View all {content.projects.length} projects{" "}
              <ArrowUpRight size={19} />
            </Link>
          </Reveal>
        </div>
        <div className="home-project-grid">
          {content.projects.slice(0, 3).map((p, i) => (
            <ProjectCard
              key={p.title}
              project={p}
              index={i}
              featured={i === 0}
            />
          ))}
        </div>
      </section>
      <Blueprint content={content} />
      <section className="about-section section-pad">
        <Reveal className="portrait-wrap">
          <img
            src="/hero.webp"
            srcSet="/hero-480.webp 480w, /hero.webp 960w"
            sizes="(max-width: 600px) 78vw, (max-width: 1100px) 35vw, 370px"
            width={960}
            height={1280}
            decoding="async"
            alt={content.hero.name}
            loading="lazy"
          />
          <div className="portrait-note mono">
            THE HUMAN BEHIND THE BUILDS.
            <ArrowUpRight size={20} />
          </div>
          <span className="portrait-stamp">
            ALWAYS
            <br />
            CURIOUS.
          </span>
        </Reveal>
        <Reveal className="about-copy">
          <span className="eyebrow">ABOUT ARAVIND</span>
          <h2>
            Engineer by craft.
            <br />
            <span className="serif-word">Builder by nature.</span>
          </h2>
          <p>{content.hero.tagline}</p>
          <p>
            From the first sketch to the final deployment, I enjoy connecting
            the dots between a good idea and a product that people can actually
            use.
          </p>
          <div className="role-list">
            {content.hero.roles.map((role) => (
              <span key={role}>
                {role}
                <ArrowUpRight size={14} />
              </span>
            ))}
          </div>
          {stats && (
            <div className="github-proof">
              <a href={content.links.github} target="_blank" rel="noreferrer">
                <strong>{stats.repos}</strong>
                <span>PUBLIC REPOSITORIES</span>
              </a>
              {stats.commits > 0 && (
                <div>
                  <strong>{stats.commits}</strong>
                  <span>COMMITS THIS YEAR</span>
                </div>
              )}
            </div>
          )}
          <a
            className="text-link"
            href={content.links.resume}
            target="_blank"
            rel="noreferrer"
          >
            A little more about me <ArrowUpRight size={18} />
          </a>
        </Reveal>
      </section>
      <section className="proof-section section-pad">
        <div className="section-heading">
          <Reveal>
            <span className="eyebrow">
              <span className="section-index">03</span> THE LEARNING NEVER STOPS
            </span>
            <h2>
              Curiosity.
              <br />
              <span className="serif-word">With credentials.</span>
            </h2>
          </Reveal>
          <Link href="/certifications" className="text-link">
            View all {content.certificates.length} certifications{" "}
            <ArrowUpRight size={20} />
          </Link>
        </div>
        <div className="credential-strip">
          {content.certificates.slice(0, 3).map((c, i) => (
            <Reveal key={c.title} delay={i * 0.08}>
              <Link href="/certifications" className="credential-small">
                <span className="credential-number">0{i + 1}</span>
                <div>
                  <span className="mono">{c.organisation}</span>
                  <h3>{c.title}</h3>
                  <span className="credential-date">{c.date}</span>
                </div>
                <ArrowUpRight size={20} />
              </Link>
            </Reveal>
          ))}
        </div>
      </section>
      <section className="review-teaser section-pad">
        <Reveal>
          <span className="eyebrow">FROM THE OTHER SIDE OF THE TABLE</span>
          <Reviews reviews={content.reviews} compact />
          <Link href="/reviews" className="text-link">
            Read all {content.reviews.length} reviews <ArrowRight size={20} />
          </Link>
        </Reveal>
      </section>
      <Contact links={content.links} compact />
    </>
  );
}
