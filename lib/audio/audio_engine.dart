/// Abstract interface for the game's audio engine.
/// Implementations will use FluidSynth or platform-native MIDI synth
/// via FFI or platform channels.
abstract class AudioEngine {
  /// Initialize the audio engine.
  Future<void> init();

  /// Load a SoundFont (.sf2) file.
  Future<void> loadSoundFont(String path);

  /// Set the instrument (GM program number, 0-127).
  void setInstrument(int gmProgram);

  /// Play a MIDI note with optional pitch bend.
  /// [noteNumber] MIDI note number (0-127, 60 = C4).
  /// [velocity] Note velocity (0-127, default 100).
  void noteOn(int noteNumber, {int velocity = 100});

  /// Release a MIDI note.
  void noteOff(int noteNumber);

  /// Apply pitch bend offset.
  /// [semitoneOffset] offset in semitones (-12.0 to +12.0 typically).
  void pitchBend(double semitoneOffset);

  /// Start playback of the background accompaniment track.
  void startAccompaniment();

  /// Stop all sounds.
  void allNotesOff();

  /// Release resources.
  void dispose();
}

/// Audio engine configuration.
class AudioConfig {
  final int sampleRate;
  final int bufferSize;
  final double masterVolume;

  const AudioConfig({
    this.sampleRate = 44100,
    this.bufferSize = 512,
    this.masterVolume = 0.8,
  });
}
