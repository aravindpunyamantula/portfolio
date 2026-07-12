import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class GithubStats {
  final int repos;
  final int commits; // commits authored this year
  const GithubStats({required this.repos, required this.commits});
}

/// Live "proof of life" numbers for the hero chips. Cached in localStorage
/// for an hour (unauthenticated GitHub API allows 60 req/h, search 10/min);
/// returns null on any failure so the chips simply don't render.
Future<GithubStats?> fetchGithubStats(String username) async {
  const cacheKey = 'gh_stats_v2';
  try {
    final cached = web.window.localStorage.getItem(cacheKey);
    if (cached != null) {
      final map = jsonDecode(cached) as Map<String, dynamic>;
      final age = DateTime.now().millisecondsSinceEpoch - (map['t'] as num);
      if (age < 3600 * 1000 && map['u'] == username) {
        return GithubStats(
          repos: (map['repos'] as num).toInt(),
          commits: (map['commits'] as num).toInt(),
        );
      }
    }
  } catch (_) {}

  try {
    final headers = {'Accept': 'application/vnd.github+json'};
    final userRes = await http
        .get(Uri.parse('https://api.github.com/users/$username'),
            headers: headers)
        .timeout(const Duration(seconds: 8));
    if (userRes.statusCode != 200) return null;
    final user = jsonDecode(userRes.body) as Map<String, dynamic>;
    final repos = (user['public_repos'] as num?)?.toInt() ?? 0;

    // Commits authored this year across public repos (search index counts
    // default branches — close enough for a live activity chip).
    var commits = 0;
    final year = DateTime.now().year;
    final commitRes = await http
        .get(
            Uri.parse('https://api.github.com/search/commits'
                '?q=author:$username+author-date:>=$year-01-01&per_page=1'),
            headers: headers)
        .timeout(const Duration(seconds: 8));
    if (commitRes.statusCode == 200) {
      commits = ((jsonDecode(commitRes.body)
                  as Map<String, dynamic>)['total_count'] as num?)
              ?.toInt() ??
          0;
    }

    final stats = GithubStats(repos: repos, commits: commits);
    try {
      web.window.localStorage.setItem(
        cacheKey,
        jsonEncode({
          't': DateTime.now().millisecondsSinceEpoch,
          'u': username,
          'repos': stats.repos,
          'commits': stats.commits,
        }),
      );
    } catch (_) {}
    return stats;
  } catch (_) {
    return null;
  }
}
