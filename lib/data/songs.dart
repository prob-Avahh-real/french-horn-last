import 'instruments.dart';

/// A song in the game's library.
class Song {
  final String id;
  final String title;
  final String composer;
  final String era; // e.g. '90s music class', 'classical'
  final String midiAssetPath;
  final Instrument instrument;
  final double bpm;
  final int difficulty; // 1-5 小红花难度
  final String unlockCondition; // 'default' or description of unlock

  const Song({
    required this.id,
    required this.title,
    required this.composer,
    required this.era,
    required this.midiAssetPath,
    required this.instrument,
    required this.bpm,
    required this.difficulty,
    this.unlockCondition = 'default',
  });
}

/// The full song library, organized by instrument (卡带A面/B面).
const songLibrary = <String, List<Song>>{
  // A面：排箫曲库
  'pan_flute': [
    Song(
      id: 'canon_pf',
      title: '卡农',
      composer: '帕赫贝尔',
      era: 'classical',
      midiAssetPath: 'assets/midi/canon.mid',
      instrument: panFlute,
      bpm: 80,
      difficulty: 2,
    ),
    Song(
      id: 'ode_to_joy_pf',
      title: '欢乐颂',
      composer: '贝多芬',
      era: 'classical',
      midiAssetPath: 'assets/midi/ode_to_joy.mid',
      instrument: panFlute,
      bpm: 120,
      difficulty: 2,
    ),
    Song(
      id: 'jasmine_pf',
      title: '茉莉花',
      composer: '中国民歌',
      era: 'classical',
      midiAssetPath: 'assets/midi/jasmine.mid',
      instrument: panFlute,
      bpm: 72,
      difficulty: 1,
    ),
    Song(
      id: 'william_tell_pf',
      title: '威廉退尔序曲',
      composer: '罗西尼',
      era: 'classical',
      midiAssetPath: 'assets/midi/william_tell.mid',
      instrument: panFlute,
      bpm: 150,
      difficulty: 4,
    ),
    Song(
      id: 'jingle_bells_pf',
      title: '铃儿响叮当',
      composer: '皮尔庞特',
      era: 'classical',
      midiAssetPath: 'assets/midi/jingle_bells.mid',
      instrument: panFlute,
      bpm: 140,
      difficulty: 1,
    ),
  ],

  // B面：笙曲库
  'sheng': [
    Song(
      id: 'canon_sg',
      title: '卡农',
      composer: '帕赫贝尔',
      era: 'classical',
      midiAssetPath: 'assets/midi/canon.mid',
      instrument: sheng,
      bpm: 80,
      difficulty: 2,
    ),
    Song(
      id: 'ode_to_joy_sg',
      title: '欢乐颂',
      composer: '贝多芬',
      era: 'classical',
      midiAssetPath: 'assets/midi/ode_to_joy.mid',
      instrument: sheng,
      bpm: 120,
      difficulty: 2,
    ),
    Song(
      id: 'blue_danube_sg',
      title: '蓝色多瑙河',
      composer: '小约翰·施特劳斯',
      era: 'classical',
      midiAssetPath: 'assets/midi/blue_danube.mid',
      instrument: sheng,
      bpm: 160,
      difficulty: 3,
    ),
    Song(
      id: 'spring_sg',
      title: '春节序曲',
      composer: '李焕之',
      era: 'classical',
      midiAssetPath: 'assets/midi/spring.mid',
      instrument: sheng,
      bpm: 130,
      difficulty: 3,
    ),
    Song(
      id: 'radetzky_sg',
      title: '拉德茨基进行曲',
      composer: '老约翰·施特劳斯',
      era: 'classical',
      midiAssetPath: 'assets/midi/radetzky.mid',
      instrument: sheng,
      bpm: 120,
      difficulty: 4,
    ),
  ],
};

/// Get all songs for a given instrument ID.
List<Song> songsForInstrument(String instrumentId) {
  return songLibrary[instrumentId] ?? [];
}
