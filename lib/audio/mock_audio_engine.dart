import 'audio_engine.dart';

/// Mock audio engine for development and testing.
/// Logs events instead of producing real audio.
class MockAudioEngine implements AudioEngine {
  int _currentNote = -1;

  @override
  Future<void> init() async {
    print('[Audio] Engine initialized');
  }

  @override
  Future<void> loadSoundFont(String path) async {
    print('[Audio] Loading SoundFont: $path');
  }

  @override
  void setInstrument(int gmProgram) {
    print('[Audio] Set instrument: GM#$gmProgram');
  }

  @override
  void noteOn(int noteNumber, {int velocity = 100}) {
    if (_currentNote == noteNumber) return;
    if (_currentNote >= 0) noteOff(_currentNote);
    _currentNote = noteNumber;
    print('[Audio] Note ON: $noteNumber (vel=$velocity)');
  }

  @override
  void noteOff(int noteNumber) {
    _currentNote = -1;
    print('[Audio] Note OFF: $noteNumber');
  }

  @override
  void pitchBend(double semitoneOffset) {
    // In mock mode, just track it silently
  }

  @override
  void startAccompaniment() {
    print('[Audio] Accompaniment started');
  }

  @override
  void allNotesOff() {
    _currentNote = -1;
    print('[Audio] All notes off');
  }

  @override
  void dispose() {
    _currentNote = -1;
    print('[Audio] Engine disposed');
  }
}
