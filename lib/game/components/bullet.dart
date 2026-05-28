import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bug_out_game.dart';

class Bullet extends PositionComponent with HasGameReference<BugOutGame>, CollisionCallbacks {
  Bullet({
    required super.position,
    required this.velocity,
    required this.damage,
    required this.fromPlayer,
  }) {
    size = Vector2(6, 16);
    anchor = Anchor.center;
  }

  final Vector2 velocity;
  final int damage;
  final bool fromPlayer;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.y < -20 || position.y > game.size.y + 20) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = fromPlayer ? const Color(0xFF69F0AE) : const Color(0xFFFF5252);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
        const Radius.circular(3),
      ),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size.x * 0.5, height: size.y * 0.6),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }
}
