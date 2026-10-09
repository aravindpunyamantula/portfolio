import { pageMetadata, webpageSchema, breadcrumbSchema } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import { getPortfolio } from "@/lib/portfolio";
import Contact from "@/components/workshop/Contact";
export const metadata = pageMetadata("contact");
export default async function ContactPage() {
  const { links } = await getPortfolio();
  return (
    <div className="contact-page">
      <StructuredData
        data={[
          webpageSchema("contact"),
          breadcrumbSchema([
            { name: "Home", path: "/" },
            { name: "Contact", path: "/contact" },
          ]),
        ]}
      />
      <Contact links={links} />
    </div>
  );
}
