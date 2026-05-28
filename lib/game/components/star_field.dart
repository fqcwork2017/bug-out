import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class StarField extends Component with HasGameReference<FlameGame> {
  final List<_Star> _stars = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _generateStars();
  }

  void _generateStars() {
    _stars.clear();
    final count = (game.size.x * game.size.y / 3500).round().clamp(40, 120);
    for (var i = 0; i < count; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * game.size.x,
        y: _random.nextDouble() * game.size.y,
        speed: 20 + _random.nextDouble() * 80,
        radius: 0.5 + _random.nextDouble() * 1.8,
        brightness: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_stars.isEmpty && size.x > 0 && size.y > 0) {
      _generateStars();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final height = game.size.y;
    for (final star in _stars) {
      star.y += star.speed * dt;
      if (star.y > height) {
        star.y = 0;
        star.x = _random.nextDouble() * game.size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.radius,
        Paint()..color = Colors.white.withValues(alpha: star.brightness),
      );
    }
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.brightness,
  });

  double x;
  double y;
  final double speed;
  final double radius;
  final double brightness;
}
