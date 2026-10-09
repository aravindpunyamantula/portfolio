"use client";
import {
  motion,
  MotionConfig,
  useScroll,
  useSpring,
  useReducedMotion,
} from "motion/react";
import { useState, useEffect, type ReactNode } from "react";
export function useHydratedReducedMotion() {
  const reduce = useReducedMotion();
  const [hydrated, setHydrated] = useState(false);
  useEffect(() => setHydrated(true), []);
  return hydrated && !!reduce;
}
export function MotionProvider({ children }: { children: ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}
export function Reveal({
  children,
  className = "",
  delay = 0,
  eager = false,
}: {
  children: ReactNode;
  className?: string;
  delay?: number;
  eager?: boolean;
}) {
  const reduce = useHydratedReducedMotion();
  return (
    <motion.div
      className={className}
      initial={eager ? false : { opacity: 0, y: reduce ? 0 : 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-40px" }}
      transition={{ duration: 0.7, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}
export function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, { stiffness: 150, damping: 30 });
  return (
    <motion.div
      className="scroll-progress"
      style={{ scaleX }}
      aria-hidden="true"
    />
  );
}
