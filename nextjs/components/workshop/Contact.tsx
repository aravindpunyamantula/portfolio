"use client";
import { useState, useRef } from "react";
import {
  ArrowUpRight,
  Check,
  Copy,
  Github,
  Linkedin,
  Send,
} from "lucide-react";
import type { LinksContent } from "@/lib/types";
import { Metal, Orb } from "./Effects";
import { Reveal } from "./MotionKit";
export default function Contact({
  links,
  compact = false,
}: {
  links: LinksContent;
  compact?: boolean;
}) {
  const Heading = compact ? "h2" : "h1";
  const [status, setStatus] = useState<
      "idle" | "sending" | "success" | "error"
    >("idle"),
    [copied, setCopied] = useState(false);
  const lock = useRef(false);
  const email = links.email.replace("mailto:", "");
  const submit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (lock.current) return;
    const form = e.currentTarget;
    const data = new FormData(form);
    if (String(data.get("website") ?? "")) return;
    const name = String(data.get("name") ?? "").trim(),
      emailValue = String(data.get("email") ?? "").trim(),
      message = String(data.get("message") ?? "").trim();
    if (!name || !message || !emailValue) {
      setStatus("error");
      return;
    }
    lock.current = true;
    setStatus("sending");
    try {
      const response = await fetch(
        "https://api.emailjs.com/api/v1.0/email/send",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          signal: AbortSignal.timeout(15000),
          body: JSON.stringify({
            service_id:
              process.env.NEXT_PUBLIC_EMAILJS_SERVICE_ID || "service_vhgrmso",
            template_id:
              process.env.NEXT_PUBLIC_EMAILJS_TEMPLATE_ID || "template_gwnxpve",
            user_id:
              process.env.NEXT_PUBLIC_EMAILJS_PUBLIC_KEY || "21uNgzXVuKbRypUha",
            template_params: {
              name,
              email: emailValue,
              message,
              time: new Date().toISOString(),
            },
          }),
        },
      );
      if (!response.ok) throw new Error("send failed");
      setStatus("success");
      form.reset();
    } catch {
      setStatus("error");
    } finally {
      lock.current = false;
    }
  };
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(email);
      setCopied(true);
    } catch {
      setCopied(false);
    }
  };
  return (
    <section
      className={`contact-section ${compact ? "contact-home" : ""}`}
      id="contact"
    >
      <Reveal className="contact-intro">
        <span className="eyebrow">
          <span className="section-index">04</span> YOUR IDEA, NEXT
        </span>
        <Heading>
          Good things
          <br />
          start with
          <br />
          <span className="serif-word">a conversation.</span>
        </Heading>
        <p>
          A product to build. A problem to solve. Or just a hello.
          <br />
          I&apos;d love to hear what you have in mind.
        </p>
        <a className="contact-email" href={links.email}>
          {email}
          <ArrowUpRight size={22} />
        </a>
        <div className="contact-socials">
          <a href={links.github} target="_blank" rel="noreferrer">
            <Github size={16} />
            GitHub
          </a>
          <a href={links.linkedin} target="_blank" rel="noreferrer">
            <Linkedin size={16} />
            LinkedIn
          </a>
          <button onClick={copy}>
            {copied ? <Check size={16} /> : <Copy size={16} />}{" "}
            {copied ? "Copied" : "Copy email"}
          </button>
        </div>
      </Reveal>
      <Reveal className="contact-form-wrap" delay={0.1}>
        <div className="form-heading">
          <span className="mono">A LITTLE ABOUT YOUR IDEA</span>
          <ArrowUpRight size={24} />
        </div>
        <form onSubmit={submit}>
          <div className="form-row">
            <label>
              Your name
              <input
                name="name"
                autoComplete="name"
                placeholder="What should I call you?"
                required
                maxLength={100}
                disabled={status === "sending"}
              />
            </label>
            <label>
              Email address
              <input
                name="email"
                type="email"
                autoComplete="email"
                placeholder="you@example.com"
                required
                maxLength={254}
                disabled={status === "sending"}
              />
            </label>
          </div>
          <label>
            What are you thinking?
            <textarea
              name="message"
              placeholder="Tell me about your idea, opportunity, or project…"
              required
              minLength={10}
              maxLength={5000}
              rows={5}
              disabled={status === "sending"}
            />
          </label>
          <label className="honeypot" aria-hidden="true">
            Website
            <input name="website" tabIndex={-1} autoComplete="off" />
          </label>
          <div className="form-submit-row">
            <span className="mono">STRAIGHT TO MY INBOX.</span>
            <Metal>
              <button
                type="submit"
                className="button button-metal"
                disabled={status === "sending"}
              >
                {status === "sending" ? (
                  <Orb label="Sending…" dark />
                ) : (
                  <>
                    Send your message <Send size={17} />
                  </>
                )}
              </button>
            </Metal>
          </div>
          <div className="form-status" aria-live="polite">
            {status === "success" && (
              <p className="success-message">
                <Check size={18} /> Message sent. Thanks for stopping by —
                I&apos;ll get back to you soon.
              </p>
            )}
            {status === "error" && (
              <p className="error-message">
                Couldn&apos;t send your message. Please try again or{" "}
                <a href={links.email}>email me directly</a>.
              </p>
            )}
          </div>
        </form>
      </Reveal>
    </section>
  );
}
