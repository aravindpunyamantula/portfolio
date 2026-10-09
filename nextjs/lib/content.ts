"use client";
import { useState, useEffect } from "react";
import type { GithubStats } from "./types";
const GH_CACHE_KEY = "gh_stats_v2";

export function useGithubStats(username: string = "aravindpunyamantula") {
  const [stats, setStats] = useState<GithubStats | null>(null);

  useEffect(() => {
    const loadStats = async () => {
      try {
        const cached = localStorage.getItem(GH_CACHE_KEY);
        if (cached) {
          const parsed = JSON.parse(cached);
          const age = Date.now() - (parsed.t || 0);
          if (age < 3600 * 1000 && parsed.u === username) {
            setStats({ repos: parsed.repos, commits: parsed.commits });
            return;
          }
        }
      } catch {
        // Continue
      }

      try {
        const userRes = await fetch(
          `https://api.github.com/users/${username}`,
          {
            headers: { Accept: "application/vnd.github+json" },
          },
        );
        if (!userRes.ok) return;
        const user = await userRes.json();
        const repos = user.public_repos || 0;

        let commits = 0;
        const currentYear = new Date().getFullYear();
        try {
          const commitRes = await fetch(
            `https://api.github.com/search/commits?q=author:${username}+author-date:>=${currentYear}-01-01&per_page=1`,
            { headers: { Accept: "application/vnd.github+json" } },
          );
          if (commitRes.ok) {
            const commitData = await commitRes.json();
            commits = commitData.total_count || 0;
          }
        } catch {
          // Commit search rate limits
        }

        const newStats = { repos, commits };
        setStats(newStats);
        try {
          localStorage.setItem(
            GH_CACHE_KEY,
            JSON.stringify({
              t: Date.now(),
              u: username,
              repos,
              commits,
            }),
          );
        } catch {
          // Ignore storage
        }
      } catch {
        // Ignore errors
      }
    };

    loadStats();
  }, [username]);

  return stats;
}
