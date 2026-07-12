import 'package:flutter/material.dart';
import '../../game/score_manager.dart';
import '../theme.dart';

/// 老师脸 —— 根据判定结果变化表情
class TeacherFace extends StatelessWidget {
  final Accuracy? lastAccuracy;

  const TeacherFace({super.key, this.lastAccuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: GameColors.chalkWhite,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.brown.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getFace(),
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );
  }

  String _getFace() {
    if (lastAccuracy == null) return '😐'; // 认真听

    switch (lastAccuracy!) {
      case Accuracy.perfect:
        return '😊';
      case Accuracy.great:
        return '😄';
      case Accuracy.good:
        return '🙂';
      case Accuracy.ok:
        return '😐';
      case Accuracy.miss:
        return '😟';
    }
  }
}

/// 判定文字弹出动画
class AccuracyPopup extends StatefulWidget {
  final Accuracy accuracy;

  const AccuracyPopup({super.key, required this.accuracy});

  @override
  State<AccuracyPopup> createState() => _AccuracyPopupState();
}

class _AccuracyPopupState extends State<AccuracyPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.accuracy) {
      case Accuracy.perfect:
        return GameColors.perfectColor;
      case Accuracy.great:
        return GameColors.greatColor;
      case Accuracy.good:
        return GameColors.goodColor;
      case Accuracy.ok:
        return GameColors.okColor;
      case Accuracy.miss:
        return GameColors.missColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.accuracy.label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getColor(),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.accuracy.chineseComment,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getColor().withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
