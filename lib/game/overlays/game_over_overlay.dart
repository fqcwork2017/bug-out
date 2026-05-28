import 'package:flutter/material.dart';

import '../bug_out_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final BugOutGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF12122A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 24),
              _StatRow(label: '得分', value: '${game.score}'),
              _StatRow(label: '波次', value: '${game.wave}'),
              _StatRow(
                label: '最高分',
                value: '${game.highScore}',
                highlight: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: game.startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF69F0AE),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '再来一局',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? const Color(0xFFFFD740) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final BugOutGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: game.togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40C4FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              ),
              child: const Text('继续游戏'),
            ),
          ],
        ),
      ),
    );
  }
}
