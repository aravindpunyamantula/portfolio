import { ArrowUpRight } from "lucide-react";
import Link from "next/link";
export default function NotFound() {
  return (
    <div className="not-found">
      <span className="eyebrow">404 / OUTSIDE THE WORKSHOP</span>
      <h1>
        A little
        <br />
        <span className="serif-word">off the blueprint.</span>
      </h1>
      <p>
        This page hasn&apos;t been built. There&apos;s plenty to explore back
        home.
      </p>
      <Link href="/" className="button button-blue">
        Back to the workshop <ArrowUpRight size={18} />
      </Link>
    </div>
  );
}
