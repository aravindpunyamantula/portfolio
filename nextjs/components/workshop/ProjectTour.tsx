"use client";
import { useState, useRef, useEffect } from "react";
import {
  Play,
  X,
  ChevronLeft,
  ChevronRight,
  ArrowUpRight,
  Github,
} from "lucide-react";
import type { ProjectModel } from "@/lib/types";
import { ProjectVisual } from "./Projects";
import { Metal } from "./Effects";
export default function ProjectTour({ project }: { project: ProjectModel }) {
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState(0);
  const dialog = useRef<HTMLDialogElement>(null);
  useEffect(() => {
    if (open) dialog.current?.showModal();
    else if (dialog.current?.open) dialog.current.close();
  }, [open]);
  const headings = ["Meet the project", "What it does", "Explore it yourself"];
  return (
    <div className="project-tour-entry">
      <div>
        <span className="eyebrow">THE QUICK TOUR</span>
        <h2>A closer look, in three steps.</h2>
        <p>
          Preview the project, understand the idea, then explore the product or
          source.
        </p>
      </div>
      <Metal>
        <button
          className="button button-metal"
          onClick={() => {
            setStep(0);
            setOpen(true);
          }}
        >
          <Play size={18} />
          Take a quick tour
        </button>
      </Metal>
      <dialog
        ref={dialog}
        className="tour-dialog"
        onCancel={() => setOpen(false)}
        onClose={() => setOpen(false)}
        onClick={(e) => {
          if (e.target === dialog.current) setOpen(false);
        }}
      >
        {open && (
          <div className="tour-content">
            <div className="tour-heading">
              <span className="mono">
                {project.title} / {step + 1} OF 3
              </span>
              <button
                aria-label="Close project tour"
                onClick={() => setOpen(false)}
              >
                <X size={22} />
              </button>
            </div>
            <div className="tour-progress" aria-hidden="true">
              {headings.map((h, i) => (
                <span key={h} className={i <= step ? "complete" : ""} />
              ))}
            </div>
            <div className="tour-step" aria-live="polite">
              <h2>{headings[step]}</h2>
              {step === 0 ? (
                <>
                  <ProjectVisual project={project} />
                  <p>
                    {project.imageUrl || /cherries|glamup/i.test(project.title)
                      ? "A preview of the project. Continue to discover the idea behind it."
                      : "A visual introduction to the project. Continue to learn what it does."}
                  </p>
                </>
              ) : step === 1 ? (
                <>
                  <p>{project.description}</p>
                  {!!project.tags?.length && (
                    <div className="detail-tags">
                      {project.tags.map((t) => (
                        <span key={t}>{t}</span>
                      ))}
                    </div>
                  )}
                </>
              ) : (
                <>
                  <p>Go beyond the preview and explore {project.title}.</p>
                  <div className="tour-links">
                    {project.liveUrl && (
                      <a
                        className="button button-blue"
                        href={project.liveUrl}
                        target="_blank"
                        rel="noreferrer"
                      >
                        Open live project <ArrowUpRight size={18} />
                      </a>
                    )}
                    {project.githubUrl && (
                      <a
                        className="button button-outline"
                        href={project.githubUrl}
                        target="_blank"
                        rel="noreferrer"
                      >
                        <Github size={18} />
                        View source code
                      </a>
                    )}
                    {!project.liveUrl && !project.githubUrl && (
                      <p>The project details are available on this page.</p>
                    )}
                  </div>
                </>
              )}
            </div>
            <div className="tour-navigation">
              <button
                className="button button-outline"
                onClick={() => setStep((v) => v - 1)}
                disabled={step === 0}
              >
                <ChevronLeft size={18} />
                Back
              </button>
              {step < 2 ? (
                <button
                  className="button button-blue"
                  onClick={() => setStep((v) => v + 1)}
                >
                  Continue
                  <ChevronRight size={18} />
                </button>
              ) : (
                <button
                  className="button button-blue"
                  onClick={() => setOpen(false)}
                >
                  Finish tour
                </button>
              )}
            </div>
          </div>
        )}
      </dialog>
    </div>
  );
}
