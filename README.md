# Aravind's World

Personal Portfolio built using Flutter.

## Features

- Mainly built for web, but also supports mobile and desktop.
- Responsive design.
- Smooth animations and transitions.
- Showcases projects, skills, and contact information.
- Easy to navigate and visually appealing.
- Fully glassmorphic design.

## Technologies Used

- Flutter: For building the user interface and handling animations.
- State Management: Provider for managing state across the application.
- Responsive Design: MediaQuery and LayoutBuilder for creating a responsive layout.
- Animations: flutter_animate package for creating smooth animations and transitions.
- Glassmorphism: Custom glassmorphic widgets for a modern and stylish design.

## Main Sections

1. **Home/Intro Page**: A visually appealing introduction with animations and a brief overview of who I am.
2. **About**: A detailed overview of my background, skills, and experience.
3. **Projects**: A showcase of my projects with descriptions, technologies, and links to repositories or live demos.
4. **Skills**: A section highlighting my technical skills and proficiencies.
5. **Certificates**: A display of my certifications and achievements in the field.
6. **Reviews**: Testimonials and feedback from colleagues, clients, or mentors.
7. **Contact**: A simple way to get in touch with me, including email, social media links, and a contact form.

## Project Structure
.
├── core
│   ├── constants
│   │   ├── app_colors.dart
│   │   └── app_spacing.dart
│   ├── theme
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils
│       └── resposive.dart
├── data
│   ├── models
│   └── services
│       ├── email_service.dart
│       └── urls_launcher_service.dart
├── features
│   ├── certificates
│   ├── contacts
│   ├── home
│   │   ├── home_page.dart
│   │   ├── intro_page.dart
│   │   └── widgets
│   │       └── skill_card.dart
│   ├── projects
│   │   └── widgets
│   │       └── project_card.dart
│   └── reviews
│       └── widgets
│           └── review_card.dart
├── main.dart
└── widgets
    ├── common
    │   └── section_container.dart
    └── glass
        ├── glass_button.dart
        ├── glass_card.dart
        ├── glass_container.dart
        └── glass_nav_bar.dart

## 07 APRIL 2026:
- Updated the intro page animation timings for a smoother experience.
- Added GlassNavBar widget to the project for a consistent navigation experience across the app.


## Build & Deploy

```bash
flutter build web --release --wasm
```

Output lands in `build/web/`. The `--wasm` flag compiles to WebAssembly
(skwasm renderer) with an automatic JavaScript fallback for older browsers —
modern browsers get a much faster startup. Icon fonts are tree-shaken,
Poppins is bundled locally and subsetted to Latin (~14 KB per weight), and
`flutter_markdown` is split into a deferred chunk that only loads when a
GitHub README preview scrolls into view.

### Hosting (recommended: Cloudflare Pages)

1. Push the repo to GitHub.
2. In Cloudflare Pages: **Create project → connect repo**.
   - Build command: `flutter build web --release --wasm`
     (or build locally and use **Direct Upload** of `build/web/`).
   - Output directory: `build/web`.
3. Done — Brotli compression, HTTP/3, and the CDN are automatic.

`web/_headers` is copied into `build/web/` at build time and configures
caching (Cloudflare Pages and Netlify read it natively):

- `index.html`, `flutter_bootstrap.js`, service worker, `version.json` →
  `no-cache`, so every visit picks up new deploys.
- `main.dart.*`, `assets/`, `canvaskit/` → cached for 1 year (`immutable`).
  Safe because Flutter's service worker re-fetches changed files with
  `cache: reload` after each deploy.

**Vercel:** same idea, but headers go in a `vercel.json` instead of
`_headers`. **Firebase Hosting:** use the `headers` array in
`firebase.json`. **GitHub Pages:** works, but you can't set cache headers —
expect a lower Lighthouse performance score there.

Deliberately **not** set: `Cross-Origin-Opener-Policy` /
`Cross-Origin-Embedder-Policy`. They would enable multi-threaded wasm but
break the live-site iframe previews and externally hosted certificate
images. Single-threaded skwasm runs fine without them (verified).

### Measuring performance

Test the **deployed URL** (never localhost — compression and CDN account
for half the score) with [PageSpeed Insights](https://pagespeed.web.dev).
First HTML paint is a real hero rendered in CSS (`web/index.html`), so
FCP/LCP fire long before the Flutter engine finishes booting.

### Fonts

`assets/fonts/*.ttf` are subsetted (Latin + `© · — …`). If you ever add
text in another script (e.g. Telugu), re-download the full files from
[google/fonts](https://github.com/google/fonts/tree/main/ofl/poppins) and
re-subset with `pyftsubset`.

Before going live, replace the placeholder domain `aravindkumar.dev` with
your real domain in `web/index.html`, `web/robots.txt`, and `web/sitemap.xml`.
