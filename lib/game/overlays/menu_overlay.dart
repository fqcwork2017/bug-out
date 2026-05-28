import 'package:flutter/material.dart';

import '../bug_out_game.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  final BugOutGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'BUG OUT',
              style: TextStyle(
                color: Color(0xFF69F0AE),
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '消灭虫群，突出重围',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            _PulseButton(
              label: '开始游戏',
              onPressed: game.startGame,
            ),
            const SizedBox(height: 32),
            Text(
              '拖拽移动 · 自动射击\nWASD / 方向键 · P 暂停',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (game.highScore > 0) ...[
              const SizedBox(height: 24),
              Text(
                '最高分: ${game.highScore}',
                style: const TextStyle(
                  color: Color(0xFFFFD740),
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PulseButton extends StatefulWidget {
  const _PulseButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _controller.value * 0.04,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
