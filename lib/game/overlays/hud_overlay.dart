import 'package:flutter/material.dart';

import '../bug_out_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final BugOutGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: game.hudTick,
        builder: (context, _, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoChip(
                  label: 'SCORE',
                  value: '${game.score}',
                  color: const Color(0xFF69F0AE),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'WAVE',
                  value: '${game.wave}',
                  color: const Color(0xFF40C4FF),
                ),
                const Spacer(),
                if (game.combo >= 3)
                  _InfoChip(
                    label: 'COMBO',
                    value: 'x${game.combo}',
                    color: const Color(0xFFFFD740),
                  ),
                const SizedBox(width: 12),
                _LivesDisplay(lives: game.lives),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesDisplay extends StatelessWidget {
  const _LivesDisplay({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.favorite,
            color: active
                ? const Color(0xFFFF5252)
                : Colors.white.withValues(alpha: 0.2),
            size: 22,
          ),
        );
      }),
    );
  }
}
