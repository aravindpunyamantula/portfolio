import snapshot from "./fallback.json";
import type { PortfolioContent } from "./types";
// Last known content from the same public GitHub CMS; used when the source is unavailable.
export const fallbackContent: PortfolioContent = snapshot;
