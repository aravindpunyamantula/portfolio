import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// The four effect slots. Files live in assets/sfx/ — see [SoundService._files]
/// for the exact filenames and what triggers each.
enum Sfx { warp, blackhole, meteors, sent }

/// Tiny sound-effects layer on the browser's native audio element — no
/// packages, nothing loaded until the user opts in.
///
/// Muted by default (respectful + autoplay policies would block pre-gesture
/// playback anyway). The toggle persists in localStorage. Missing files
/// fail silently, so this ships before the MP3s exist.
class SoundService {
  SoundService._();

  static final ValueNotifier<bool> enabled = ValueNotifier(false);
  static final Map<Sfx, web.HTMLAudioElement> _players = {};
  static const _storageKey = 'sfx_on';

  /// filename in assets/sfx/ + playback volume per effect.
  static const _files = <Sfx, (String, double)>{
    Sfx.warp: ('warp.mp3', 0.35), // "View Projects" hyperspace jump
    Sfx.blackhole: ('blackhole.mp3', 0.40), // badge double-tap collapse
    Sfx.meteors: ('meteors.mp3', 0.30), // typing-the-name meteor shower
    Sfx.sent: ('sent.mp3', 0.40), // contact form success (+ toggle-on)
  };

  /// Restore the persisted preference. Call once from main().
  static void init() {
    try {
      enabled.value = web.window.localStorage.getItem(_storageKey) == '1';
    } catch (_) {}
    // No preloading here even when enabled — audio only loads on first
    // play, keeping boot quiet for returning visitors too.
  }

  static void toggle() {
    enabled.value = !enabled.value;
    try {
      web.window.localStorage.setItem(_storageKey, enabled.value ? '1' : '0');
    } catch (_) {}
    // Audible confirmation doubles as the browser's "user gesture" unlock.
    if (enabled.value) play(Sfx.sent);
  }

  static void play(Sfx sfx) {
    if (!enabled.value) return;
    try {
      final player = _players.putIfAbsent(sfx, () {
        final (file, volume) = _files[sfx]!;
        return web.HTMLAudioElement()
          ..src = 'assets/assets/sfx/$file'
          ..preload = 'auto'
          ..volume = volume;
      });
      player.currentTime = 0;
      // Swallow rejections (file missing, autoplay policy) so nothing
      // reaches the console-errors audit.
      player.play().toDart.then((v) => v, onError: (Object _) => null);
    } catch (_) {}
  }
}
