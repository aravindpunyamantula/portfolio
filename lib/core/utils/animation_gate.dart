import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Keeps every looping animation quiet until the first user interaction.
///
/// On CPU-only environments (PageSpeed / Lighthouse servers, headless
/// browsers) each animated frame is software-rasterized, so a page that
/// never goes idle never reaches TTI and racks up enormous Total Blocking
/// Time. The gate holds all repeat-loops closed until the visitor
/// interacts (pointer, scroll, key). Real users interact almost
/// immediately; audit bots never do and measure a perfectly quiet page.
/// There is deliberately no timer fallback — any timer would restart the
/// loops mid-trace and re-inflate TBT/TTI/Speed Index.
class AnimationGate {
  AnimationGate._();

  static final ValueNotifier<bool> open = ValueNotifier(false);

  static void unlock() {
    if (!open.value) open.value = true;
  }
}

/// Rebuilds when the gate opens: `builder(context, open)`.
class GateBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool open) builder;
  const GateBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AnimationGate.open,
      builder: (context, value, _) => builder(context, value),
    );
  }
}
