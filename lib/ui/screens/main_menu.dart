import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/game_controller.dart';
import '../theme.dart';

/// 主菜单 —— 音乐课本封面
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GameColors.paperYellow,
              GameColors.paperDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background decorative elements
              // 音乐符号散落
              ..._buildMusicNotes(size),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: GameColors.blackboardGreen,
                      border: Border.all(
                        color: GameColors.chalkWhite,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '圆号老末',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: GameColors.chalkWhite,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '小学音乐课 · 排箫与笙',
                          style: TextStyle(
                            fontSize: 16,
                            color: GameColors.chalkWhite,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Subtitle: 课本信息
                  Text(
                    '九年义务教育六年制小学教科书',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GameColors.blackboardGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '音乐 第七册',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: GameColors.scarfRed,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Start button
                  SizedBox(
                    width: 220,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<GameController>().goToSongSelect();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.scarfRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '开始上课',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Footer: 出版社信息
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  '人民音乐出版社 · 2003',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.brown.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMusicNotes(Size size) {
    // Decorative scattered music notes (simple text)
    return [
      Positioned(
        top: 30,
        right: 40,
        child: Text('♩', style: TextStyle(fontSize: 48, color: Colors.brown.shade200)),
      ),
      Positioned(
        bottom: 100,
        left: 50,
        child: Text('♪', style: TextStyle(fontSize: 64, color: Colors.brown.shade100)),
      ),
      Positioned(
        top: 120,
        left: 30,
        child: Text('♫', style: TextStyle(fontSize: 40, color: Colors.brown.shade200)),
      ),
    ];
  }
}
