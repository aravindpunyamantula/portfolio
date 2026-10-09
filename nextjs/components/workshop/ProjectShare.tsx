"use client";
import { useEffect, useState } from "react";
import {
  Share2,
  Link2,
  Check,
  MessageCircle,
  Instagram,
  Linkedin,
  Download,
  X,
} from "lucide-react";
import { SITE_URL } from "@/lib/seo";
import { Orb } from "./Effects";
export default function ProjectShare({
  title,
  slug,
  description,
}: {
  title: string;
  slug: string;
  description: string;
}) {
  const url = `${SITE_URL}/projects/${slug}`;
  const [copied, setCopied] = useState(false),
    [story, setStory] = useState(false),
    [file, setFile] = useState<File | null>(null),
    [status, setStatus] = useState(""),
    [preparing, setPreparing] = useState(false);
  const imageUrl = `/share/project-${slug}-story.png`;
  useEffect(() => {
    if (!story || file || !navigator.canShare) return;
    const controller = new AbortController();
    setPreparing(true);
    fetch(imageUrl, { signal: controller.signal })
      .then((res) => {
        if (!res.ok) throw Error("Card unavailable");
        return res.blob();
      })
      .then((blob) =>
        setFile(
          new File([blob], `aravind-${slug}-story.png`, { type: "image/png" }),
        ),
      )
      .catch((error) => {
        if (error.name !== "AbortError")
          setStatus("Use Download story card to save the image.");
      })
      .finally(() => {
        if (!controller.signal.aborted) setPreparing(false);
      });
    return () => controller.abort();
  }, [story, file, imageUrl, slug]);
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setStatus("Project link copied.");
    } catch {
      setStatus("Copy the project link from the field below.");
    }
  };
  const share = async () => {
    if (!navigator.share) {
      await copy();
      return;
    }
    try {
      await navigator.share({
        title: `${title} | Aravind Kumar`,
        text: description,
        url,
      });
      setStatus("");
    } catch (e) {
      if (e instanceof Error && e.name !== "AbortError")
        setStatus("Sharing is unavailable here. Use Copy link or WhatsApp.");
    }
  };
  const shareStory = async () => {
    if (!file || !navigator.canShare?.({ files: [file] })) return;
    try {
      await navigator.share({
        files: [file],
        title: `${title} | Aravind Kumar`,
      });
    } catch (e) {
      if (e instanceof Error && e.name !== "AbortError")
        setStatus(
          "Please download the story image and share it from your gallery.",
        );
    }
  };
  return (
    <section className="project-share" aria-labelledby="share-heading">
      <div className="share-heading">
        <div>
          <span className="eyebrow">WORTH PASSING ALONG</span>
          <h2 id="share-heading">Share this project.</h2>
          <p>A good idea travels further when you share it.</p>
        </div>
        <Share2 size={28} strokeWidth={1.5} />
      </div>
      <div className="share-actions">
        <button onClick={share}>
          <Share2 size={18} /> Share
        </button>
        <a
          href={`https://wa.me/?text=${encodeURIComponent(`${title} — built by Aravind Kumar\n${url}`)}`}
          target="_blank"
          rel="noreferrer"
        >
          <MessageCircle size={18} /> WhatsApp
        </a>
        <a
          href={`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`}
          target="_blank"
          rel="noreferrer"
        >
          <Linkedin size={18} /> LinkedIn
        </a>
        <button onClick={() => setStory(!story)} aria-expanded={story}>
          {story ? <X size={18} /> : <Instagram size={18} />} Instagram story
        </button>
        <button onClick={copy}>
          {copied ? <Check size={18} /> : <Link2 size={18} />}{" "}
          {copied ? "Link copied" : "Copy link"}
        </button>
      </div>
      <input
        className="share-url"
        value={url}
        readOnly
        aria-label="Project sharing link"
        onFocus={(e) => e.target.select()}
      />
      {story && (
        <div className="story-share-panel">
          <img
            src={imageUrl}
            alt={`${title} Instagram story card preview`}
            loading="lazy"
          />
          <div>
            <h3>A project, beautifully packaged.</h3>
            <p>
              Save this story card and add it to Instagram. Copy the project
              link above to use as a link sticker.
            </p>
            <a
              className="button button-blue"
              href={imageUrl}
              download={`${slug}-story.png`}
            >
              <Download size={18} /> Download story card
            </a>
            {file && navigator.canShare?.({ files: [file] }) && (
              <button className="button button-outline" onClick={shareStory}>
                <Share2 size={18} /> Share story image
              </button>
            )}
            {preparing && <Orb label="Preparing image sharing…" />}
          </div>
        </div>
      )}
      <p role="status" className="share-status">
        {status}
      </p>
    </section>
  );
}
