"use client";
import { useState, useRef } from "react";
import dynamic from "next/dynamic";
import Link from "next/link";
import {
  ArrowRight,
  ArrowLeft,
  ArrowUpRight,
  RotateCcw,
  Box,
  GitBranch,
  Database,
  Code2,
  Github,
  Check,
} from "lucide-react";
import type { ProjectModel } from "@/lib/types";
import { projectStory } from "@/lib/project-story";
import { slugify } from "@/lib/slug";
import { Beam, Orb, Metal } from "./Effects";
import { useHydratedReducedMotion } from "./MotionKit";
const Scene = dynamic(() => import("./ParticleScene"), {
  ssr: false,
  loading: () => null,
});
const steps = ["Experience", "Behind the build", "Explore the result"];
const layerIcons = { interface: Box, logic: GitBranch, data: Database };
export default function ProjectJourney({
  projects,
}: {
  projects: ProjectModel[];
}) {
  const stage = useRef<HTMLDivElement>(null);
  const reduce = useHydratedReducedMotion();
  const [selected, setSelected] = useState(0);
  const [step, setStep] = useState(0);
  const [loading, setLoading] = useState(true);
  const [replay, setReplay] = useState<"idle" | "scatter" | "assemble">("idle");
  const project = projects[selected] ?? projects[0];
  const changeStep = (next: number) => {
    setReplay("idle");
    setStep(next);
  };
  if (!project) return null;
  const story = projectStory(project);
  const slug = slugify(project.title);
  return (
    <div className="project-explorer project-journey">
      <div className="journey-intro">
        <span className="mono">FROM IDEA TO WORKING PRODUCT</span>
        <p>Choose a project. Discover the thinking behind it.</p>
      </div>
      <label className="journey-selector" htmlFor="journey-project">
        <span>
          Explore a project <small>{projects.length} projects</small>
        </span>
        <select
          id="journey-project"
          value={selected}
          onChange={(e) => {
            setSelected(Number(e.target.value));
            setStep(0);
            setReplay("idle");
          }}
        >
          {projects.map((p, i) => (
            <option key={`${p.title}-${i}`} value={i}>
              {p.title}
            </option>
          ))}
        </select>
      </label>
      <div
        ref={stage}
        className={`explorer-scene journey-scene ${step === 1 ? "journey-scene-layered" : ""}`}
        aria-hidden="true"
      >
        <Scene
          model="orbit"
          system={step === 1}
          dispersed={replay === "scatter"}
          scrollDriven={false}
          onReady={() => setLoading(false)}
          onSettled={() =>
            setReplay((current) =>
              current === "scatter"
                ? "assemble"
                : current === "assemble"
                  ? "idle"
                  : current,
            )
          }
        />
        {loading && (
          <div className="explorer-loading">
            <Orb label="Preparing the project story…" size={64} />
          </div>
        )}
        {step === 1 && !!story.layers.length && (
          <div className="journey-layer-labels">
            {story.layers.map((layer) => (
              <span
                className={`journey-layer-label layer-${layer.id}`}
                key={layer.id}
              >
                {layer.title}
              </span>
            ))}
          </div>
        )}
        <span className="journey-scene-caption">
          {replay === "scatter"
            ? "Every product starts with an idea."
            : replay === "assemble"
              ? "Bringing the pieces together."
              : step === 1
                ? "A closer look at the build"
                : "Ideas, connected."}
        </span>
      </div>
      <div
        className="journey-progress"
        role="group"
        aria-label="Project story steps"
      >
        {steps.map((label, i) => (
          <button
            key={label}
            aria-label={label}
            aria-current={step === i ? "step" : undefined}
            onClick={() => changeStep(i)}
          >
            <span>
              {i < step ? <Check size={13} /> : String(i + 1).padStart(2, "0")}
            </span>
            <strong>{label}</strong>
          </button>
        ))}
      </div>
      <Beam className="journey-beam">
        <section className="journey-card" aria-labelledby="journey-heading">
          <div className="journey-step-heading">
            <span className="mono">STEP {step + 1} OF 3</span>
            <button
              className="journey-replay"
              onClick={() => {
                setStep(0);
                setReplay("scatter");
                stage.current?.scrollIntoView({
                  behavior: reduce ? "instant" : "smooth",
                  block: "start",
                });
              }}
              disabled={loading || replay !== "idle"}
            >
              <RotateCcw size={14} />
              Replay the build
            </button>
          </div>
          <div aria-live="polite" className="journey-content">
            <h2 id="journey-heading">
              {step === 0
                ? "See the experience"
                : step === 1
                  ? "Behind the build"
                  : "Explore the result"}
            </h2>
            {step === 0 ? (
              <>
                {story.image ? (
                  <div className="journey-preview">
                    <img
                      src={story.image}
                      alt={`${project.title} project preview`}
                      loading="lazy"
                    />
                    <span>{project.title}</span>
                  </div>
                ) : (
                  <div className="journey-project-intro">
                    <Code2 size={28} />
                    <strong>{project.title}</strong>
                    <span>
                      {project.githubUrl
                        ? "An open-source project"
                        : "A project by Aravind"}
                    </span>
                  </div>
                )}
                <p>
                  {story.overview ||
                    `Discover ${project.title} and explore its project details.`}
                </p>
                {project.story?.audience && (
                  <p className="journey-fact">
                    <strong>Who it helps</strong>
                    {project.story.audience}
                  </p>
                )}
              </>
            ) : step === 1 ? (
              <>
                {story.layers.length ? (
                  <div className="journey-build-layers">
                    {story.layers.map((layer) => {
                      const Icon = layerIcons[layer.id];
                      return (
                        <div key={layer.id}>
                          <Icon size={18} />
                          <div>
                            <h3>{layer.title}</h3>
                            <p>{layer.description}</p>
                            {!!layer.technologies.length && (
                              <div className="journey-tools">
                                {layer.technologies.map((tool) => (
                                  <span key={tool}>{tool}</span>
                                ))}
                              </div>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <>
                    <p>
                      {story.notes ||
                        `Explore the project page for more about ${project.title}.`}
                    </p>
                    {!!story.technologies.length && (
                      <div className="journey-stack">
                        <span className="mono">
                          TOOLS NAMED IN THIS PROJECT
                        </span>
                        <div className="journey-tools">
                          {story.technologies.map((tool) => (
                            <span key={tool}>{tool}</span>
                          ))}
                        </div>
                      </div>
                    )}
                  </>
                )}
                {project.story?.contribution && (
                  <p className="journey-fact">
                    <strong>My contribution</strong>
                    {project.story.contribution}
                  </p>
                )}
              </>
            ) : (
              <>
                <div className="journey-result-icon">
                  <ArrowUpRight size={32} />
                </div>
                <h3>{project.title}</h3>
                <p>
                  {project.story?.outcome ||
                    "Take a closer look at the project and explore the work for yourself."}
                </p>
                <div className="journey-result-actions">
                  {project.liveUrl && (
                    <Metal>
                      <a
                        href={project.liveUrl}
                        target="_blank"
                        rel="noreferrer"
                        className="button button-metal"
                      >
                        Open live project
                        <ArrowUpRight size={17} />
                      </a>
                    </Metal>
                  )}
                  {project.githubUrl && (
                    <a
                      href={project.githubUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="button button-outline"
                    >
                      <Github size={17} />
                      Explore the source
                    </a>
                  )}
                  <Link href={`/projects/${slug}`} className="text-link">
                    View project details
                    <ArrowUpRight size={17} />
                  </Link>
                </div>
              </>
            )}
          </div>
          <div className="journey-animation-status" role="status">
            {replay !== "idle" && (
              <Orb
                label={
                  replay === "scatter"
                    ? "Starting with an idea…"
                    : "Bringing the pieces together…"
                }
              />
            )}
          </div>
          <div className="journey-navigation">
            <button
              className="journey-back"
              onClick={() => changeStep(step - 1)}
              disabled={step === 0}
            >
              <ArrowLeft size={16} />
              Back
            </button>
            {step < 2 ? (
              <button
                className="button button-blue journey-continue"
                onClick={() => changeStep(step + 1)}
              >
                Continue
                <ArrowRight size={17} />
              </button>
            ) : (
              <button className="journey-back" onClick={() => changeStep(0)}>
                Back to experience
                <RotateCcw size={16} />
              </button>
            )}
          </div>
        </section>
      </Beam>
    </div>
  );
}
