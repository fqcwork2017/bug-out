import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/bug_out_game.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/menu_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BugOutApp());
}

class BugOutApp extends StatelessWidget {
  const BugOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bug Out',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BugOutGame _game;

  @override
  void initState() {
    super.initState();
    _game = BugOutGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          BugOutGame.overlayMenu: (context, game) =>
              MenuOverlay(game: game as BugOutGame),
          BugOutGame.overlayHud: (context, game) =>
              HudOverlay(game: game as BugOutGame),
          BugOutGame.overlayGameOver: (context, game) =>
              GameOverOverlay(game: game as BugOutGame),
          BugOutGame.overlayPause: (context, game) =>
              PauseOverlay(game: game as BugOutGame),
        },
      ),
    );
  }
}
