/// Instrument definitions for the game.
/// Uses General MIDI program numbers for SoundFont compatibility.
class Instrument {
  final String id;
  final String name;
  final int gmProgram; // General MIDI program number
  final String description;
  final double pitchRangeLow; // MIDI note number (lowest)
  final double pitchRangeHigh; // MIDI note number (highest)
  final String side; // 'A' for 排箫, 'B' for 笙 (卡带隐喻)

  const Instrument({
    required this.id,
    required this.name,
    required this.gmProgram,
    required this.description,
    required this.pitchRangeLow,
    required this.pitchRangeHigh,
    required this.side,
  });

  /// Normalize a touch position (0.0=bottom, 1.0=top) to a MIDI note number.
  double touchPositionToMidi(double normalizedY) {
    // Clamp and invert: bottom of screen = low pitch
    final clamped = normalizedY.clamp(0.0, 1.0);
    return pitchRangeLow + (pitchRangeHigh - pitchRangeLow) * clamped;
  }
}

/// 排箫 (Pan Flute) - GM program 75
const panFlute = Instrument(
  id: 'pan_flute',
  name: '排箫',
  gmProgram: 75,
  description: '塑料排箫，小学音乐课人手一个',
  pitchRangeLow: 60, // C4
  pitchRangeHigh: 84, // C6
  side: 'A',
);

/// 笙 (Sheng) - GM program 110, treated as monophonic for gameplay
const sheng = Instrument(
  id: 'sheng',
  name: '笙',
  gmProgram: 110,
  description: '只有大队长才碰得到的民乐队高级货',
  pitchRangeLow: 55, // G3
  pitchRangeHigh: 79, // G5
  side: 'B',
);

const allInstruments = [panFlute, sheng];
