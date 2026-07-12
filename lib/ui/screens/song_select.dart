import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/game_controller.dart';
import '../../data/songs.dart';
import '../../data/instruments.dart';
import '../theme.dart';

/// 曲目选择 —— 卡带A面/B面翻页
class SongSelect extends StatefulWidget {
  const SongSelect({super.key});

  @override
  State<SongSelect> createState() => _SongSelectState();
}

class _SongSelectState extends State<SongSelect> {
  /// 'A' for 排箫, 'B' for 笙
  String _currentSide = 'A';

  Instrument get _currentInstrument =>
      _currentSide == 'A' ? panFlute : sheng;

  List<Song> get _currentSongs =>
      songsForInstrument(_currentInstrument.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: GameColors.paperYellow,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header: 课间铃 / 下一节课
              _buildHeader(context),

              // 卡带翻面选择器
              _buildSideSelector(),

              // 曲目列表
              Expanded(child: _buildSongList()),

              // 返回按钮
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.blackboardGreen,
        border: const Border(
          bottom: BorderSide(color: GameColors.chalkWhite, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.school, color: GameColors.chalkWhite),
              const Text(
                '音乐课 · 选曲',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameColors.chalkWhite,
                  letterSpacing: 2,
                ),
              ),
              // 课间铃图标
              GestureDetector(
                onTap: () => _toggleSide(),
                child: const Icon(
                  Icons.notifications_active,
                  color: GameColors.awardGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _currentSide == 'A' ? '卡带 A面 · 排箫' : '卡带 B面 · 笙',
            style: const TextStyle(
              fontSize: 14,
              color: GameColors.chalkWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.paperDark,
        border: const Border(
          bottom: BorderSide(color: Colors.brown, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _sideButton('A', '排箫', panFlute.description),
          const SizedBox(width: 20),
          // 卡带 icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GameColors.cassetteGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.album,
                  color: _currentSide == 'A'
                      ? GameColors.flowerRed
                      : GameColors.cassetteLight,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  _currentSide,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _sideButton('B', '笙', sheng.description),
        ],
      ),
    );
  }

  Widget _sideButton(String side, String name, String desc) {
    final isActive = _currentSide == side;
    return GestureDetector(
      onTap: () => setState(() => _currentSide = side),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? GameColors.scarfRed : Colors.brown.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? GameColors.awardGold : Colors.brown.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.brown.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$side面',
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white70 : Colors.brown.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentSongs.length,
      itemBuilder: (context, index) {
        final song = _currentSongs[index];
        return _buildSongCard(song, context);
      },
    );
  }

  Widget _buildSongCard(Song song, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: GameColors.paperYellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.read<GameController>().selectSong(song);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 难度小红花
              Column(
                children: [
                  Text(
                    '🌸' * song.difficulty,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '难度 ${song.difficulty}/5',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // 歌曲信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.composer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 箭头
              Icon(
                Icons.play_arrow,
                color: GameColors.scarfRed,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 200,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            context.read<GameController>().goToMenu();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            foregroundColor: Colors.white,
          ),
          child: const Text('下课', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  void _toggleSide() {
    setState(() {
      _currentSide = _currentSide == 'A' ? 'B' : 'A';
    });
  }
}
