import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/game_controller.dart';
import '../../game/score_manager.dart';
import '../theme.dart';

/// 结果界面 —— 小红花评分 + 老师评语
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final song = controller.currentSong;
    final score = controller.score;

    if (song == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: GameColors.paperYellow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成绩单标题
                _buildTitleCard(),
                const SizedBox(height: 24),

                // 小红花
                _buildFlowerRating(score.flowerRating),
                const SizedBox(height: 24),

                // 老师评语
                _buildTeacherComment(score),
                const SizedBox(height: 24),

                // 详细统计
                _buildStatsCard(score, song.title),
                const SizedBox(height: 24),

                // 操作按钮
                _buildActionButtons(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GameColors.scarfRed, width: 3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            '音乐课成绩单',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GameColors.scarfRed,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '—— 请家长查阅 ——',
            style: TextStyle(
              fontSize: 14,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerRating(int flowers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final active = i < flowers;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '🌸',
            style: TextStyle(
              fontSize: 48,
              color: active ? null : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTeacherComment(ScoreManager score) {
    String comment;
    if (score.flowerRating >= 5) {
      comment = '满分！文艺小标兵！';
    } else if (score.flowerRating >= 4) {
      comment = '优秀！可以报销路费了。';
    } else if (score.flowerRating >= 3) {
      comment = '良好。继续努力。';
    } else if (score.flowerRating >= 2) {
      comment = '及格。请家长督促练习。';
    } else {
      comment = '不及格。请家长签字。';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.blackboardGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👩‍🏫', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 18,
              color: GameColors.chalkWhite,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ScoreManager score, String songTitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        children: [
          Text(
            songTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          _statRow('总分', '${score.score.toInt()} 分'),
          _statRow('最大连击', '${score.maxCombo} 连'),
          _statRow('命中率', '${((score.totalNotes - score.missedNotes) / score.totalNotes * 100).toStringAsFixed(1)}%'),
          const Divider(),
          _statRow('PERFECT', '${(score.accuracyRatio(Accuracy.perfect) * 100).toStringAsFixed(1)}%'),
          _statRow('GREAT', '${(score.accuracyRatio(Accuracy.great) * 100).toStringAsFixed(1)}%'),
          _statRow('GOOD', '${(score.accuracyRatio(Accuracy.good) * 100).toStringAsFixed(1)}%'),
          _statRow('OK', '${(score.accuracyRatio(Accuracy.ok) * 100).toStringAsFixed(1)}%'),
          _statRow('MISS', '${(score.accuracyRatio(Accuracy.miss) * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.brown)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => controller.restartSong(),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.blackboardGreen,
          ),
          child: const Text('再练一遍'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => controller.goToSongSelect(),
          child: const Text('换一首'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => controller.goToMenu(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
          ),
          child: const Text('下课'),
        ),
      ],
    );
  }
}
