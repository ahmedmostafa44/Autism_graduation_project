import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();

  factory AudioService() => instance;

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccessSound() async {
    try {
      await _player.play(AssetSource('sounds/WiningSound.wav'));
    } catch (e) {
      // Ignore if sound fails
    }
  }

  Future<void> playFailureSound() async {
    try {
      await _player.play(AssetSource('sounds/LosingSound.wav'));
    } catch (e) {
      // Ignore if sound fails
    }
  }

  void dispose() {
    _player.dispose();
  }
}
