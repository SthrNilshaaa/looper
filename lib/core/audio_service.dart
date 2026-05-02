import 'package:media_kit/media_kit.dart';

class AudioService {
  late final Player player;

  AudioService() {
    player = Player(configuration: const PlayerConfiguration(title: 'OnePlayer'));
  }

  Future<void> play(String path, {Map<String, String>? metadata}) async {
    await player.open(Media(path, extras: metadata));
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    await player.play();
  }

  Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }

  Future<void> stop() async {
    await player.stop();
  }

  void dispose() {
    player.dispose();
  }
}
