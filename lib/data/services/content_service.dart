import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:portfolio/data/models/portfolio_content.dart';
import 'package:web/web.dart' as web;

/// Loads editable site content from the public `portfolio-data` repo —
/// GitHub acts as the CMS, no backend involved.
///
/// Load order (stale-while-revalidate):
///   1. compiled-in fallback (instant, always valid)
///   2. last successful fetch from localStorage (instant on repeat visits)
///   3. fresh data.json from GitHub raw (updates ~1–5 min after a commit)
class ContentService extends ChangeNotifier {
  static const _remoteUrl =
      'https://raw.githubusercontent.com/aravindpunyamantula/portfolio-data/main/data.json';
  static const _cacheKey = 'portfolio_data_v1';

  PortfolioContent content = PortfolioContent.fallback();

  Future<void> load() async {
    _applyCached();
    await _fetchRemote();
  }

  void _applyCached() {
    try {
      final cached = web.window.localStorage.getItem(_cacheKey);
      if (cached != null) _apply(cached);
    } catch (_) {
      // Corrupt cache or storage disabled — fallback content stands.
    }
  }

  Future<void> _fetchRemote() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return;
      _apply(response.body);
      web.window.localStorage.setItem(_cacheKey, response.body);
    } catch (_) {
      // Offline or repo unreachable — cached/fallback content stands.
    }
  }

  void _apply(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;
    content = PortfolioContent.fromJson(decoded);
    notifyListeners();
  }
}
