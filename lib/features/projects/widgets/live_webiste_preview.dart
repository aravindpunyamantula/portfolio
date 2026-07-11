import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
// package:web instead of dart:html — dart:html doesn't compile to wasm.
import 'package:web/web.dart' as web;

/// Live site preview that only mounts its iframe once the card scrolls
/// near the viewport — keeps initial page load light.
class LiveWebistePreview extends StatefulWidget {
  final String url;
  const LiveWebistePreview({super.key, required this.url});

  @override
  State<LiveWebistePreview> createState() => _LiveWebistePreviewState();
}

class _LiveWebistePreviewState extends State<LiveWebistePreview>
    with AutomaticKeepAliveClientMixin {
  static final Set<String> _registeredViews = {};

  bool _load = false;

  @override
  bool get wantKeepAlive => true;

  String get _viewId => 'iframe-${widget.url.hashCode}';

  void _registerView() {
    if (_registeredViews.contains(_viewId)) return;
    _registeredViews.add(_viewId);
    ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      final iframe = web.HTMLIFrameElement()
        ..src = widget.url
        ..allowFullscreen = true;
      iframe.setAttribute('loading', 'lazy');
      iframe.style
        ..border = 'none'
        ..width = '100%'
        ..height = '100%'
        // Don't let the embedded site swallow scroll/drag — the card's
        // "Live" button opens it for real interaction.
        ..pointerEvents = 'none';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key(_viewId),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.05 && !_load && mounted) {
          setState(() => _load = true);
        }
      },
      child: _load
          ? Builder(
              builder: (context) {
                _registerView();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: HtmlElementView(viewType: _viewId),
                );
              },
            )
          : const _PreviewPlaceholder(),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, color: Colors.white.withOpacity(0.2), size: 36),
          const SizedBox(height: 10),
          const Text(
            "Loading preview…",
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
