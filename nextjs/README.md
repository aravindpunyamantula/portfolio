# Aravind — The Digital Workshop

The new Next.js portfolio lives in this directory. The original Flutter source is retained in the repository for reference.

## Run locally

```sh
cd nextjs
npm install
npm run dev
```

Open http://localhost:3000. For a production run, use `npm run build` then `npm start`.

## Experience

- A three-ring Three.js hero matching its interactive SVG fallback, with deterministic particles, a three-step project story (Experience → Behind the build → Explore the result), a particle assembly replay, pointer response, and scroll-driven separation in the architecture chapter. The hero rings separate when viewing build notes and assemble for the experience. Its layout stays in normal flow to keep the footer row clear.
- A pinned blueprint chapter with layered architecture, particle background, and scroll progress.
- Motion reveals, parallax, animated project filtering, and responsive navigation.
- Libraries.dev `metal-fx` silver buttons for primary actions; `border-beam` for the project explorer and foundation layer; `thinking-orbs` for actual loading and sending states. Metal mounts after hydration to avoid its WebGL fallback markup differing between the server and browser. Wrapped buttons use transparent chrome so the shader remains visible, with a 3px silver ring on a dark surface. The project story uses a stronger traveling beam.
- Projects with search and progressive reveal, individual project pages with guided three-step tours, certifications with dynamically derived issuer filters and native modal previews, searchable reviews, and contact.
- A mobile-friendly 3D stage with a clear Continue action, thinking orbs during assembly replay, and a project selector containing every GitHub project. Home previews link to complete archives with live collection counts; client reviews are browsable from home.
- Archives show six projects/certifications or four reviews initially. “Show more” expands each collection; searching and filtering reset the visible count. New content and new certificate issuers need no layout changes.
- Reduced-motion handling, an interactive fallback when WebGL is unavailable, keyboard navigation, and canvases paused outside the viewport or in a hidden tab.

## Content

The same GitHub source is used:

`https://raw.githubusercontent.com/aravindpunyamantula/portfolio-data/main/data.json`

Content is fetched from GitHub at build time, normalized, and sorted by the existing `order` fields. Missing or malformed fields use safe defaults. If the source is unavailable, the checked-in fallback data keeps the site functional. After editing the data repository, trigger a new Cloudflare Pages build. New projects, detail pages, SEO metadata, and sharing cards are generated together. GitHub's own CDN caching may add a delay after edits. No GitHub token is required. Project detail pages retain the raw GitHub README endpoint used by Flutter, with a `master` branch fallback. The README is presented as expandable source notes.

The repository count and current-year commit search retain the Flutter implementation's public GitHub endpoints and one-hour browser cache. Commit search covers indexed public commits, rather than all contributions.

Project covers for Cherries Cafe and Glamup Gifts include captured screenshots of the live sites. Other covers are typographic artwork unless `imageUrl` is supplied in the content source. To update a screenshot, replace the corresponding image in `public/projects`.

## Project stories

The hero builds its three steps from each project's existing description, screenshots, tags, and links. Named tools are matched only against that project's text; general portfolio skills are never assigned to individual projects. Missing screenshots use a labeled project introduction. Unspecified architecture, contributions, audiences, and results stay hidden.

For richer stories, optionally add this `story` object to a project in the existing GitHub data file. Fill in only facts you can document:

```json
{
  "story": {
    "audience": "Who this project serves",
    "contribution": "Your actual contribution",
    "outcome": "The documented result",
    "layers": [
      {
        "id": "interface",
        "title": "Interface",
        "description": "How the documented interface works",
        "technologies": ["An actual technology used here"]
      }
    ]
  }
}
```

Layer IDs can be `interface`, `logic`, or `data`. Unknown IDs, duplicate IDs, and layers without descriptions are ignored. Every field is optional. Only supplied layers are displayed and labeled beside the separated rings.

Replay starts the current story at Experience and scatters then assembles the rings; completion follows the renderer's settled callback, including the interactive SVG fallback. Selecting another project resets its story to step one.

## Branding and sharing

The portrait uses orientation-corrected WebP images: `public/hero.webp` (960 × 1280, 89 KB) and `public/hero-480.webp` (480 × 640, 30 KB). Responsive image selection keeps mobile downloads small.

The white italic serif A monogram on navy includes SVG, favicon, Apple touch, Android, and maskable icons. Regenerate them with `node scripts/generate-icons.mjs`.

Each page and project includes a title, description, canonical URL, Open Graph and Twitter metadata, and structured data. `/share/[slug].png` contains build-generated 1200 × 630 social cards; `/share/[slug]-story.png` contains downloadable 1080 × 1920 Instagram story cards. Native sharing depends on browser support. Instagram story uploads and link stickers are added by the visitor.

Set `NEXT_PUBLIC_SITE_URL` to your production origin before building if it differs from `https://aravindkumar.tech`. Social previews need the publicly deployed site.

## Contact

The same EmailJS REST endpoint, service, template, and public key as Flutter are used. The template parameters remain `name`, `email`, `message`, and `time`. Success appears only after a successful API response; errors retain entered text and offer direct email.

Optional `.env.local` overrides:

```dotenv
NEXT_PUBLIC_EMAILJS_SERVICE_ID=your_service_id
NEXT_PUBLIC_EMAILJS_TEMPLATE_ID=your_template_id
NEXT_PUBLIC_EMAILJS_PUBLIC_KEY=your_public_key
```

These values are public browser configuration. Never add an EmailJS private key to a `NEXT_PUBLIC_` variable. Your EmailJS account's origin allowlist must include the domain where you run the form.

## Verification

```sh
npm run typecheck
npm run build
npm audit
```

`npm run lint` currently runs TypeScript validation. No separate ESLint ruleset is installed.

## Cloudflare Pages deployment

Update the existing Pages project connected to this repository. Replace the Flutter build configuration:

| Setting                | Value                                  |
| ---------------------- | -------------------------------------- |
| Framework preset       | Next.js (Static HTML Export), if shown |
| Root directory         | `nextjs`                               |
| Build command          | `npm run build`                        |
| Build output directory | `out`                                  |
| Production branch      | `main`                                 |
| Build system version   | 3                                      |

Keep automatic deployments enabled. Pages installs dependencies using the committed package lock before building.

Add these environment variables for production and preview builds:

```dotenv
NODE_VERSION=22
NEXT_PUBLIC_SITE_URL=https://aravindkumar.tech
```

Use your actual production origin if the domain changes. It controls canonical URLs, sitemap entries, structured data, and social cards. Retain your existing custom domain. Clear the previous Flutter build cache once, save the new settings, and retry the latest deployment.

`npm run build` exports the complete site into `out/`, including every GitHub project route, social and Instagram PNGs, robots.txt, sitemap.xml, icons, and Pages cache headers. `npm start` serves that export locally. There is no server runtime or Pages Functions dependency; the contact form continues to call EmailJS directly from the browser.

To publish content edits from the separate `portfolio-data` repository, retry the latest Pages deployment or use a Pages deploy hook. Changes in that separate repository do not automatically trigger this repository's Git integration. Avoid putting deploy-hook URLs or Cloudflare API tokens in public code.

Official guide: [Next.js static export on Cloudflare Pages](https://developers.cloudflare.com/pages/framework-guides/nextjs/deploy-a-static-nextjs-site/).
