import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/game_controller.dart';
import 'ui/theme.dart';
import 'ui/screens/main_menu.dart';
import 'ui/screens/song_select.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const FrenchHornLastApp(),
    ),
  );
}

class FrenchHornLastApp extends StatelessWidget {
  const FrenchHornLastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '圆号老末',
      debugShowCheckedModeBanner: false,
      theme: gameTheme,
      home: const GameRouter(),
    );
  }
}

/// Routes between screens based on [GameController.state].
class GameRouter extends StatelessWidget {
  const GameRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameController>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _screenForState(state),
    );
  }

  Widget _screenForState(GameState state) {
    switch (state) {
      case GameState.menu:
        return const MainMenu();
      case GameState.songSelect:
        return const SongSelect();
      case GameState.playing:
      case GameState.paused:
        return const GameScreen();
      case GameState.result:
        return const ResultScreen();
    }
  }
}
