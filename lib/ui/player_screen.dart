import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/player_engine.dart';
import '../../core/shortcuts.dart';
import 'widgets/side_arrows.dart';
import 'widgets/speed_control.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerEngine _engine = PlayerEngine();
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() => _controlsVisible = true);
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      _engine.open(result.files.single.path!);
      _engine.play();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (_) => _resetControlsTimer(),
        child: Shortcuts(
          shortcuts: PlayerShortcuts.shortcuts,
          child: Actions(
            actions: PlayerShortcuts.actions(
              onForward: () => _engine.forward(const Duration(seconds: 10)),
              onBackward: () => _engine.backward(const Duration(seconds: 10)),
              onVolumeUp: () => _engine.setVolume(_engine.player.state.volume + 5),
              onVolumeDown: () => _engine.setVolume(_engine.player.state.volume - 5),
              onPlayPause: () => _engine.playOrPause(),
            ),
            child: Focus(
              autofocus: true,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Layer
                  Video(controller: _engine.controller),

                  // Overlay Gradient
                  AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pick video button (Top left)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _controlsVisible ? 24 : -60,
                    left: 24,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.file_open),
                      label: const Text('Open File', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Speed control (Top right)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _controlsVisible ? 24 : -60,
                    right: 24,
                    child: SpeedControl(
                      currentSpeed: _currentSpeed,
                      onSpeedChanged: (speed) {
                        setState(() => _currentSpeed = speed);
                        _engine.setRate(speed);
                      },
                    ),
                  ),

                  // Navigation Arrows
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SideArrows(
                        visible: _controlsVisible,
                        onLeft: () => _engine.backward(const Duration(seconds: 10)),
                        onRight: () => _engine.forward(const Duration(seconds: 10)),
                      ),
                    ),
                  ),

                  // Bottom Controls (Placeholder)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: _controlsVisible ? 24 : -60,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: StreamBuilder(
                            stream: _engine.player.stream.playing,
                            builder: (context, snapshot) {
                              return Icon(
                                (snapshot.data ?? false) ? Icons.pause : Icons.play_arrow,
                                size: 48,
                                color: Colors.white,
                              );
                            },
                          ),
                          onPressed: () => _engine.playOrPause(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
