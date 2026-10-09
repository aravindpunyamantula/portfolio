import { pageMetadata, webpageSchema, breadcrumbSchema } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import { getPortfolio } from "@/lib/portfolio";
import PageHeading from "@/components/workshop/PageHeading";
import Certificates from "@/components/workshop/Certificates";
export const metadata = pageMetadata("certifications");
export default async function Certifications() {
  const content = await getPortfolio();
  return (
    <div className="archive-page">
      <StructuredData
        data={[
          webpageSchema("certifications"),
          breadcrumbSchema([
            { name: "Home", path: "/" },
            { name: "Certifications", path: "/certifications" },
          ]),
        ]}
      />
      <PageHeading
        index="03"
        title="Certifications"
        accent="always learning"
        description={content.sections.certificates.subtitle}
      />
      <div className="archive-rule mono">
        <span>
          {String(content.certificates.length).padStart(2, "0")} CREDENTIALS /
          AND COUNTING
        </span>
        <span>CURIOSITY IS A PRACTICE.</span>
      </div>
      <Certificates certificates={content.certificates} />
    </div>
  );
}
