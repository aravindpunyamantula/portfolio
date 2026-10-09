import { ImageResponse } from "next/og";
import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { getPortfolio } from "@/lib/portfolio";
import { slugify } from "@/lib/slug";
import { pageInfo, type PageKey, SITE_URL, excerpt } from "@/lib/seo";
export const runtime = "nodejs";
export const dynamic = "force-static";
export const dynamicParams = false;
export async function generateStaticParams() {
  const content = await getPortfolio();
  const keys = [
    ...Object.keys(pageInfo),
    ...content.projects.map((project) => `project-${slugify(project.title)}`),
  ];
  return keys.flatMap((key) => [
    { slug: `${key}.png` },
    { slug: `${key}-story.png` },
  ]);
}
const fonts = Promise.all([
  readFile(join(process.cwd(), "public/fonts/Poppins-Regular.ttf")),
  readFile(join(process.cwd(), "public/fonts/Poppins-SemiBold.ttf")),
]);
export async function GET(
  _request: Request,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug: filename } = await params;
  const story = filename.endsWith("-story.png");
  const slug = filename.replace(story ? /-story\.png$/ : /\.png$/, "");
  const content = await getPortfolio();
  const project = slug.startsWith("project-")
    ? content.projects.find((p) => slugify(p.title) === slug.slice(8))
    : undefined;
  const page = Object.hasOwn(pageInfo, slug)
    ? pageInfo[slug as PageKey]
    : undefined;
  if (!page && !project) return new Response("Card not found", { status: 404 });
  const [regular, bold] = await fonts;
  const title =
    project?.title ?? (slug === "home" ? "Aravind Kumar" : page!.title);
  const description = excerpt(
    project?.description ?? page!.description,
    story ? 240 : 155,
  );
  const path = project ? `/projects/${slugify(project.title)}` : page!.path;
  const label = project
    ? project.liveUrl
      ? "LIVE PRODUCT / PROJECT SHOWCASE"
      : "OPEN SOURCE / PROJECT SHOWCASE"
    : page!.label;
  const projectName = project?.title.toLowerCase() ?? "";
  let image: string | null = null;
  const screenshot = projectName.includes("cherries")
    ? "cherries-social.png"
    : projectName.includes("glamup")
      ? "glamup-social.png"
      : null;
  if (screenshot) {
    try {
      image = `data:image/png;base64,${(await readFile(join(process.cwd(), "public/projects", screenshot))).toString("base64")}`;
    } catch {
      /* Abstract cover remains available. */
    }
  }
  const logo = `data:image/svg+xml;base64,${(await readFile(join(process.cwd(), "public/icons/monogram.svg"))).toString("base64")}`;
  const width = story ? 1080 : 1200,
    height = story ? 1920 : 630;
  return new ImageResponse(
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        width: "100%",
        height: "100%",
        background: "#f4f3ed",
        color: "#172334",
        fontFamily: "Poppins",
        padding: story ? "92px 80px" : "44px 56px",
        position: "relative",
      }}
    >
      <div
        style={{
          display: "flex",
          position: "absolute",
          right: story ? -220 : -140,
          top: story ? 550 : -180,
          width: story ? 900 : 680,
          height: story ? 900 : 680,
          border: "1px solid #cad3ea",
          borderRadius: "50%",
        }}
      />
      <div
        style={{
          display: "flex",
          position: "absolute",
          right: story ? -170 : -95,
          top: story ? 600 : -135,
          width: story ? 800 : 590,
          height: story ? 800 : 590,
          border: "1px solid #d3dbec",
          borderRadius: "50%",
        }}
      />
      <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
        <img
          src={logo}
          width={story ? 88 : 52}
          height={story ? 88 : 52}
          alt=""
        />
        <div style={{ display: "flex", flexDirection: "column" }}>
          <span style={{ fontSize: story ? 34 : 23, fontWeight: 600 }}>
            Aravind Kumar
          </span>
          <span
            style={{
              fontSize: story ? 19 : 12,
              color: "#617083",
              letterSpacing: 2,
            }}
          >
            THE DIGITAL WORKSHOP
          </span>
        </div>
        <span
          style={{
            marginLeft: "auto",
            fontSize: story ? 20 : 13,
            color: "#2454e6",
          }}
        >
          {project ? "SELECTED WORK" : "PORTFOLIO"}
        </span>
      </div>
      <div
        style={{
          display: "flex",
          flexDirection: story ? "column" : "row",
          flex: 1,
          gap: story ? 58 : 38,
          alignItems: story ? "stretch" : "center",
          justifyContent: story ? "center" : "space-between",
          marginTop: story ? 110 : 24,
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            width: story ? "100%" : image ? "50%" : "68%",
          }}
        >
          <span
            style={{
              display: "flex",
              fontSize: story ? 20 : 12,
              color: "#2454e6",
              letterSpacing: 2,
              marginBottom: story ? 30 : 18,
            }}
          >
            {label}
          </span>
          <div
            style={{
              display: "flex",
              fontSize: story
                ? title.length > 45
                  ? 67
                  : 88
                : title.length > 40
                  ? 47
                  : 63,
              fontWeight: 600,
              lineHeight: 1.12,
              letterSpacing: -3,
              overflowWrap: "break-word",
            }}
          >
            {title}
          </div>
          {!project && (
            <div
              style={{
                display: "flex",
                fontSize: story ? 42 : 28,
                color: "#2454e6",
                marginTop: story ? 30 : 18,
                lineHeight: 1.3,
              }}
            >
              {page!.headline}
            </div>
          )}
          <div
            style={{
              display: "flex",
              fontSize: story ? 28 : 18,
              color: "#617083",
              lineHeight: 1.6,
              marginTop: story ? 34 : 22,
            }}
          >
            {description}
          </div>
        </div>
        {image ? (
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              width: story ? "100%" : "47%",
              background: "#fff",
              border: "1px solid #d9dfeb",
              borderRadius: 12,
              overflow: "hidden",
              boxShadow: "0 22px 55px #17233422",
            }}
          >
            <div
              style={{
                display: "flex",
                padding: "14px 20px",
                background: "#e8edf7",
                fontSize: story ? 19 : 12,
                color: "#586883",
              }}
            >
              PRODUCT / INTERFACE
            </div>
            <img
              src={image}
              width={story ? 920 : 520}
              height={story ? 640 : 360}
              style={{ objectFit: "cover", objectPosition: "top" }}
              alt=""
            />
          </div>
        ) : (
          <div
            style={{
              display: "flex",
              position: story ? "relative" : "absolute",
              width: story ? 720 : 300,
              height: story ? 530 : 300,
              alignItems: "center",
              justifyContent: "center",
              right: story ? 0 : 45,
              alignSelf: "center",
            }}
          >
            <div
              style={{
                display: "flex",
                position: "absolute",
                width: "80%",
                height: "70%",
                border: "26px solid #2454e6",
                borderRadius: "50%",
                transform: "rotate(-32deg)",
              }}
            />
            <div
              style={{
                display: "flex",
                position: "absolute",
                width: "65%",
                height: "90%",
                border: "21px solid #a8bdf4",
                borderRadius: "50%",
                transform: "rotate(35deg)",
              }}
            />
            <div
              style={{
                display: "flex",
                width: story ? 110 : 60,
                height: story ? 110 : 60,
                background: "#172334",
                borderRadius: "50%",
              }}
            />
          </div>
        )}
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          borderTop: "1px solid #d3d9df",
          paddingTop: story ? 32 : 20,
          marginTop: story ? 75 : 22,
        }}
      >
        <span style={{ fontSize: story ? 23 : 15, color: "#617083" }}>
          Built by Aravind Kumar
        </span>
        <span style={{ fontSize: story ? 23 : 15, color: "#2454e6" }}>
          {SITE_URL.replace(/^https?:\/\//, "")}
          {story && project ? path : ""}
        </span>
      </div>
    </div>,
    {
      width,
      height,
      fonts: [
        { name: "Poppins", data: regular, weight: 400, style: "normal" },
        { name: "Poppins", data: bold, weight: 600, style: "normal" },
      ],
      headers: {
        "Cache-Control":
          "public, max-age=300, s-maxage=3600, stale-while-revalidate=86400",
      },
    },
  );
}
