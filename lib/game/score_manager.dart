/// Scoring system modeled after 90s primary school grading:
/// 小红花 (Little Red Flowers) instead of letter grades.
class ScoreManager {
  /// Current score (cumulative accuracy points)
  double _score = 0;

  /// Current combo (consecutive accurate hits)
  int _combo = 0;

  /// Maximum combo achieved this performance
  int _maxCombo = 0;

  /// Number of notes hit with each accuracy level
  final Map<Accuracy, int> _accuracyCounts = {
    for (final a in Accuracy.values) a: 0,
  };

  /// Total notes in the current song
  int _totalNotes = 0;

  /// Notes missed
  int _missedNotes = 0;

  // Getters
  double get score => _score;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get totalNotes => _totalNotes;
  int get missedNotes => _missedNotes;

  /// Set the total note count for the current song.
  void setTotalNotes(int count) {
    _totalNotes = count;
  }

  /// Evaluate a note hit based on pitch deviation.
  /// [deviation] is in semitones (0.0 = perfect).
  /// Returns the accuracy level achieved.
  Accuracy evaluateNote(double deviation) {
    final abs = deviation.abs();

    Accuracy accuracy;
    if (abs <= 0.3) {
      accuracy = Accuracy.perfect;
    } else if (abs <= 0.6) {
      accuracy = Accuracy.great;
    } else if (abs <= 1.0) {
      accuracy = Accuracy.good;
    } else if (abs <= 2.0) {
      accuracy = Accuracy.ok;
    } else {
      accuracy = Accuracy.miss;
    }

    _accuracyCounts[accuracy] = (_accuracyCounts[accuracy] ?? 0) + 1;

    if (accuracy == Accuracy.miss) {
      _combo = 0;
      _missedNotes++;
    } else {
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;
      _score += accuracy.basePoints * (1.0 + (_combo * 0.1).clamp(0.0, 1.0));
    }

    return accuracy;
  }

  /// Get the final rating as 小红花 count (1-5).
  int get flowerRating {
    if (_totalNotes == 0) return 0;
    final hitRate = (_totalNotes - _missedNotes) / _totalNotes;
    if (hitRate >= 0.95) return 5;
    if (hitRate >= 0.80) return 4;
    if (hitRate >= 0.60) return 3;
    if (hitRate >= 0.30) return 2;
    return 1;
  }

  /// Reset for a new song.
  void reset() {
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _totalNotes = 0;
    _missedNotes = 0;
    for (final key in _accuracyCounts.keys) {
      _accuracyCounts[key] = 0;
    }
  }

  /// Get accuracy ratio for a specific level.
  double accuracyRatio(Accuracy accuracy) {
    if (_totalNotes == 0) return 0;
    return (_accuracyCounts[accuracy] ?? 0) / _totalNotes;
  }
}

/// Accuracy levels for note hitting.
enum Accuracy {
  perfect('PERFECT', '满分！', 100),
  great('GREAT', '优秀！', 80),
  good('GOOD', '良好！', 50),
  ok('OK', '还行……', 20),
  miss('MISS', '请家长签字', 0);

  final String label;
  final String chineseComment; // 90s teacher remark style
  final int basePoints;

  const Accuracy(this.label, this.chineseComment, this.basePoints);
}
