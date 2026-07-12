import 'package:flutter/material.dart';
import '../../audio/midi_player.dart';
import '../theme.dart';

/// 谱面组件 —— 音符下落 + 判定线
class MusicStand extends StatelessWidget {
  final MidiTrack? track;
  final double songTime; // Current playback time in seconds
  final double playerMidiNote; // Player's current pitch
  final bool isTouching;

  const MusicStand({
    super.key,
    required this.track,
    required this.songTime,
    required this.playerMidiNote,
    required this.isTouching,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 谱面线条 (五线谱风格)
            _buildStaffLines(constraints),

            // 下落的音符
            if (track != null) ..._buildNotes(constraints),

            // 判定线 (屏幕中央)
            _buildJudgmentLine(constraints),

            // 玩家音高指示器
            if (isTouching) _buildPlayerIndicator(constraints),

            // 连击/判定文字
            // (handled by game_screen overlay)
          ],
        );
      },
    );
  }

  Widget _buildStaffLines(BoxConstraints constraints) {
    return CustomPaint(
      painter: const StaffLinesPainter(lineCount: 5),
      size: Size(constraints.maxWidth, constraints.maxHeight),
    );
  }

  List<Widget> _buildNotes(BoxConstraints constraints) {
    final widgets = <Widget>[];
    final lookAheadSec = 3.0;
    final halfHeight = constraints.maxHeight / 2;

    // Judgment line is at the middle of the screen
    // Notes above judgment line (negative y) are future notes
    // Notes at judgment line are being played now

    for (final note in track!.notes) {
      final timeUntilJudgment = note.startTime - songTime;

      // Only show notes within the visible window
      if (timeUntilJudgment < -0.3 || timeUntilJudgment > lookAheadSec) {
        continue;
      }

      // Map time to vertical position
      // 0 seconds = at judgment line (center)
      // Seconds ahead = above judgment line
      final pixelsPerSecond = halfHeight / lookAheadSec;
      final yOffset = halfHeight - (timeUntilJudgment * pixelsPerSecond);

      // Map MIDI note to horizontal position
      // Low notes on left, high notes on right
      final midiRange = 48.0; // Range of display (e.g., C3 to C7)
      final normalizedMidi = (note.noteNumber - 48) / midiRange;
      final xOffset = normalizedMidi.clamp(0.05, 0.95) * constraints.maxWidth;

      // Calculate opacity based on distance
      final opacity = (1.0 - (timeUntilJudgment.abs() / lookAheadSec)).clamp(0.2, 1.0);

      // Note size based on importance
      final noteWidth = 36.0;
      final noteHeight = 20.0;

      widgets.add(
        Positioned(
          left: xOffset - noteWidth / 2,
          top: yOffset - noteHeight / 2,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: noteWidth,
              height: noteHeight,
              decoration: BoxDecoration(
                color: GameColors.scarfRed.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildJudgmentLine(BoxConstraints constraints) {
    return Positioned(
      left: 0,
      right: 0,
      top: constraints.maxHeight / 2 - 1,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: GameColors.scarfRed,
          boxShadow: [
            BoxShadow(
              color: GameColors.scarfRed.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerIndicator(BoxConstraints constraints) {
    // Show where the player's pitch is on the horizontal axis
    final midiRange = 48.0;
    final normalizedMidi = (playerMidiNote - 48) / midiRange;
    final xOffset = normalizedMidi.clamp(0.0, 1.0) * constraints.maxWidth;

    return Positioned(
      left: xOffset - 12,
      top: constraints.maxHeight / 2 - 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: GameColors.awardGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: GameColors.awardGold.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.music_note, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

/// Custom painter for staff lines (五线谱)
class StaffLinesPainter extends CustomPainter {
  final int lineCount;

  const StaffLinesPainter({this.lineCount = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final spacing = size.height / (lineCount + 1);

    for (var i = 1; i <= lineCount; i++) {
      final y = spacing * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
