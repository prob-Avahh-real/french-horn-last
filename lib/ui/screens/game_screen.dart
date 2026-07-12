import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../game/game_controller.dart';
import '../theme.dart';
import '../widgets/music_stand.dart';
import '../widgets/teacher.dart';

/// 演奏界面 —— 讲台 + 谱面 + 判定线
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final controller = context.read<GameController>();
    // Send delta time since last tick
    // For simplicity, use a fixed 16ms frame
    controller.tick(const Duration(milliseconds: 16));
    setState(() {}); // Redraw every frame
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.state != GameState.playing &&
        controller.state != GameState.paused) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: GameColors.paperYellow,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 教室背景
                _buildClassroomBackground(constraints),

                // 谱面（音符下落区域）
                Positioned(
                  left: constraints.maxWidth * 0.25,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: MusicStand(
                    track: controller.currentTrack,
                    songTime: controller.songTime,
                    playerMidiNote: controller.currentMidiNote,
                    isTouching: controller.isTouching,
                  ),
                ),

                // 老师（左边）
                Positioned(
                  left: 20,
                  top: constraints.maxHeight * 0.3,
                  child: TeacherFace(
                    lastAccuracy: controller.lastAccuracy,
                  ),
                ),

                // 判定线区域提示
                Positioned(
                  right: 0,
                  top: constraints.maxHeight * 0.5 - 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GameColors.scarfRed.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      '🎯',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                // 暂停按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      controller.state == GameState.paused
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: GameColors.blackboardGreen,
                    ),
                    onPressed: () => controller.togglePause(),
                  ),
                ),

                // 暂停遮罩
                if (controller.state == GameState.paused)
                  _buildPauseOverlay(constraints),

                // 触控区域（整个屏幕）
                Positioned.fill(
                  child: _buildTouchArea(controller, constraints),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassroomBackground(BoxConstraints constraints) {
    return Column(
      children: [
        // 教室上方 - 黑板顶部
        Container(
          height: constraints.maxHeight * 0.08,
          color: GameColors.blackboardGreen,
          child: const Center(
            child: Text(
              '好好学习  天天向上',
              style: TextStyle(
                color: GameColors.chalkWhite,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        // 教室主体 - 讲台背景
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.brown.shade50,
                  Colors.brown.shade100,
                ],
              ),
            ),
          ),
        ),
        // 教室底部 - 地板
        Container(
          height: constraints.maxHeight * 0.12,
          decoration: BoxDecoration(
            color: Colors.brown.shade400,
            border: Border(
              top: BorderSide(
                color: Colors.brown.shade600,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchArea(GameController controller, BoxConstraints constraints) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        controller.onTouchStart(
          details.localPosition.dy,
          constraints.maxHeight,
        );
      },
      onPanUpdate: (details) {
        controller.onTouchMove(
          details.localPosition.dy,
          constraints.maxHeight,
        );
      },
      onPanEnd: (_) {
        controller.onTouchEnd();
      },
      onPanCancel: () {
        controller.onTouchEnd();
      },
    );
  }

  Widget _buildPauseOverlay(BoxConstraints constraints) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              '课间休息',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<GameController>().togglePause();
                  },
                  child: const Text('继续上课'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<GameController>().goToMenu();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('逃课'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
