import 'dart:async';
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

  // ── background music (assets/sfx/ambient.mp3, loops at low volume) ──
  static web.HTMLAudioElement? _music;
  static Timer? _fade;
  static const _musicVolume = 0.12;

  /// Restore the persisted preference. Call once from main().
  static void init() {
    try {
      enabled.value = web.window.localStorage.getItem(_storageKey) == '1';
    } catch (_) {}
    // No preloading here even when enabled — audio only loads on first
    // play, keeping boot quiet for returning visitors too.
    try {
      // For returning visitors with sound on: the first real gesture
      // (pointer/touch) grants the autoplay permission music needs.
      web.document.addEventListener(
        'pointerdown',
        ((web.Event e) {
          if (enabled.value) _startMusic();
        }).toJS,
      );
      // Don't keep playing in a background tab.
      web.document.addEventListener(
        'visibilitychange',
        ((web.Event e) {
          if (web.document.hidden) {
            _music?.pause();
          } else if (enabled.value && _music != null) {
            _music!.play().toDart.then((v) => v, onError: (Object _) => null);
          }
        }).toJS,
      );
    } catch (_) {}
  }

  static void toggle() {
    enabled.value = !enabled.value;
    try {
      web.window.localStorage.setItem(_storageKey, enabled.value ? '1' : '0');
    } catch (_) {}
    if (enabled.value) {
      // Audible confirmation doubles as the browser's gesture unlock.
      play(Sfx.sent);
      _startMusic();
    } else {
      _stopMusic();
    }
  }

  /// Warm ambient loop, faded in over ~2.5s. Missing file fails silently.
  static void _startMusic() {
    try {
      _music ??= web.HTMLAudioElement()
        ..src = 'assets/assets/sfx/ambient.mp3'
        ..loop = true
        ..preload = 'auto';
      if (!_music!.paused) return;
      _music!.volume = 0;
      _music!.play().toDart.then((v) => v, onError: (Object _) => null);
      _fade?.cancel();
      _fade = Timer.periodic(const Duration(milliseconds: 100), (t) {
        final v = _music!.volume + _musicVolume / 25;
        if (v >= _musicVolume) {
          _music!.volume = _musicVolume;
          t.cancel();
        } else {
          _music!.volume = v;
        }
      });
    } catch (_) {}
  }

  static void _stopMusic() {
    _fade?.cancel();
    try {
      _music?.pause();
    } catch (_) {}
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
