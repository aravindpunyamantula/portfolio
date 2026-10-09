import { pageMetadata, webpageSchema, breadcrumbSchema } from "@/lib/seo";
import StructuredData from "@/components/workshop/StructuredData";
import { getPortfolio } from "@/lib/portfolio";
import PageHeading from "@/components/workshop/PageHeading";
import ReviewCollection from "@/components/workshop/Reviews";
import { ArrowUpRight } from "lucide-react";
import Link from "next/link";
export const metadata = pageMetadata("reviews");
export default async function Reviews() {
  const { reviews } = await getPortfolio();
  return (
    <div className="archive-page">
      <StructuredData
        data={[
          webpageSchema("reviews"),
          breadcrumbSchema([
            { name: "Home", path: "/" },
            { name: "Reviews", path: "/reviews" },
          ]),
        ]}
      />
      <PageHeading
        index="03"
        title="Client reviews"
        accent="real experiences"
        description="The best part of building is the people you build with. A few words from the other side of the table."
      />
      <ReviewCollection reviews={reviews} />
      <div className="archive-end">
        <span className="mono">LET'S MAKE SOMETHING WORTH TALKING ABOUT.</span>
        <Link href="/contact">
          Start a conversation <ArrowUpRight size={22} />
        </Link>
      </div>
    </div>
  );
}
