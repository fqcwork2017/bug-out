import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Explosion extends PositionComponent {
  Explosion({
    required super.position,
    required this.color,
    this.particleCount = 14,
  }) {
    size = Vector2.all(4);
    anchor = Anchor.center;
    _initParticles();
  }

  final Color color;
  final int particleCount;
  final List<_Particle> _particles = [];
  double _life = 0.6;

  void _initParticles() {
    final random = Random();
    for (var i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = 80 + random.nextDouble() * 160;
      _particles.add(_Particle(
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        radius: 2 + random.nextDouble() * 4,
        color: Color.lerp(color, Colors.white, random.nextDouble()) ?? color,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    for (final particle in _particles) {
      particle.position += particle.velocity * dt;
      particle.velocity *= 0.92;
    }
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_life / 0.6).clamp(0.0, 1.0);
    for (final particle in _particles) {
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.radius * alpha,
        Paint()..color = particle.color.withValues(alpha: alpha),
      );
    }
  }
}

class _Particle {
  _Particle({
    required this.velocity,
    required this.radius,
    required this.color,
  });

  Vector2 velocity;
  Vector2 position = Vector2.zero();
  final double radius;
  final Color color;
}
