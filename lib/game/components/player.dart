import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bug_out_game.dart';
import 'engine_trail.dart';
import 'enemy.dart';

class Player extends PositionComponent
    with HasGameReference<BugOutGame>, CollisionCallbacks {
  static const double moveSpeed = 340;

  double _flashTimer = 0;
  double _enginePulse = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(48, 56);
    anchor = Anchor.center;
    reset();
    add(CircleHitbox(radius: 18));
    add(EngineTrail(this));
  }

  void reset() {
    position = Vector2(game.size.x / 2, game.size.y - 100);
  }

  void flash() {
    _flashTimer = 0.6;
  }

  void moveByDirection(Vector2 direction, double dt) {
    position += direction * moveSpeed * dt;
    clampToBounds();
  }

  void moveByDelta(Vector2 delta) {
    position += delta;
    clampToBounds();
  }

  void clampToBounds() {
    final margin = size.x / 2;
    position.x = position.x.clamp(margin, game.size.x - margin);
    position.y = position.y.clamp(game.size.y * 0.45, game.size.y - margin);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _enginePulse += dt * 8;
    if (_flashTimer > 0) _flashTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    if (_flashTimer > 0 && (_flashTimer * 10).floor().isOdd) {
      return;
    }

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF64FFDA), Color(0xFF00BFA5)],
      ).createShader(Rect.fromLTWH(-24, -28, 48, 56));

    final path = Path()
      ..moveTo(0, -28)
      ..lineTo(22, 18)
      ..lineTo(8, 12)
      ..lineTo(0, 28)
      ..lineTo(-8, 12)
      ..lineTo(-22, 18)
      ..close();

    canvas.drawPath(path, bodyPaint);

    canvas.drawCircle(
      const Offset(0, -4),
      6,
      Paint()..color = const Color(0xFF1DE9B6),
    );

    final flameHeight = 10 + sin(_enginePulse) * 4;
    canvas.drawPath(
      Path()
        ..moveTo(-6, 24)
        ..lineTo(0, 24 + flameHeight)
        ..lineTo(6, 24)
        ..close(),
      Paint()..color = const Color(0xFFFF7043),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      game.damagePlayer();
      other.removeFromParent();
      game.resetCombo();
    }
  }
}
