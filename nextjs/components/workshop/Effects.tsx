"use client";
import { useState, useEffect } from "react";
import { MetalFx } from "metal-fx";
import { BorderBeam } from "border-beam";
import { ThinkingOrb } from "thinking-orbs";
import { useHydratedReducedMotion } from "./MotionKit";
export function Beam({
  children,
  dark = false,
  className = "",
}: {
  children: React.ReactNode;
  dark?: boolean;
  className?: string;
}) {
  const reduce = useHydratedReducedMotion();
  return (
    <BorderBeam
      className={className}
      colorVariant="ocean"
      theme={dark ? "dark" : "light"}
      strength={1}
      duration={3.5}
      borderRadius={16}
      active={!reduce}
      brightness={1.6}
      css={`
        [data-beam="{id}"] {
          --beam-stroke-opacity: ${dark ? 2 : 6};
        }
        [data-beam="{id}"][data-active]::after,
        [data-beam="{id}"][data-fading]::after {
          padding: 2px;
        }
      `}
      staticColors
    >
      {children}
    </BorderBeam>
  );
}
export function Orb({
  label = "Loading",
  dark = false,
  size = 20,
}: {
  label?: string;
  dark?: boolean;
  size?: 20 | 64;
}) {
  const reduce = useHydratedReducedMotion();
  return (
    <span
      className={`orb-status ${size === 64 ? "orb-status-large" : ""}`}
      role="status"
    >
      <ThinkingOrb
        state="connecting"
        size={size}
        theme={dark ? "dark" : "light"}
        color={dark ? "#94b3ff" : "#2454e6"}
        paused={!!reduce}
        aria-hidden="true"
      />
      <span>{label}</span>
    </span>
  );
}

export function Metal({ children }: { children: React.ReactNode }) {
  const reduce = useHydratedReducedMotion();
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  if (!mounted) return <div className="metal-action">{children}</div>;
  return (
    <MetalFx
      preset="silver"
      theme="dark"
      strength={1}
      ringCssPx={3}
      innerShadow
      paused={!!reduce}
      normalizeHostStyles
      className="metal-action"
    >
      {children}
    </MetalFx>
  );
}
