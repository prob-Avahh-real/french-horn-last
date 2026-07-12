import 'dart:typed_data';
import 'dart:math';

/// Simple PCM synthesizer for "沙雕" game music.
/// Generates sine/triangle waves with ADSR envelope.
class PcmSynth {
  final int sampleRate;
  final List<_ActiveVoice> _voices = [];

  PcmSynth({this.sampleRate = 44100});

  /// Start a note.
  void noteOn(int midiNote, {double velocity = 1.0}) {
    // Stop any existing voice with the same note
    noteOff(midiNote);
    _voices.add(_ActiveVoice(
      frequency: _midiToFreq(midiNote),
      velocity: velocity.clamp(0.0, 1.0),
      sampleRate: sampleRate,
    ));
  }

  /// Stop a note.
  void noteOff(int midiNote) {
    final freq = _midiToFreq(midiNote);
    for (final v in _voices) {
      if ((v.frequency - freq).abs() < 0.5) {
        v.release();
      }
    }
  }

  /// Stop all notes.
  void allNotesOff() {
    for (final v in _voices) { v.release(); }
  }

  /// Generate the next buffer of samples.
  /// Returns a [Float32List] of length [frameCount] * 2 (stereo interleaved).
  Float32List generate(int frameCount) {
    final buf = Float32List(frameCount * 2);

    for (var i = 0; i < frameCount; i++) {
      var left = 0.0;
      var right = 0.0;

      for (final v in _voices) {
        final sample = v.nextSample();
        left += sample * v.velocity * v.getAmplitude();
        right += sample * v.velocity * v.getAmplitude();
      }

      buf[i * 2] = left.clamp(-1.0, 1.0).toDouble();
      buf[i * 2 + 1] = right.clamp(-1.0, 1.0).toDouble();
    }

    // Remove released voices
    _voices.removeWhere((v) => v.isDone);

    return buf;
  }
}

/// Convert MIDI note number to frequency.
double _midiToFreq(int note) => 440.0 * pow(2.0, (note - 69) / 12.0);

/// An active voice (note being played).
class _ActiveVoice {
  final double frequency;
  final double velocity;
  final int sampleRate;
  double _phase = 0;
  double _time = 0; // in samples

  // ADSR envelope
  static const _attackSamples = 882;   // 20ms
  static const _decaySamples = 2205;   // 50ms
  static const _sustainLevel = 0.7;
  static const _releaseSamples = 4410; // 100ms

  bool _releasing = false;
  double _releaseStartAmp = 1.0;
  double _releaseStartTime = 0;

  _ActiveVoice({
    required this.frequency,
    required this.velocity,
    required this.sampleRate,
  });

  void release() {
    if (!_releasing) {
      _releasing = true;
      _releaseStartAmp = getAmplitude();
      _releaseStartTime = _time;
    }
  }

  bool get isDone => _releasing && getAmplitude() <= 0.001;

  /// Get the ADSR amplitude at the current time.
  double getAmplitude() {
    if (_releasing) {
      final relTime = _time - _releaseStartTime;
      final relAmp = 1.0 - (relTime / _releaseSamples).clamp(0.0, 1.0);
      return _releaseStartAmp * relAmp;
    }

    if (_time < _attackSamples) {
      return (_time / _attackSamples).clamp(0.0, 1.0);
    }
    if (_time < _attackSamples + _decaySamples) {
      final decayFrac = (_time - _attackSamples) / _decaySamples;
      return 1.0 - (1.0 - _sustainLevel) * decayFrac;
    }
    return _sustainLevel;
  }

  /// Generate the next sample (waveform only, no envelope).
  double nextSample() {
    final phaseIncrement = frequency / sampleRate;
    _phase += phaseIncrement;
    if (_phase >= 1.0) _phase -= 1.0;
    _time++;

    // Triangle wave — softer and more "toy instrument" sound
    final raw = _phase < 0.5 ? _phase * 4 - 1 : 3 - _phase * 4;
    return raw;
  }
}
