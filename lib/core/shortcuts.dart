import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeekForwardIntent extends Intent {}
class SeekBackwardIntent extends Intent {}
class VolumeUpIntent extends Intent {}
class VolumeDownIntent extends Intent {}
class PlayPauseIntent extends Intent {}

class PlayerShortcuts {
  static Map<ShortcutActivator, Intent> get shortcuts => {
    LogicalKeySet(LogicalKeyboardKey.arrowRight): SeekForwardIntent(),
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): SeekBackwardIntent(),
    LogicalKeySet(LogicalKeyboardKey.arrowUp): VolumeUpIntent(),
    LogicalKeySet(LogicalKeyboardKey.arrowDown): VolumeDownIntent(),
    LogicalKeySet(LogicalKeyboardKey.space): PlayPauseIntent(),
  };

  static Map<Type, Action<Intent>> actions({
    required VoidCallback onForward,
    required VoidCallback onBackward,
    required VoidCallback onVolumeUp,
    required VoidCallback onVolumeDown,
    required VoidCallback onPlayPause,
  }) => {
    SeekForwardIntent: CallbackAction<SeekForwardIntent>(onInvoke: (_) => onForward()),
    SeekBackwardIntent: CallbackAction<SeekBackwardIntent>(onInvoke: (_) => onBackward()),
    VolumeUpIntent: CallbackAction<VolumeUpIntent>(onInvoke: (_) => onVolumeUp()),
    VolumeDownIntent: CallbackAction<VolumeDownIntent>(onInvoke: (_) => onVolumeDown()),
    PlayPauseIntent: CallbackAction<PlayPauseIntent>(onInvoke: (_) => onPlayPause()),
  };
}
