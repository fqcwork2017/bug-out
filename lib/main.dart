import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/bug_out_game.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/menu_overlay.dart';
import 'showcase/showcase_game.dart';
import 'showcase/showcase_overlay.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BUG OUT',
                  style: TextStyle(
                    color: Color(0xFF69F0AE),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Flame 1.37.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 56),
                _HomeCard(
                  icon: Icons.rocket_launch,
                  title: '开始游戏',
                  subtitle: '太空射击 · 拖拽移动',
                  color: const Color(0xFF00BFA5),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _HomeCard(
                  icon: Icons.auto_awesome,
                  title: '动效展示',
                  subtitle: '12+ 场景 · 精灵 · UI · 氛围 · 光效',
                  color: const Color(0xFF7C4DFF),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShowcaseScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            color: color.withValues(alpha: 0.12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ),
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

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  late final ShowcaseGame _game;

  @override
  void initState() {
    super.initState();
    _game = ShowcaseGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          ShowcaseGame.overlayHud: (context, game) {
            final showcase = game as ShowcaseGame;
            return ValueListenableBuilder<int>(
              valueListenable: showcase.sectionTick,
              builder: (context, _, __) => ShowcaseOverlay(game: showcase),
            );
          },
        },
      ),
    );
  }
}
