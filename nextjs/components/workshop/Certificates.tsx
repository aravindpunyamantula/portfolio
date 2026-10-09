"use client";
import { useState, useRef, useEffect } from "react";
import { ArrowUpRight, Maximize2, X, Award } from "lucide-react";
import type { CertificateModel } from "@/lib/types";
import { CollectionSearch, CollectionFooter } from "./CollectionTools";
import { Reveal } from "./MotionKit";
function CertificateImage({ certificate }: { certificate: CertificateModel }) {
  const [broken, setBroken] = useState(false);
  return certificate.imageUrl && !broken ? (
    <img
      src={certificate.imageUrl}
      alt={`${certificate.title} credential`}
      loading="lazy"
      onError={() => setBroken(true)}
    />
  ) : (
    <div className="certificate-image-fallback">
      <Award size={55} />
      <strong>{certificate.organisation}</strong>
      <span>Credential image unavailable</span>
    </div>
  );
}
export default function Certificates({
  certificates,
}: {
  certificates: CertificateModel[];
}) {
  const [selected, setSelected] = useState<CertificateModel | null>(null);
  const [query, setQuery] = useState("");
  const [organisation, setOrganisation] = useState("All issuers");
  const [limit, setLimit] = useState(6);
  const issuers = Array.from(
    new Set(certificates.map((c) => c.organisation).filter(Boolean)),
  );
  const shown = certificates.filter(
    (c) =>
      (organisation === "All issuers" || c.organisation === organisation) &&
      `${c.title} ${c.organisation} ${c.skills.join(" ")}`
        .toLowerCase()
        .includes(query.trim().toLowerCase()),
  );
  const dialog = useRef<HTMLDialogElement>(null);
  useEffect(() => {
    if (selected) {
      dialog.current?.showModal();
    } else if (dialog.current?.open) {
      dialog.current.close();
    }
  }, [selected]);
  return (
    <>
      <div className="archive-toolbar">
        <label className="collection-select">
          Certificate issuer
          <select
            value={organisation}
            onChange={(e) => {
              setOrganisation(e.target.value);
              setLimit(6);
            }}
          >
            <option>All issuers</option>
            {issuers.map((issuer) => (
              <option key={issuer}>{issuer}</option>
            ))}
          </select>
        </label>
        <CollectionSearch
          noun="certifications"
          value={query}
          onChange={(v) => {
            setQuery(v);
            setLimit(6);
          }}
        />
      </div>
      <div className="certificate-grid">
        {shown.slice(0, limit).map((c, i) => (
          <Reveal key={`${c.title}-${i}`} className="certificate-card">
            <button
              className="certificate-preview"
              onClick={() => setSelected(c)}
              aria-label={`Preview ${c.title}`}
            >
              <CertificateImage certificate={c} />
              <span>
                <Maximize2 size={17} />
              </span>
            </button>
            <div className="certificate-info">
              <div className="certificate-meta">
                <span className="mono">{c.organisation}</span>
                <span>{c.date}</span>
              </div>
              <h2>{c.title}</h2>
              <div className="certificate-skills">
                {c.skills.map((s) => (
                  <span key={s}>{s}</span>
                ))}
              </div>
              {c.link ? (
                <a
                  className="text-link"
                  href={c.link}
                  target="_blank"
                  rel="noreferrer"
                >
                  Verify credential <ArrowUpRight size={16} />
                </a>
              ) : (
                <span className="credential-date">
                  Certificate available in preview
                </span>
              )}
            </div>
          </Reveal>
        ))}
      </div>
      {!shown.length && (
        <p className="empty-state">
          {certificates.length
            ? "No certifications match. Try another skill or issuer."
            : "New certifications will appear here as they are added."}
        </p>
      )}
      <CollectionFooter
        total={shown.length}
        visible={limit}
        noun="certifications"
        onMore={() => setLimit((v) => v + 6)}
      />
      <dialog
        ref={dialog}
        className="certificate-dialog"
        onCancel={() => setSelected(null)}
        onClose={() => setSelected(null)}
        onClick={(e) => {
          if (e.target === dialog.current) setSelected(null);
        }}
      >
        {selected && (
          <div>
            <button
              className="dialog-close"
              onClick={() => setSelected(null)}
              aria-label="Close certificate preview"
            >
              <X />
            </button>
            <h2>{selected.title}</h2>
            <CertificateImage certificate={selected} />
            {selected.link && (
              <a
                className="text-link"
                href={selected.link}
                target="_blank"
                rel="noreferrer"
              >
                Verify credential <ArrowUpRight size={17} />
              </a>
            )}
          </div>
        )}
      </dialog>
    </>
  );
}
