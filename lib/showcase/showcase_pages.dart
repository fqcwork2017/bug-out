import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../game/effects/particle_effects.dart';
import 'showcase_game.dart';
import 'sprite_sheet_factory.dart';

/// 精灵动画展示区：SpriteSheet + SpriteAnimationComponent
class SpriteShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final centerY = game.size.y * 0.42;

    add(_sectionTitle('精灵动画 SpriteAnimation', game.size.y * 0.14));

    final shipSheet = SpriteSheet(
      image: SpriteSheetFactory.shipSheet!,
      srcSize: Vector2.all(SpriteSheetFactory.frameSize),
    );
    add(
      SpriteAnimationComponent(
        animation: shipSheet.createAnimation(
          row: 0,
          stepTime: 0.09,
          to: SpriteSheetFactory.shipFrames,
        ),
        position: Vector2(game.size.x * 0.25, centerY),
        size: Vector2.all(96),
        anchor: Anchor.center,
      )
        ..add(
          MoveEffect.by(
            Vector2(0, -14),
            EffectController(
              duration: 1.2,
              alternate: true,
              infinite: true,
              curve: Curves.easeInOut,
            ),
          ),
        ),
    );
    add(_caption('飞船飞行动画', Vector2(game.size.x * 0.25, centerY + 72)));

    final bugSheet = SpriteSheet(
      image: SpriteSheetFactory.bugSheet!,
      srcSize: Vector2.all(SpriteSheetFactory.frameSize),
    );
    add(
      SpriteAnimationComponent(
        animation: bugSheet.createAnimation(
          row: 0,
          stepTime: 0.1,
          to: SpriteSheetFactory.bugFrames,
        ),
        position: Vector2(game.size.x * 0.75, centerY),
        size: Vector2.all(96),
        anchor: Anchor.center,
      )
        ..add(
          MoveEffect.by(
            Vector2(30, 0),
            EffectController(
              duration: 2.0,
              alternate: true,
              infinite: true,
              curve: Curves.easeInOut,
            ),
          ),
        ),
    );
    add(_caption('虫子爬行动画', Vector2(game.size.x * 0.75, centerY + 72)));

    final explodeSheet = SpriteSheet(
      image: SpriteSheetFactory.explodeSheet!,
      srcSize: Vector2.all(SpriteSheetFactory.frameSize),
    );
    add(
      _LoopingExplosion(
        animation: explodeSheet.createAnimation(
          row: 0,
          stepTime: 0.08,
          loop: false,
          to: SpriteSheetFactory.explodeFrames,
        ),
        position: Vector2(game.size.x * 0.5, centerY + 130),
      ),
    );
    add(_caption('爆炸帧动画（循环播放）', Vector2(game.size.x * 0.5, centerY + 200)));
  }

  TextComponent _sectionTitle(String text, double y) {
    return TextComponent(
      text: text,
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, y),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF69F0AE),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  TextComponent _caption(String text, Vector2 position) {
    return TextComponent(
      text: text,
      anchor: Anchor.topCenter,
      position: position,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _LoopingExplosion extends SpriteAnimationComponent {
  _LoopingExplosion({
    required super.animation,
    required super.position,
  }) : super(
          size: Vector2.all(80),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    animation!.loop = false;
    add(
      TimerComponent(
        period: 0.55,
        repeat: true,
        onTick: () => animationTicker?.reset(),
      ),
    );
  }
}

/// 粒子系统展示区
class ParticleShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    add(_sectionTitle('粒子系统 Particles', game.size.y * 0.14));

    add(_ParticleEmitter(
      position: Vector2(game.size.x * 0.2, game.size.y * 0.55),
      label: '引擎尾焰',
      factory: () => ParticleEffects.engineExhaust(position: Vector2.zero()),
      interval: 0.05,
    ));
    add(_ParticleEmitter(
      position: Vector2(game.size.x * 0.5, game.size.y * 0.55),
      label: '爆炸粒子',
      factory: () => ParticleEffects.explosion(
        position: Vector2.zero(),
        color: const Color(0xFFE040FB),
        count: 18,
      ),
      interval: 1.2,
    ));
    add(_ParticleEmitter(
      position: Vector2(game.size.x * 0.8, game.size.y * 0.55),
      label: '命中火花',
      factory: () => ParticleEffects.hitSparks(position: Vector2.zero()),
      interval: 0.7,
    ));

    add(_OrbitParticleRing(position: game.size / 2 + Vector2(0, 80)));
  }

  TextComponent _sectionTitle(String text, double y) {
    return TextComponent(
      text: text,
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, y),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF40C4FF),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ParticleEmitter extends Component {
  _ParticleEmitter({
    required this.position,
    required this.label,
    required this.factory,
    required this.interval,
  });

  final Vector2 position;
  final String label;
  final ParticleSystemComponent Function() factory;
  final double interval;

  double _timer = 0;

  @override
  Future<void> onLoad() async {
    add(
      TextComponent(
        text: label,
        anchor: Anchor.topCenter,
        position: Vector2(0, 50),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;
    if (_timer <= 0) {
      _timer = interval;
      final burst = factory()..position = position;
      parent?.add(burst);
    }
  }
}

class _OrbitParticleRing extends Component {
  _OrbitParticleRing({required this.position});

  final Vector2 position;
  double _angle = 0;
  double _cooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _angle += dt * 2.2;
    _cooldown -= dt;
    if (_cooldown > 0) return;
    _cooldown = 0.08;

    parent?.add(
      ParticleSystemComponent(
        position: position + Vector2(cos(_angle), sin(_angle)) * 90,
        particle: Particle.generate(
          count: 3,
          lifespan: 0.5,
          generator: (i) => CircleParticle(
            paint: Paint()..color = const Color(0xFF69F0AE),
            radius: 2,
          ).scaling(to: 0),
        ),
      ),
    );
  }
}

/// Effect 动画链展示区
class EffectShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    add(_sectionTitle('Effect 补间动画', game.size.y * 0.14));

    final badge = CircleComponent(
      radius: 28,
      paint: Paint()..color = const Color(0xFFFFD740),
      position: Vector2(game.size.x * 0.25, game.size.y * 0.42),
      anchor: Anchor.center,
    );
    badge.add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(0.35),
          EffectController(duration: 0.6, curve: Curves.elasticOut),
        ),
        ScaleEffect.by(
          Vector2.all(-0.35),
          EffectController(duration: 0.6, curve: Curves.easeInOut),
        ),
      ], infinite: true),
    );
    add(badge);
    add(_caption('ScaleEffect 弹性缩放', Vector2(game.size.x * 0.25, game.size.y * 0.42 + 56)));

    final ring = CircleComponent(
      radius: 20,
      paint: Paint()
        ..color = const Color(0xFF69F0AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      position: Vector2(game.size.x * 0.5, game.size.y * 0.42),
      anchor: Anchor.center,
    );
    ring.add(
      RotateEffect.by(
        pi * 2,
        EffectController(duration: 3, infinite: true),
      ),
    );
    add(ring);
    add(_caption('RotateEffect 旋转', Vector2(game.size.x * 0.5, game.size.y * 0.42 + 56)));

    final orb = CircleComponent(
      radius: 16,
      paint: Paint()..color = const Color(0xFF7C4DFF),
      position: Vector2(game.size.x * 0.75, game.size.y * 0.42),
      anchor: Anchor.center,
    );
    orb.add(
      MoveEffect.by(
        Vector2(0, -50),
        EffectController(
          duration: 1.4,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
    orb.add(
      OpacityEffect.to(
        0.25,
        EffectController(
          duration: 1.4,
          alternate: true,
          infinite: true,
        ),
      ),
    );
    add(orb);
    add(_caption('Move + Opacity 呼吸', Vector2(game.size.x * 0.75, game.size.y * 0.42 + 56)));

    add(
      TextComponent(
        text: '点击屏幕触发冲击波',
        anchor: Anchor.center,
        position: Vector2(game.size.x / 2, game.size.y * 0.72),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  TextComponent _sectionTitle(String text, double y) {
    return TextComponent(
      text: text,
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, y),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD740),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  TextComponent _caption(String text, Vector2 position) {
    return TextComponent(
      text: text,
      anchor: Anchor.topCenter,
      position: position,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}
