import '../data/instruments.dart';

/// Handles touch input and converts it to pitch data.
class InputHandler {
  /// Current normalized Y position (0.0 = bottom, 1.0 = top)
  double _normalizedY = 0.5;

  /// Whether the player is currently touching the screen
  bool _isTouching = false;

  /// Current computed MIDI pitch
  double _currentMidiNote = 69.0; // A4

  /// The active instrument (affects pitch range)
  Instrument _instrument = panFlute;

  /// Whether input is locked (e.g., between songs)
  bool _locked = false;

  // Getters
  double get normalizedY => _normalizedY;
  bool get isTouching => _isTouching;
  double get currentMidiNote => _currentMidiNote;
  Instrument get instrument => _instrument;

  /// Set the active instrument.
  void setInstrument(Instrument inst) {
    _instrument = inst;
    _updatePitch();
  }

  /// Lock/unlock input.
  void setLocked(bool locked) {
    _locked = locked;
    if (locked) {
      _isTouching = false;
    }
  }

  /// Process a touch start event.
  /// [localY] is the Y position relative to the game area.
  /// [gameHeight] is the total height of the touchable area.
  void onTouchStart(double localY, double gameHeight) {
    if (_locked) return;
    _isTouching = true;
    _updatePosition(localY, gameHeight);
  }

  /// Process a touch move event.
  void onTouchMove(double localY, double gameHeight) {
    if (_locked || !_isTouching) return;
    _updatePosition(localY, gameHeight);
  }

  /// Process a touch end event.
  void onTouchEnd() {
    _isTouching = false;
  }

  /// Update position from a raw Y coordinate.
  void _updatePosition(double localY, double gameHeight) {
    // Normalize: 0.0 at bottom, 1.0 at top
    _normalizedY = 1.0 - (localY / gameHeight).clamp(0.0, 1.0);
    _updatePitch();
  }

  /// Convert normalized position to MIDI pitch.
  void _updatePitch() {
    _currentMidiNote = _instrument.touchPositionToMidi(_normalizedY);
  }

  /// Reset to default position (center).
  void reset() {
    _normalizedY = 0.5;
    _isTouching = false;
    _updatePitch();
  }
}
