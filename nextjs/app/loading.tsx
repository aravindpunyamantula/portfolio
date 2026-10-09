import { Orb } from "@/components/workshop/Effects";
export default function Loading() {
  return (
    <div className="route-loading">
      <Orb label="Loading the page…" size={64} />
    </div>
  );
}
