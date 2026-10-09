import type { Metadata, Viewport } from "next";
import localFont from "next/font/local";
import { getPortfolio } from "@/lib/portfolio";
import Shell from "@/components/workshop/Shell";
import "./globals.css";
import { SITE_URL, SITE_NAME, pageMetadata, pageInfo } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
const font = localFont({
  src: [
    { path: "../public/fonts/Poppins-Regular.ttf", weight: "400" },
    { path: "../public/fonts/Poppins-Medium.ttf", weight: "500" },
    { path: "../public/fonts/Poppins-SemiBold.ttf", weight: "600" },
    { path: "../public/fonts/Poppins-Bold.ttf", weight: "700" },
    { path: "../public/fonts/Poppins-ExtraBold.ttf", weight: "800" },
  ],
  variable: "--font-sans",
  display: "swap",
});
export const viewport: Viewport = {
  themeColor: "#f4f3ed",
  width: "device-width",
  initialScale: 1,
};
export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  ...pageMetadata("home"),
  title: { default: pageInfo.home.title, template: "%s | Aravind Kumar" },
  applicationName: "Aravind Kumar — Portfolio",
  authors: [{ name: "Aravind Kumar", url: SITE_URL }],
  creator: "Aravind Kumar",
  publisher: "Aravind Kumar",
  category: "technology",
  manifest: "/manifest.json",
  icons: {
    icon: [
      { url: "/favicon.svg?v=serif-a1", type: "image/svg+xml", sizes: "any" },
      {
        url: "/icons/icon-32.png?v=serif-a1",
        type: "image/png",
        sizes: "32x32",
      },
      {
        url: "/icons/icon-16.png?v=serif-a1",
        type: "image/png",
        sizes: "16x16",
      },
    ],
    shortcut: "/favicon.ico?v=serif-a1",
    apple: [
      {
        url: "/icons/apple-touch-icon.png?v=serif-a1",
        type: "image/png",
        sizes: "180x180",
      },
      {
        url: "/icons/icon-152.png?v=serif-a1",
        type: "image/png",
        sizes: "152x152",
      },
      {
        url: "/icons/icon-167.png?v=serif-a1",
        type: "image/png",
        sizes: "167x167",
      },
    ],
  },
  appleWebApp: { capable: true, title: "Aravind", statusBarStyle: "default" },
  formatDetection: { telephone: false },
};
export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const content = await getPortfolio();
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Person",
        "@id": `${SITE_URL}/#person`,
        name: content.hero.name,
        alternateName: content.hero.nameShort,
        url: SITE_URL,
        image: `${SITE_URL}/hero.webp`,
        jobTitle: content.hero.roles[0],
        description: content.hero.tagline,
        sameAs: [
          content.links.github,
          content.links.linkedin,
          content.links.instagram,
        ],
        knowsAbout: content.skillCategories.flatMap(
          (category) => category.skills,
        ),
        hasCredential: content.certificates.map((c) => ({
          "@type": "EducationalOccupationalCredential",
          name: c.title,
          credentialCategory: "Certification",
          recognizedBy: { "@type": "Organization", name: c.organisation },
          ...(c.link ? { url: c.link } : {}),
        })),
      },
      {
        "@type": "WebSite",
        "@id": `${SITE_URL}/#website`,
        url: SITE_URL,
        name: SITE_NAME,
        description: pageInfo.home.description,
        inLanguage: "en",
        publisher: { "@id": `${SITE_URL}/#person` },
      },
    ],
  };
  return (
    <html lang="en" className={font.variable}>
      <body>
        <noscript>
          <style>{`[style*="opacity:0"], [style*="opacity: 0"] { opacity: 1 !important; transform: none !important; }`}</style>
        </noscript>
        <StructuredData data={jsonLd} />
        <Shell links={content.links} tagline={content.hero.footerTagline}>
          {children}
        </Shell>
      </body>
    </html>
  );
}
