"use client";
import { useState } from "react";
import { Star, ChevronLeft, ChevronRight } from "lucide-react";
import type { ReviewModel } from "@/lib/types";
import { Reveal } from "./MotionKit";
import { CollectionSearch, CollectionFooter } from "./CollectionTools";
function Avatar({ review }: { review: ReviewModel }) {
  return (
    <span className="review-avatar">
      {review.name
        .split(" ")
        .map((n) => n[0])
        .slice(0, 2)
        .join("")}
    </span>
  );
}
export default function Reviews({
  reviews,
  compact = false,
}: {
  reviews: ReviewModel[];
  compact?: boolean;
}) {
  const [query, setQuery] = useState("");
  const [limit, setLimit] = useState(4);
  const [active, setActive] = useState(0);
  if (compact) {
    const r = reviews[active % Math.max(1, reviews.length)];
    return r ? (
      <div className="home-review-browser">
        <div aria-live="polite">
          <span className="quote-mark">“</span>
          <blockquote>{r.message.split("\n")[0]}</blockquote>
          <div className="quote-attribution">
            <Avatar review={r} />
            <div>
              <strong>{r.name}</strong>
              <span>{[r.role, r.company].filter(Boolean).join(" / ")}</span>
            </div>
          </div>
        </div>
        {reviews.length > 1 && (
          <div className="review-pagination">
            <span>
              {active + 1} / {reviews.length} client experiences
            </span>
            <button
              aria-label="Previous review"
              onClick={() =>
                setActive((v) => (v - 1 + reviews.length) % reviews.length)
              }
            >
              <ChevronLeft size={20} />
            </button>
            <button
              aria-label="Next review"
              onClick={() => setActive((v) => (v + 1) % reviews.length)}
            >
              <ChevronRight size={20} />
            </button>
          </div>
        )}
      </div>
    ) : (
      <p>Client feedback will appear here as it is added.</p>
    );
  }
  const shown = reviews.filter((r) =>
    `${r.name} ${r.role} ${r.company} ${r.message}`
      .toLowerCase()
      .includes(query.trim().toLowerCase()),
  );
  return (
    <>
      <div className="archive-toolbar">
        <p>{reviews.length} client experiences</p>
        <CollectionSearch
          noun="reviews"
          value={query}
          onChange={(v) => {
            setQuery(v);
            setLimit(4);
          }}
        />
      </div>
      <div className="reviews-list">
        {shown.slice(0, limit).map((r, i) => (
          <Reveal key={`${r.name}-${i}`} className="full-review">
            <aside>
              <Avatar review={r} />
              <h2>{r.name}</h2>
              <p>{r.role}</p>
              <strong>{r.company}</strong>
              {!!r.rating && (
                <span
                  className="review-stars"
                  aria-label={`${r.rating} out of 5 stars`}
                >
                  {Array.from({ length: r.rating }, (_, j) => (
                    <Star size={16} key={j} fill="currentColor" />
                  ))}
                </span>
              )}
            </aside>
            <div>
              <span className="quote-mark">“</span>
              <blockquote>
                {r.message.split("\n\n").map((p, j) => (
                  <p key={j}>{p}</p>
                ))}
              </blockquote>
              <span className="mono review-source">
                CLIENT FEEDBACK / {r.company}
              </span>
            </div>
          </Reveal>
        ))}
      </div>
      {!shown.length && (
        <p className="empty-state">
          {reviews.length
            ? "No reviews match. Try another name or company."
            : "Client feedback will appear here as it is added."}
        </p>
      )}
      <CollectionFooter
        total={shown.length}
        visible={limit}
        noun="reviews"
        onMore={() => setLimit((v) => v + 4)}
      />
    </>
  );
}
