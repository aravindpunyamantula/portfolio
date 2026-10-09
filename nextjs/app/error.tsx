"use client";
import { RotateCcw } from "lucide-react";
export default function ErrorPage({ reset }: { reset: () => void }) {
  return (
    <div className="not-found">
      <span className="eyebrow">A SMALL INTERRUPTION</span>
      <h1>
        Let&apos;s try
        <br />
        <span className="serif-word">that again.</span>
      </h1>
      <p>The workshop couldn&apos;t open this page.</p>
      <button className="button button-blue" onClick={reset}>
        Try again <RotateCcw size={18} />
      </button>
    </div>
  );
}
