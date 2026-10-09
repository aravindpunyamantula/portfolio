import type { ProjectModel } from "./types";

// Show only named tools present in the project's own content. Portfolio-wide
// skills are not evidence that a particular project uses a technology.
const knownTools = [
  "Node.js",
  "Next.js",
  "React",
  "Flutter",
  "Dart",
  "TypeScript",
  "JavaScript",
  "Python",
  "MongoDB",
  "PostgreSQL",
  "Firebase",
  "Ollama",
  "Llama 3.2",
  "Docker",
  "Express",
  "Tailwind CSS",
];
export function projectStory(project: ProjectModel) {
  const description = project.description.trim();
  const firstSentence =
    description.match(/^.*?[.!?](?=\s+[A-Z]|$)/)?.[0] || description;
  const layers = project.story?.layers ?? [];
  const technologies = Array.from(
    new Set([
      ...(project.tags ?? []),
      ...layers.flatMap((layer) => layer.technologies),
      ...knownTools.filter((tool) =>
        new RegExp(
          `(^|[^a-zA-Z])${tool.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}(?=$|[^a-zA-Z])`,
          "i",
        ).test(description),
      ),
    ]),
  );
  return {
    overview: firstSentence,
    notes: description.slice(firstSentence.length).trim() || description,
    technologies,
    layers,
    image:
      project.imageUrl ||
      (/cherries/i.test(project.title)
        ? "/projects/cherries-screen.webp"
        : /glamup/i.test(project.title)
          ? "/projects/glamup-screen.webp"
          : undefined),
  };
}
