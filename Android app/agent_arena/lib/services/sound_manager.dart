import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;

  bool get muted => _muted;
  set muted(bool v) => _muted = v;

  Future<void> play(String assetPath) async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

  Future<void> playBegin() => play('sounds/begin.mp3');
  Future<void> playFight() => play('sounds/fight.mp3');
  Future<void> playSarcasm() => play('sounds/sarcasm.mp3');
  Future<void> playVictory() => play('sounds/victory.mp3');
  Future<void> playDefeat() => play('sounds/defeat.mp3');
  Future<void> playSwordSwing() => play('sounds/sword_swing.mp3');

  void dispose() => _player.dispose();
}
