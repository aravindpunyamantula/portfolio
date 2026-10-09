"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { ArrowUpRight, ArrowUp, Menu, X, Github, Linkedin } from "lucide-react";
import { AnimatePresence, motion } from "motion/react";
import type { LinksContent } from "@/lib/types";
import { MotionProvider, ScrollProgress } from "./MotionKit";
const routes = [
  ["/", "Home"],
  ["/projects", "Projects"],
  ["/certifications", "Certifications"],
  ["/reviews", "Reviews"],
  ["/contact", "Contact"],
];
export default function Shell({
  children,
  links,
  tagline,
}: {
  children: React.ReactNode;
  links: LinksContent;
  tagline: string;
}) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  useEffect(() => setOpen(false), [pathname]);
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);
  return (
    <MotionProvider>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <ScrollProgress />
      <header className="site-header">
        <Link
          href="/"
          className="wordmark"
          aria-label="Aravind's workshop home"
        >
          <img
            className="brand-symbol"
            src="/icons/monogram.svg?v=serif-a1"
            alt=""
            width={44}
            height={44}
          />
          <span>
            aravind<span className="wordmark-dot">.</span>
            <small>THE DIGITAL WORKSHOP</small>
          </span>
        </Link>
        <nav className="desktop-nav" aria-label="Main navigation">
          {routes.map(([href, label]) => (
            <Link
              key={href}
              href={href}
              aria-current={
                pathname === href ||
                (href !== "/" && pathname.startsWith(href + "/"))
                  ? "page"
                  : undefined
              }
            >
              {label}
            </Link>
          ))}
        </nav>
        <a
          href={links.resume}
          target="_blank"
          rel="noreferrer"
          className="resume-link"
        >
          Resume <ArrowUpRight size={16} />
        </a>
        <button
          className="menu-toggle"
          onClick={() => setOpen(!open)}
          aria-expanded={open}
          aria-controls="mobile-navigation"
          aria-label={open ? "Close navigation" : "Open navigation"}
        >
          {open ? <X /> : <Menu />}
        </button>
      </header>
      <AnimatePresence>
        {open && (
          <motion.nav
            id="mobile-navigation"
            className="mobile-nav"
            aria-label="Mobile navigation"
            initial={{ opacity: 0, y: -12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
          >
            {routes.map(([href, label]) => (
              <Link
                key={href}
                href={href}
                onClick={() => setOpen(false)}
                aria-current={
                  pathname === href ||
                  (href !== "/" && pathname.startsWith(href + "/"))
                    ? "page"
                    : undefined
                }
              >
                {label}
                <ArrowUpRight size={20} />
              </Link>
            ))}
          </motion.nav>
        )}
      </AnimatePresence>
      <main id="main">{children}</main>
      <footer className="site-footer">
        <div>
          <Link href="/" className="footer-brand">
            aravind<span>.</span>
          </Link>
          <p>{tagline}</p>
        </div>
        <div className="footer-links">
          <a href={links.github} target="_blank" rel="noreferrer">
            <Github size={17} /> GitHub
          </a>
          <a href={links.linkedin} target="_blank" rel="noreferrer">
            <Linkedin size={17} /> LinkedIn
          </a>
          <a href={links.email}>
            Email <ArrowUpRight size={17} />
          </a>
        </div>
        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} Aravind Kumar</span>
          <span>THOUGHTFULLY BUILT. ALWAYS EVOLVING.</span>
          <button
            onClick={() =>
              window.scrollTo({
                top: 0,
                behavior: window.matchMedia("(prefers-reduced-motion: reduce)")
                  .matches
                  ? "instant"
                  : "smooth",
              })
            }
          >
            Back to top <ArrowUp size={15} />
          </button>
        </div>
      </footer>
    </MotionProvider>
  );
}
