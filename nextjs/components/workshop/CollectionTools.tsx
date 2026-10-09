"use client";
import { Search, Plus } from "lucide-react";
export function CollectionSearch({
  value,
  onChange,
  noun,
}: {
  value: string;
  onChange: (value: string) => void;
  noun: string;
}) {
  return (
    <label className="search-box">
      <Search size={18} />
      <input
        type="search"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={`Search ${noun}…`}
        aria-label={`Search ${noun}`}
      />
    </label>
  );
}
export function CollectionFooter({
  total,
  visible,
  noun,
  onMore,
}: {
  total: number;
  visible: number;
  noun: string;
  onMore: () => void;
}) {
  if (!total) return null;
  return (
    <div className="collection-footer">
      <p role="status">
        Showing {Math.min(visible, total)} of {total} {noun}
      </p>
      {visible < total && (
        <button className="button button-outline" onClick={onMore}>
          <Plus size={18} />
          Show more {noun}
        </button>
      )}
    </div>
  );
}
