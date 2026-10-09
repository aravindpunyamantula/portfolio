import { ArrowDownRight } from "lucide-react";
import { Reveal } from "./MotionKit";
export default function PageHeading({
  index,
  title,
  accent,
  description,
}: {
  index: string;
  title: string;
  accent: string;
  description: string;
}) {
  return (
    <div className="page-heading">
      <Reveal>
        <span className="eyebrow">
          <span className="section-index">{index}</span> INSIDE THE WORKSHOP
        </span>
        <h1>
          {title}
          <br />
          <span className="serif-word">{accent}</span>
          <span className="title-period">.</span>
        </h1>
      </Reveal>
      <Reveal className="page-heading-description">
        <p>{description}</p>
        <span className="mono">
          EXPLORE / DISCOVER / CONNECT <ArrowDownRight size={18} />
        </span>
      </Reveal>
    </div>
  );
}
