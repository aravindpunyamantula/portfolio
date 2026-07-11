import 'package:flutter/material.dart';
// Deferred: flutter_markdown is only needed once a GitHub-preview card
// scrolls into view, so dart2js splits it out of the main bundle.
import 'package:flutter_markdown/flutter_markdown.dart' deferred as md;
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

/// Renders a repo's README — fetched only when the card scrolls into view.
class GithubReadmePreview extends StatefulWidget {
  final String repoUrl;
  const GithubReadmePreview({super.key, required this.repoUrl});

  @override
  State<GithubReadmePreview> createState() => _GithubReadmePreviewState();
}

class _GithubReadmePreviewState extends State<GithubReadmePreview>
    with AutomaticKeepAliveClientMixin {
  static Future<void>? _markdownLib;

  String markdown = '';
  bool isLoading = true;
  bool started = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> loadReadme() async {
    try {
      final rawUrl = convertGithubToRaw(widget.repoUrl);
      final results = await Future.wait([
        http.get(Uri.parse(rawUrl)),
        _markdownLib ??= md.loadLibrary(),
      ]);
      if (!mounted) return;
      final response = results[0] as http.Response;
      setState(() {
        markdown =
            response.statusCode == 200 ? response.body : 'README not found';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        markdown = 'Error loading README';
        isLoading = false;
      });
    }
  }

  String convertGithubToRaw(String githubUrl) {
    final cleaned = githubUrl.replaceAll('https://github.com/', '');
    return 'https://raw.githubusercontent.com/$cleaned/main/README.md';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key('readme-${widget.repoUrl}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.05 && !started && mounted) {
          started = true;
          loadReadme();
        }
      },
      child: !started || isLoading
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : md.Markdown(
              data: markdown,
              padding: const EdgeInsets.all(16),
              styleSheet: md.MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white70, fontSize: 13),
                h1: const TextStyle(color: Colors.white),
                h2: const TextStyle(color: Colors.white),
                h3: const TextStyle(color: Colors.white),
                code: const TextStyle(
                  color: Color(0xFFB8BCFF),
                  backgroundColor: Colors.transparent,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }
}
