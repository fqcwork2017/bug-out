import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bug_out_game.dart';
import 'bullet.dart';
import 'player.dart';

enum EnemyKind {
  normal(speed: 120, health: 1, score: 100, color: Color(0xFFE040FB)),
  zigzag(speed: 100, health: 1, score: 150, color: Color(0xFF7C4DFF)),
  tank(speed: 70, health: 3, score: 300, color: Color(0xFFFF5252)),
  boss(speed: 55, health: 12, score: 2000, color: Color(0xFFFFD740));

  const EnemyKind({
    required this.speed,
    required this.health,
    required this.score,
    required this.color,
  });

  final double speed;
  final int health;
  final int score;
  final Color color;

  int get scoreValue => score;
}

class Enemy extends PositionComponent with HasGameReference<BugOutGame>, CollisionCallbacks {
  Enemy({
    required this.kind,
    required super.position,
    required super.size,
  }) : health = kind.health;

  final EnemyKind kind;
  int health;
  double _wobble = 0;
  double _zigzagOffset = 0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    _wobble = _random.nextDouble() * pi * 2;
    add(CircleHitbox(radius: size.x * 0.38));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _wobble += dt * 4;

    var velocity = Vector2(0, kind.speed + game.wave * 4);

    switch (kind) {
      case EnemyKind.zigzag:
        _zigzagOffset += dt * 3;
        velocity.x = sin(_zigzagOffset) * 140;
      case EnemyKind.boss:
        velocity.x = sin(_wobble) * 60;
      default:
        break;
    }

    position += velocity * dt;

    if (position.y - size.y / 2 > game.size.y + 20) {
      removeFromParent();
      game.enemiesRemaining--;
      if (game.enemiesRemaining <= 0 && game.enemiesSpawned >= game.enemiesToSpawn) {
        game.nextWave();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final scale = 1 + sin(_wobble) * 0.06;
    canvas.save();
    canvas.scale(scale);

    final bodyPaint = Paint()..color = kind.color;
    final legPaint = Paint()
      ..color = kind.color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.x * 0.35;
    canvas.drawCircle(Offset.zero, radius, bodyPaint);

    for (var i = 0; i < 6; i++) {
      final angle = i * pi / 3 + _wobble * 0.5;
      final legEnd = Offset(cos(angle) * radius * 1.6, sin(angle) * radius * 1.6);
      canvas.drawLine(Offset(cos(angle) * radius, sin(angle) * radius), legEnd, legPaint);
    }

    canvas.drawCircle(
      const Offset(-8, -4),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(8, -4),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(-8, -4),
      2,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      const Offset(8, -4),
      2,
      Paint()..color = Colors.black,
    );

    if (health > 1) {
      final barWidth = size.x * 0.8;
      final progress = health / kind.health;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, -radius - 10), width: barWidth, height: 4),
        Paint()..color = Colors.black54,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(-barWidth / 2 + barWidth * progress / 2, -radius - 10),
          width: barWidth * progress,
          height: 4,
        ),
        Paint()..color = Colors.greenAccent,
      );
    }

    canvas.restore();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.fromPlayer) {
      health -= other.damage;
      other.removeFromParent();
      if (health <= 0) {
        game.enemyDestroyed(this);
      }
    } else if (other is Player) {
      game.damagePlayer();
      removeFromParent();
    }
  }
}
