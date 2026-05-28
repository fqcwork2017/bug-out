import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import 'showcase_game.dart';

TextComponent _title(String text, Vector2 pos, Color color) => TextComponent(
      text: text,
      anchor: Anchor.center,
      position: pos,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );

TextComponent _caption(String text, Vector2 pos) => TextComponent(
      text: text,
      anchor: Anchor.topCenter,
      position: pos,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
      ),
    );

/// 氛围天气：雨、雪、气泡
class AmbientShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('氛围 / 天气', Vector2(cx, game.size.y * 0.14), const Color(0xFF81D4FA)));

    add(_RainEmitter(bounds: game.size));
    add(_SnowEmitter(bounds: game.size));
    add(_BubbleEmitter(bounds: game.size));

    add(_caption('雨滴 · 雪花 · 上升气泡', Vector2(cx, game.size.y * 0.72)));
    add(
      TextComponent(
        text: '点击生成气泡',
        anchor: Anchor.center,
        position: Vector2(cx, game.size.y * 0.78),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}

class _RainEmitter extends Component with HasGameReference<ShowcaseGame> {
  _RainEmitter({required this.bounds});

  final Vector2 bounds;
  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.section != ShowcaseSection.ambient) return;
    _timer -= dt;
    if (_timer > 0) return;
    _timer = 0.04;

    parent?.add(
      ParticleSystemComponent(
        position: Vector2(_random.nextDouble() * bounds.x, -10),
        particle: Particle.generate(
          count: 1,
          lifespan: 1.2,
          generator: (i) => CircleParticle(
            paint: Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.7),
            radius: 1.2,
          ).accelerated(
            speed: Vector2(-20 + _random.nextDouble() * 40, 280 + _random.nextDouble() * 80),
            acceleration: Vector2(0, 40),
          ),
        ),
      ),
    );
  }
}

class _SnowEmitter extends Component with HasGameReference<ShowcaseGame> {
  _SnowEmitter({required this.bounds});

  final Vector2 bounds;
  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.section != ShowcaseSection.ambient) return;
    _timer -= dt;
    if (_timer > 0) return;
    _timer = 0.18;

    parent?.add(
      ParticleSystemComponent(
        position: Vector2(_random.nextDouble() * bounds.x, -8),
        particle: Particle.generate(
          count: 1,
          lifespan: 4,
          generator: (i) => CircleParticle(
            paint: Paint()..color = Colors.white.withValues(alpha: 0.75),
            radius: 1.5 + _random.nextDouble() * 2,
          ).accelerated(
            speed: Vector2(-15 + _random.nextDouble() * 30, 40 + _random.nextDouble() * 30),
            acceleration: Vector2(0, 8),
          ).moving(
            to: Vector2(_random.nextDouble() * 30 - 15, 60),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}

class _BubbleEmitter extends Component with HasGameReference<ShowcaseGame> {
  _BubbleEmitter({required this.bounds});

  final Vector2 bounds;
  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.section != ShowcaseSection.ambient) return;
    _timer -= dt;
    if (_timer > 0) return;
    _timer = 0.5;

    parent?.add(
      ParticleSystemComponent(
        position: Vector2(
          bounds.x * 0.15 + _random.nextDouble() * bounds.x * 0.7,
          bounds.y + 10,
        ),
        particle: Particle.generate(
          count: 1,
          lifespan: 3.5,
          generator: (i) => CircleParticle(
            paint: Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.35),
            radius: 4 + _random.nextDouble() * 8,
          ).accelerated(
            speed: Vector2((_random.nextDouble() - 0.5) * 20, -50 - _random.nextDouble() * 30),
            acceleration: Vector2(0, -5),
          ).scaling(to: 1.4, curve: Curves.easeOut),
        ),
      ),
    );
  }
}

/// 点击气泡
class BubbleBurst extends ParticleSystemComponent {
  BubbleBurst({required super.position})
      : super(
          particle: Particle.generate(
            count: 12,
            lifespan: 0.9,
            generator: (i) {
              final angle = -pi / 2 + (Random().nextDouble() - 0.5) * 1.4;
              final speed = 60 + Random().nextDouble() * 80;
              return CircleParticle(
                paint: Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.6),
                radius: 3 + Random().nextDouble() * 5,
              )
                  .accelerated(
                    speed: Vector2(cos(angle), sin(angle)) * speed,
                    acceleration: Vector2(0, -30),
                  )
                  .scaling(to: 0);
            },
          ),
        );
}

/// 物理感运动：钟摆、轨道卫星、弹簧球
class MotionShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('物理感运动', Vector2(cx, game.size.y * 0.14), const Color(0xFFAED581)));

    add(_Pendulum(origin: Vector2(game.size.x * 0.25, game.size.y * 0.32)));
    add(_caption('钟摆 · SineEffectController', Vector2(game.size.x * 0.25, game.size.y * 0.32 + 90)));

    add(_OrbitSystem(center: Vector2(game.size.x * 0.72, game.size.y * 0.4)));
    add(_caption('轨道卫星 · RotateEffect', Vector2(game.size.x * 0.72, game.size.y * 0.4 + 80)));

    add(_SpringBall(position: Vector2(cx, game.size.y * 0.68)));
    add(_caption('弹簧弹跳 · alternate Scale', Vector2(cx, game.size.y * 0.68 + 60)));
  }
}

class _Pendulum extends PositionComponent {
  _Pendulum({required this.origin})
      : super(position: origin, anchor: Anchor.topCenter, size: Vector2(4, 90));

  final Vector2 origin;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: Vector2(3, 70),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 0),
        paint: Paint()..color = Colors.white.withValues(alpha: 0.5),
      ),
    );
    final bob = CircleComponent(
      radius: 14,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 70),
      paint: Paint()..color = const Color(0xFFFFD740),
    );
    add(bob);

    add(
      RotateEffect.by(
        0.7,
        EffectController(
          duration: 1.6,
          infinite: true,
          alternate: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}

class _OrbitSystem extends PositionComponent {
  _OrbitSystem({required Vector2 center})
      : super(position: center, size: Vector2.all(120), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final hub = size / 2;
    add(
      CircleComponent(
        radius: 50,
        anchor: Anchor.center,
        position: hub,
        paint: Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),
    );
    add(
      CircleComponent(
        radius: 10,
        anchor: Anchor.center,
        position: hub,
        paint: Paint()..color = const Color(0xFF40C4FF),
      ),
    );

    final arm = PositionComponent(position: hub, anchor: Anchor.center);
    arm.add(
      CircleComponent(
        radius: 6,
        anchor: Anchor.center,
        position: Vector2(50, 0),
        paint: Paint()..color = const Color(0xFF69F0AE),
      ),
    );
    arm.add(
      RotateEffect.by(
        pi * 2,
        EffectController(duration: 4, infinite: true),
      ),
    );
    add(arm);
  }
}

class _SpringBall extends CircleComponent {
  _SpringBall({required super.position})
      : super(
          radius: 22,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF7C4DFF),
        );

  @override
  Future<void> onLoad() async {
    add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2(1, -0.55),
          EffectController(duration: 0.35, curve: Curves.easeIn),
        ),
        ScaleEffect.by(
          Vector2(1, 0.55),
          EffectController(duration: 0.45, curve: Curves.elasticOut),
        ),
        MoveByEffect(
          Vector2(0, -40),
          EffectController(duration: 0.35, curve: Curves.easeOut),
        ),
        MoveByEffect(
          Vector2(0, 40),
          EffectController(duration: 0.45, curve: Curves.bounceOut),
        ),
      ], infinite: true),
    );
  }
}

/// 变换 / 光效：Glow、雷达扫描、翻转卡片
class TransformShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('光效 / 变换', Vector2(cx, game.size.y * 0.14), const Color(0xFFFF8A65)));

    add(_GlowOrb(position: Vector2(game.size.x * 0.25, game.size.y * 0.4)));
    add(_caption('GlowEffect 外发光', Vector2(game.size.x * 0.25, game.size.y * 0.4 + 52)));

    add(_RadarScan(position: Vector2(game.size.x * 0.72, game.size.y * 0.4)));
    add(_caption('雷达扫描 · Canvas 扇形', Vector2(game.size.x * 0.72, game.size.y * 0.4 + 70)));

    add(_FlipCard(position: Vector2(cx, game.size.y * 0.68)));
    add(_caption('翻转卡片 · SequenceEffect', Vector2(cx, game.size.y * 0.68 + 70)));

    add(
      TextComponent(
        text: '点击卡片翻转',
        anchor: Anchor.center,
        position: Vector2(cx, game.size.y * 0.88),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}

class _GlowOrb extends CircleComponent {
  _GlowOrb({required super.position})
      : super(
          radius: 24,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF69F0AE),
        );

  @override
  Future<void> onLoad() async {
    add(
      GlowEffect(
        12,
        EffectController(duration: 1.8, alternate: true, infinite: true, curve: Curves.easeInOut),
      ),
    );
    add(
      ScaleEffect.by(
        Vector2.all(0.15),
        EffectController(duration: 1.8, alternate: true, infinite: true),
      ),
    );
  }
}

class _RadarScan extends PositionComponent {
  _RadarScan({required super.position})
      : super(size: Vector2.all(110), anchor: Anchor.center);

  double _angle = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _angle += dt * 2.5;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      size.x / 4,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final sweep = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: size.x / 2),
        _angle,
        pi / 4,
        false,
      )
      ..close();
    canvas.drawPath(
      sweep,
      Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.25),
    );
    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(_angle) * size.x / 2,
        center.dy + sin(_angle) * size.x / 2,
      ),
      Paint()
        ..color = const Color(0xFF69F0AE)
        ..strokeWidth = 2,
    );
  }
}

class _FlipCard extends PositionComponent with TapCallbacks {
  _FlipCard({required super.position})
      : super(size: Vector2(160, 100), anchor: Anchor.center);

  bool _front = true;
  bool _animating = false;

  late RectangleComponent _face;

  @override
  Future<void> onLoad() async {
    _face = RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          colors: _front
              ? [const Color(0xFF448AFF), const Color(0xFF7C4DFF)]
              : [const Color(0xFFFF9100), const Color(0xFFFF5252)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      children: [
        TextComponent(
          text: '正面',
          anchor: Anchor.center,
          position: size / 2,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    add(_face);
  }

  void flip() {
    if (_animating || parent == null) return;
    _animating = true;
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2(0.01, 1),
          EffectController(duration: 0.2, curve: Curves.easeIn),
        ),
        FunctionEffect<_FlipCard>((target, _) {
          target._front = !target._front;
          target._face.paint = Paint()
            ..shader = LinearGradient(
              colors: target._front
                  ? [const Color(0xFF448AFF), const Color(0xFF7C4DFF)]
                  : [const Color(0xFFFF9100), const Color(0xFFFF5252)],
            ).createShader(Rect.fromLTWH(0, 0, target.size.x, target.size.y));
          target._face.children.whereType<TextComponent>().first.text =
              target._front ? '正面' : '背面';
        }, EffectController(duration: 0.01)),
        ScaleEffect.to(
          Vector2(1, 1),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
      ], onComplete: () => _animating = false),
    );
  }

  @override
  void onTapUp(TapUpEvent event) => flip();
}

/// 节点网络脉冲
class NetworkShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('网络 / 拓扑', Vector2(cx, game.size.y * 0.14), const Color(0xFF90CAF9)));

    add(_NetworkGraph(center: Vector2(cx, game.size.y * 0.48), radius: 100));
    add(_caption('节点脉冲 · 连线呼吸', Vector2(cx, game.size.y * 0.48 + 120)));
  }
}

class _NetworkGraph extends PositionComponent {
  _NetworkGraph({required Vector2 center, required this.radius})
      : super(position: center, size: Vector2.all(radius * 2.4), anchor: Anchor.center);

  final double radius;
  double _pulse = 0;

  static final _nodes = [
    Vector2(0, -1),
    Vector2(0.87, -0.5),
    Vector2(0.87, 0.5),
    Vector2(0, 1),
    Vector2(-0.87, 0.5),
    Vector2(-0.87, -0.5),
  ];

  static const _edges = [
    [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 3], [1, 4],
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final positions = _nodes.map((n) {
      final pulse = 1 + sin(_pulse + n.x * 2) * 0.06;
      return Offset(c.dx + n.x * radius * pulse, c.dy + n.y * radius * pulse);
    }).toList();

    final lineAlpha = 0.15 + (sin(_pulse) * 0.5 + 0.5) * 0.25;
    final linePaint = Paint()
      ..color = const Color(0xFF40C4FF).withValues(alpha: lineAlpha)
      ..strokeWidth = 1.5;

    for (final edge in _edges) {
      canvas.drawLine(positions[edge[0]], positions[edge[1]], linePaint);
    }

    for (var i = 0; i < positions.length; i++) {
      final nodePulse = 5 + sin(_pulse * 1.5 + i) * 2;
      canvas.drawCircle(
        positions[i],
        nodePulse,
        Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        positions[i],
        nodePulse + 6,
        Paint()
          ..color = const Color(0xFF69F0AE).withValues(alpha: 0.15 + sin(_pulse + i) * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }
}
