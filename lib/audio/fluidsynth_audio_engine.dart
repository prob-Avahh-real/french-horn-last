import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'audio_engine.dart';

// ── FluidSynth FFI bindings ──

typedef FluidSettings = Pointer<Void>;
typedef FluidSynth = Pointer<Void>;
typedef FluidAudioDriver = Pointer<Void>;

// new_fluid_settings
typedef NewSettingsC = Pointer<Void> Function();
typedef NewSettingsDart = Pointer<Void> Function();

// delete_fluid_settings
typedef DeleteSettingsC = Void Function(Pointer<Void>);
typedef DeleteSettingsDart = void Function(Pointer<Void>);

// new_fluid_synth
typedef NewSynthC = Pointer<Void> Function(Pointer<Void>);
typedef NewSynthDart = Pointer<Void> Function(Pointer<Void>);

// delete_fluid_synth
typedef DeleteSynthC = Void Function(Pointer<Void>);
typedef DeleteSynthDart = void Function(Pointer<Void>);

// fluid_settings_setstr
typedef SetStrC = Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);
typedef SetStrDart = int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);

// fluid_settings_setint
typedef SetIntC = Int32 Function(Pointer<Void>, Pointer<Utf8>, Int32);
typedef SetIntDart = int Function(Pointer<Void>, Pointer<Utf8>, int);

// fluid_settings_setnum
typedef SetNumC = Int32 Function(Pointer<Void>, Pointer<Utf8>, Double);
typedef SetNumDart = int Function(Pointer<Void>, Pointer<Utf8>, double);

// fluid_synth_sfload
typedef SfLoadC = Int32 Function(Pointer<Void>, Pointer<Utf8>, Int32);
typedef SfLoadDart = int Function(Pointer<Void>, Pointer<Utf8>, int);

// fluid_synth_program_select
typedef ProgSelC = Int32 Function(Pointer<Void>, Int32, Int32);
typedef ProgSelDart = int Function(Pointer<Void>, int, int);

// fluid_synth_noteon
typedef NoteOnC = Int32 Function(Pointer<Void>, Int32, Int32, Int32);
typedef NoteOnDart = int Function(Pointer<Void>, int, int, int);

// fluid_synth_noteoff
typedef NoteOffC = Int32 Function(Pointer<Void>, Int32, Int32);
typedef NoteOffDart = int Function(Pointer<Void>, int, int);

// fluid_synth_pitch_bend
typedef PitchBendC = Int32 Function(Pointer<Void>, Int32, Int32);
typedef PitchBendDart = int Function(Pointer<Void>, int, int);

// fluid_synth_all_notes_off / all_sounds_off
typedef AllOffC = Int32 Function(Pointer<Void>, Int32);
typedef AllOffDart = int Function(Pointer<Void>, int);

// new_fluid_audio_driver
typedef NewDriverC = Pointer<Void> Function(Pointer<Void>, Pointer<Void>);
typedef NewDriverDart = Pointer<Void> Function(Pointer<Void>, Pointer<Void>);

// delete_fluid_audio_driver
typedef DeleteDriverC = Void Function(Pointer<Void>);
typedef DeleteDriverDart = void Function(Pointer<Void>);


/// Full FluidSynth-based audio engine.
/// Uses conda-installed libfluidsynth.dylib + bundled SoundFont.
class FluidsynthAudioEngine implements AudioEngine {
  DynamicLibrary? _lib;
  Pointer<Void>? _settings;
  Pointer<Void>? _synth;
  Pointer<Void>? _driver;
  bool _initialized = false;

  @override
  Future<void> init() async {
    // Path to conda-installed FluidSynth
    const libPath = '/Users/skat/fluidsynth_env/lib/libfluidsynth.3.dylib';
    _lib = DynamicLibrary.open(libPath);

    final newSettings = _lib!.lookupFunction<NewSettingsC, NewSettingsDart>('new_fluid_settings');
    final newSynth = _lib!.lookupFunction<NewSynthC, NewSynthDart>('new_fluid_synth');
    final setStr = _lib!.lookupFunction<SetStrC, SetStrDart>('fluid_settings_setstr');

    _settings = newSettings();

    // Configure audio driver
    final driverName = 'coreaudio'.toNativeUtf8();
    final driverKey = 'audio.driver'.toNativeUtf8();
    setStr(_settings!, driverKey, driverName);
    calloc.free(driverName);
    calloc.free(driverKey);

    // Set audio period size (smaller = lower latency)
    final setNum = _lib!.lookupFunction<SetNumC, SetNumDart>('fluid_settings_setnum');
    final periodKey = 'audio.period-size'.toNativeUtf8();
    setNum(_settings!, periodKey, 256.0);
    calloc.free(periodKey);

    _synth = newSynth(_settings!);

    // Create audio driver
    final newDriver = _lib!.lookupFunction<NewDriverC, NewDriverDart>('new_fluid_audio_driver');
    _driver = newDriver(_settings!, _synth!);

    _initialized = true;
  }

  @override
  Future<void> loadSoundFont(String path) async {
    if (!_initialized || _synth == null) return;
    final sfLoad = _lib!.lookupFunction<SfLoadC, SfLoadDart>('fluid_synth_sfload');
    final pathStr = path.toNativeUtf8();
    sfLoad(_synth!, pathStr, 1);
    calloc.free(pathStr);
  }

  @override
  void setInstrument(int gmProgram) {
    if (!_initialized || _synth == null) return;
    final progSel = _lib!.lookupFunction<ProgSelC, ProgSelDart>('fluid_synth_program_select');
    progSel(_synth!, 0, gmProgram);
  }

  @override
  void noteOn(int noteNumber, {int velocity = 100}) {
    if (!_initialized || _synth == null) return;
    final noteOn = _lib!.lookupFunction<NoteOnC, NoteOnDart>('fluid_synth_noteon');
    noteOn(_synth!, 0, noteNumber, velocity);
  }

  @override
  void noteOff(int noteNumber) {
    if (!_initialized || _synth == null) return;
    final noteOff = _lib!.lookupFunction<NoteOffC, NoteOffDart>('fluid_synth_noteoff');
    noteOff(_synth!, 0, noteNumber);
  }

  @override
  void pitchBend(double semitoneOffset) {
    if (!_initialized || _synth == null) return;
    final pb = _lib!.lookupFunction<PitchBendC, PitchBendDart>('fluid_synth_pitch_bend');
    // FluidSynth pitch bend: 0 = center, 0-8192 = up, 0-(-8192) = down
    // semitoneOffset: -12.0 to +12.0
    final value = (semitoneOffset * 682.67).round().clamp(-8192, 8191);
    pb(_synth!, 0, value);
  }

  @override
  void startAccompaniment() {
    // FluidSynth plays accompaniment in real-time
  }

  @override
  void allNotesOff() {
    if (!_initialized || _synth == null) return;
    final allOff = _lib!.lookupFunction<AllOffC, AllOffDart>('fluid_synth_all_notes_off');
    allOff(_synth!, 0);
  }

  @override
  void dispose() {
    if (_driver != null && _lib != null) {
      final delDriver = _lib!.lookupFunction<DeleteDriverC, DeleteDriverDart>('delete_fluid_audio_driver');
      delDriver(_driver!);
      _driver = null;
    }
    if (_synth != null && _lib != null) {
      final delSynth = _lib!.lookupFunction<DeleteSynthC, DeleteSynthDart>('delete_fluid_synth');
      delSynth(_synth!);
      _synth = null;
    }
    if (_settings != null && _lib != null) {
      final delSettings = _lib!.lookupFunction<DeleteSettingsC, DeleteSettingsDart>('delete_fluid_settings');
      delSettings(_settings!);
      _settings = null;
    }
    _initialized = false;
  }
}
