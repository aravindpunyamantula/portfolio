# Aravind — The Digital Workshop

The portfolio is built with Next.js, Motion, Three.js, and Libraries.dev effects. The application lives in [`nextjs/`](nextjs/README.md); the original Flutter source remains for reference.

```sh
cd nextjs
npm ci
npm run dev
```

## Cloudflare Pages

Replace the existing Flutter build settings:

| Setting | Value |
| --- | --- |
| Root directory | `nextjs` |
| Build command | `npm run build` |
| Build output directory | `out` |
| Production branch | `main` |
| Build system version | 3 |

Set `NODE_VERSION=22` and `NEXT_PUBLIC_SITE_URL=https://aravindkumar.tech`. Keep automatic deployments enabled and your existing custom domain. Clear the old Flutter build cache once, save the settings, and retry the latest deployment.

The static export includes project pages, page and project SEO, social sharing cards, Instagram story images, favicons, and mobile icons. Contact uses the original EmailJS browser endpoint.

Content still comes from [portfolio-data](https://github.com/aravindpunyamantula/portfolio-data). Editing that separate repository requires a new Pages build to update the exported website. New projects, certificates, and reviews adapt to the existing layouts automatically on rebuild.

See the [application README](nextjs/README.md) for project stories, local verification, content configuration, and deployment details.
