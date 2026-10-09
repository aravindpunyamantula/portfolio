import { pageMetadata, webpageSchema, breadcrumbSchema } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import { getPortfolio } from "@/lib/portfolio";
import Workshop from "@/components/workshop/Workshop";
export const metadata = pageMetadata("home");
export default async function Home() {
  return (
    <>
      <StructuredData data={webpageSchema("home")} />
      <Workshop content={await getPortfolio()} />
    </>
  );
}
