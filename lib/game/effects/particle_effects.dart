import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Flame 内置粒子系统的封装，展示 composable particles 的用法。
class ParticleEffects {
  static ParticleSystemComponent explosion({
    required Vector2 position,
    required Color color,
    int count = 24,
    double lifespan = 0.7,
  }) {
    final random = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: lifespan,
        generator: (i) {
          final angle = random.nextDouble() * pi * 2;
          final speed = 120 + random.nextDouble() * 220;
          final tint = Color.lerp(color, Colors.white, random.nextDouble()) ?? color;
          return CircleParticle(
            paint: Paint()..color = tint,
            radius: 2 + random.nextDouble() * 5,
          )
              .accelerated(
                speed: Vector2(cos(angle), sin(angle)) * speed,
                acceleration: Vector2(0, 80),
              )
              .scaling(to: 0, curve: Curves.easeOut);
        },
      ),
    );
  }

  static ParticleSystemComponent bossExplosion({
    required Vector2 position,
    required Color color,
  }) {
    final random = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 48,
        lifespan: 1.0,
        generator: (i) {
          final angle = random.nextDouble() * pi * 2;
          final speed = 180 + random.nextDouble() * 280;
          return CircleParticle(
            paint: Paint()..color = Color.lerp(color, Colors.orange, random.nextDouble())!,
            radius: 3 + random.nextDouble() * 7,
          )
              .accelerated(
                speed: Vector2(cos(angle), sin(angle)) * speed,
                acceleration: Vector2(0, 60),
              )
              .scaling(to: 0, curve: Curves.easeOutCubic);
        },
      ),
    );
  }

  static ParticleSystemComponent hitSparks({
    required Vector2 position,
    Color color = const Color(0xFF69F0AE),
  }) {
    final random = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 8,
        lifespan: 0.35,
        generator: (i) {
          final angle = -pi / 2 + (random.nextDouble() - 0.5) * 1.2;
          final speed = 60 + random.nextDouble() * 100;
          return CircleParticle(
            paint: Paint()..color = color,
            radius: 1.5 + random.nextDouble() * 2,
          )
              .accelerated(
                speed: Vector2(cos(angle), sin(angle)) * speed,
                acceleration: Vector2(0, 120),
              )
              .scaling(to: 0);
        },
      ),
    );
  }

  static ParticleSystemComponent engineExhaust({
    required Vector2 position,
  }) {
    final random = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 1,
        lifespan: 0.35,
        generator: (i) {
          final drift = (random.nextDouble() - 0.5) * 30;
          return CircleParticle(
            paint: Paint()..color = const Color(0xFFFF7043).withValues(alpha: 0.85),
            radius: 3 + random.nextDouble() * 3,
          )
              .accelerated(
                speed: Vector2(drift, 40 + random.nextDouble() * 40),
                acceleration: Vector2(0, 20),
              )
              .scaling(to: 0, curve: Curves.easeIn);
        },
      ),
    );
  }
}
