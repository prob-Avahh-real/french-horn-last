import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data/songs.dart';
import '../audio/audio_engine.dart';
import '../audio/fluidsynth_audio_engine.dart';
import '../audio/midi_player.dart';
import 'input_handler.dart';
import 'score_manager.dart';

/// Game states.
enum GameState {
  menu,
  songSelect,
  playing,
  paused,
  result,
}

/// Core game controller - the central state machine.
/// Owns the game loop, audio, input, and scoring.
class GameController extends ChangeNotifier {
  // Sub-systems
  final AudioEngine _audio = FluidsynthAudioEngine();
  final InputHandler _input = InputHandler();
  final ScoreManager _score = ScoreManager();

  // State
  GameState _state = GameState.menu;
  Song? _currentSong;
  MidiTrack? _currentTrack;
  int _currentNoteIndex = 0;
  double _songTime = 0; // Current playback time in seconds
  bool _isPlaying = false;

  // UI feedback
  Accuracy? _lastAccuracy;

  // Getters
  GameState get state => _state;
  Song? get currentSong => _currentSong;
  MidiTrack? get currentTrack => _currentTrack;
  double get songTime => _songTime;
  bool get isPlaying => _isPlaying;
  double get currentMidiNote => _input.currentMidiNote;
  double get normalizedY => _input.normalizedY;
  bool get isTouching => _input.isTouching;
  ScoreManager get score => _score;
  Accuracy? get lastAccuracy => _lastAccuracy;

  /// Initialize the controller.
  Future<void> init() async {
    try {
      await _audio.init();
      // Load the SoundFont from the project asset on macOS
      try {
        await _audio.loadSoundFont(
          '/Users/skat/projects/active/french_horn_last/assets/soundfonts/TimGM6mb.sf2',
        );
      } catch (_) {
        // SoundFont loading is optional — engine may not support it
      }
    } catch (e) {
      // Fallback: if FluidSynth isn't available, proceed silently
    }
  }

  /// Navigate to song selection.
  void goToSongSelect() {
    _state = GameState.songSelect;
    notifyListeners();
  }

  /// Navigate back to main menu.
  void goToMenu() {
    _state = GameState.menu;
    _currentSong = null;
    _currentTrack = null;
    notifyListeners();
  }

  /// Select a song and prepare to play.
  Future<void> selectSong(Song song) async {
    _currentSong = song;
    _input.setInstrument(song.instrument);
    _audio.setInstrument(song.instrument.gmProgram);

    // Try to load the real MIDI file from assets
    MidiTrack? track;
    try {
      final data = await rootBundle.load(song.midiAssetPath);
      track = MidiParser.parse(song.id, data.buffer.asUint8List());
    } catch (e) {
      // Fallback to test track if MIDI file is missing
      track = MidiParser.generateTestTrack(song.id, song.bpm);
    }

    _currentTrack = track;
    _score.reset();
    _score.setTotalNotes(_currentTrack!.notes.length);

    _state = GameState.playing;
    _songTime = 0;
    _currentNoteIndex = 0;
    _isPlaying = true;

    notifyListeners();
  }

  /// Called every frame by the game loop ticker.
  /// [dt] is the delta time in seconds.
  void tick(Duration dt) {
    if (_state != GameState.playing || !_isPlaying) return;
    if (_currentTrack == null) return;

    final dtSec = dt.inMicroseconds / 1000000.0;
    _songTime += dtSec;

    // Check for upcoming notes to evaluate
    _evaluateNotes();

    // Check if song is finished
    if (_songTime >= _currentTrack!.totalDuration + 1.0) {
      _finishSong();
      return;
    }

    // Send player's pitch to audio engine
    if (_input.isTouching) {
      final playerNote = _input.currentMidiNote.round();
      _audio.noteOn(playerNote);
    } else {
      _audio.allNotesOff();
    }

    notifyListeners();
  }

  /// Evaluate notes at the current time.
  void _evaluateNotes() {
    if (_currentTrack == null) return;

    for (var i = _currentNoteIndex; i < _currentTrack!.notes.length; i++) {
      final note = _currentTrack!.notes[i];

      // If we've passed the judgment window
      final judgmentWindow = 0.15; // 150ms window
      if (_songTime > note.startTime + judgmentWindow) {
        if (i == _currentNoteIndex) {
          // We missed this note (never hit the window)
          _lastAccuracy = _score.evaluateNote(999); // Large deviation = miss
          _currentNoteIndex++;
        }
        continue;
      }

      // If we're within the judgment window
      if (_songTime >= note.startTime - judgmentWindow &&
          _songTime <= note.startTime + judgmentWindow) {
        if (_input.isTouching) {
          final target = note.noteNumber.toDouble();
          final actual = _input.currentMidiNote;
          final deviation = (actual - target).abs();

          _lastAccuracy = _score.evaluateNote(deviation);
          _currentNoteIndex = i + 1;
          break; // One note per evaluation
        }
      }

      // Note is still in the future
      if (_songTime < note.startTime - judgmentWindow) {
        break;
      }
    }
  }

  /// Finish the current song and show results.
  void _finishSong() {
    _isPlaying = false;
    _audio.allNotesOff();
    _state = GameState.result;
    notifyListeners();
  }

  /// Pause/resume the game.
  void togglePause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      _isPlaying = false;
      _audio.allNotesOff();
    } else if (_state == GameState.paused) {
      _state = GameState.playing;
      _isPlaying = true;
    }
    notifyListeners();
  }

  /// Restart the current song.
  Future<void> restartSong() async {
    if (_currentSong != null) {
      await selectSong(_currentSong!);
    }
  }

  /// Get the upcoming notes for visual display.
  /// Returns notes within the visible window ahead of the judgment line.
  List<MidiNote> getVisibleNotes({double lookAheadSec = 3.0}) {
    if (_currentTrack == null) return [];
    return _currentTrack!.notes.where((n) {
      return n.startTime >= _songTime - 0.2 &&
          n.startTime <= _songTime + lookAheadSec;
    }).toList();
  }

  // --- Touch input delegation ---

  void onTouchStart(double localY, double gameHeight) {
    _input.onTouchStart(localY, gameHeight);
  }

  void onTouchMove(double localY, double gameHeight) {
    _input.onTouchMove(localY, gameHeight);
  }

  void onTouchEnd() {
    _input.onTouchEnd();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}
