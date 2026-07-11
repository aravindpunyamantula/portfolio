import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class GithubStats {
  final int repos;
  final int stars;
  const GithubStats({required this.repos, required this.stars});
}

/// Live "proof of life" numbers for the hero chips. Cached in localStorage
/// for an hour (unauthenticated GitHub API allows 60 req/h); returns null
/// on any failure so the chips simply don't render.
Future<GithubStats?> fetchGithubStats(String username) async {
  const cacheKey = 'gh_stats_v1';
  try {
    final cached = web.window.localStorage.getItem(cacheKey);
    if (cached != null) {
      final map = jsonDecode(cached) as Map<String, dynamic>;
      final age = DateTime.now().millisecondsSinceEpoch - (map['t'] as num);
      if (age < 3600 * 1000 && map['u'] == username) {
        return GithubStats(
          repos: (map['repos'] as num).toInt(),
          stars: (map['stars'] as num).toInt(),
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

    var stars = 0;
    final repoRes = await http
        .get(
            Uri.parse(
                'https://api.github.com/users/$username/repos?per_page=100'),
            headers: headers)
        .timeout(const Duration(seconds: 8));
    if (repoRes.statusCode == 200) {
      for (final r in jsonDecode(repoRes.body) as List) {
        stars += ((r as Map)['stargazers_count'] as num?)?.toInt() ?? 0;
      }
    }

    final stats = GithubStats(repos: repos, stars: stars);
    try {
      web.window.localStorage.setItem(
        cacheKey,
        jsonEncode({
          't': DateTime.now().millisecondsSinceEpoch,
          'u': username,
          'repos': stats.repos,
          'stars': stats.stars,
        }),
      );
    } catch (_) {}
    return stats;
  } catch (_) {
    return null;
  }
}
