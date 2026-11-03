import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerEngine {
  late final Player player;
  late final VideoController controller;

  PlayerEngine() {
    player = Player();
    controller = VideoController(player);
  }

  void open(String path) {
    player.open(Media(path));
  }

  void play() {
    player.play();
  }

  void pause() {
    player.pause();
  }

  void playOrPause() {
    player.playOrPause();
  }

  void setVolume(double volume) {
    player.setVolume(volume.clamp(0.0, 100.0));
  }

  void setRate(double rate) {
    player.setRate(rate.clamp(0.25, 4.0));
  }

  void seek(Duration duration) {
    player.seek(duration);
  }

  void forward(Duration duration) {
    player.seek(player.state.position + duration);
  }

  void backward(Duration duration) {
    player.seek(player.state.position - duration);
  }

  void dispose() {
    player.dispose();
  }
}
