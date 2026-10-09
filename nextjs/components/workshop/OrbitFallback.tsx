"use client";
import { useEffect, useRef } from "react";
const colors = ["#9aafd1", "#2454e6", "#d2dbec"];
const angles = [35, -35, 90];
const particles = Array.from({ length: 240 }, (_, i) => {
  const angle = (i / 80) * Math.PI * 2;
  const ring = i % 3;
  const tilt = (angles[ring] * Math.PI) / 180;
  const x = 155 * Math.cos(angle),
    y = 64 * Math.sin(angle);
  return {
    ring,
    x: 240 + x * Math.cos(tilt) - y * Math.sin(tilt),
    y: 210 + x * Math.sin(tilt) + y * Math.cos(tilt),
    scatterX: 35 + ((i * 137) % 410),
    scatterY: 30 + ((i * 97) % 360),
    layerX: 240 + 155 * Math.cos(angle),
    layerY: 210 + (ring - 1) * 92 + 42 * Math.sin(angle),
  };
});
export default function OrbitFallback({
  system,
  dispersed,
  onSettled,
}: {
  system: boolean;
  dispersed: boolean;
  onSettled: () => void;
}) {
  const callback = useRef(onSettled);
  callback.current = onSettled;
  useEffect(() => {
    const reduce = window.matchMedia(
      "(prefers-reduced-motion: reduce)",
    ).matches;
    const timer = setTimeout(() => callback.current(), reduce ? 0 : 1050);
    return () => clearTimeout(timer);
  }, [system, dispersed]);
  return (
    <svg
      className="orbit-fallback"
      viewBox="0 0 480 420"
      data-view={system ? "blueprint" : "product"}
      data-dispersed={dispersed}
      aria-hidden="true"
    >
      {colors.map((color, i) => (
        <ellipse
          key={color}
          cx="240"
          cy="210"
          rx="155"
          ry="64"
          fill="none"
          stroke={color}
          strokeWidth="22"
          style={{
            transformOrigin: "240px 210px",
            transform: `translateY(${system ? (i - 1) * 92 : 0}px) rotate(${system ? 0 : angles[i]}deg)`,
            opacity: dispersed ? 0 : 1,
          }}
        />
      ))}
      <g fill="#2454e6">
        {particles.map((p, i) => (
          <circle
            key={i}
            r={i % 5 === 0 ? 2 : 1.3}
            style={{
              transform: `translate(${dispersed ? p.scatterX : system ? p.layerX : p.x}px,${dispersed ? p.scatterY : system ? p.layerY : p.y}px)`,
              opacity: dispersed ? 1 : system ? 0.5 : 0,
            }}
          />
        ))}
      </g>
    </svg>
  );
}
