import 'dart:math';

import 'package:flame/components.dart';
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

/// 启动页 / 品牌展示 —— Splash Screen
class SplashShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('启动页 / 品牌', Vector2(cx, game.size.y * 0.14), const Color(0xFF80DEEA)));

    add(_BreathingGlow(position: Vector2(cx, game.size.y * 0.4)));
    add(_BrandLogo(position: Vector2(cx, game.size.y * 0.4)));
    add(_caption('Logo 弹性入场 · ScaleEffect', Vector2(cx, game.size.y * 0.4 + 56)));

    final slogan = _FadeInSlogan(
      text: 'Let\'s go for a while',
      position: Vector2(cx, game.size.y * 0.55),
    );
    add(slogan);
    add(_caption('Slogan 延迟淡入 · FunctionEffect', Vector2(cx, game.size.y * 0.55 + 28)));

    add(_SkipHint(position: Vector2(cx, game.size.y * 0.78)));
    add(_caption('跳过按钮呼吸 · 循环 Opacity', Vector2(cx, game.size.y * 0.78 + 24)));
  }
}

class _BreathingGlow extends CircleComponent {
  _BreathingGlow({required super.position})
      : super(
          radius: 60,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFF00BFA5).withValues(alpha: 0.15),
        );

  @override
  Future<void> onLoad() async {
    add(
      ScaleEffect.by(
        Vector2.all(0.35),
        EffectController(duration: 2.2, alternate: true, infinite: true, curve: Curves.easeInOut),
      ),
    );
    add(
      OpacityEffect.to(
        0.05,
        EffectController(duration: 2.2, alternate: true, infinite: true),
      ),
    );
  }
}

class _BrandLogo extends CircleComponent {
  _BrandLogo({required super.position})
      : super(
          radius: 38,
          anchor: Anchor.center,
          paint: Paint()
            ..shader = const RadialGradient(
              colors: [Color(0xFF69F0AE), Color(0xFF00897B)],
            ).createShader(const Rect.fromLTWH(-38, -38, 76, 76)),
        );

  @override
  Future<void> onLoad() async {
    scale = Vector2.all(0.01);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.8, curve: Curves.elasticOut),
      ),
    );
    add(
      TextComponent(
        text: 'BO',
        anchor: Anchor.center,
        position: Vector2(radius, radius),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FadeInSlogan extends TextComponent {
  _FadeInSlogan({required super.text, required super.position})
      : super(
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0),
              letterSpacing: 3,
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(
      FunctionEffect<_FadeInSlogan>(
        (_, progress) {
          textRenderer = TextPaint(
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: progress.clamp(0.0, 1.0)),
              letterSpacing: 3,
            ),
          );
        },
        EffectController(duration: 1.0, startDelay: 0.6, curve: Curves.easeOut),
      ),
    );
  }
}

class _SkipHint extends TextComponent {
  _SkipHint({required Vector2 position})
      : super(
          text: '跳过',
          anchor: Anchor.center,
          position: position,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(
      FunctionEffect<_SkipHint>(
        (_, progress) {
          // TextComponent 不支持 OpacityEffect，用 FunctionEffect 改文字透明度
          final alpha = 0.25 + (1 - progress) * 0.35;
          textRenderer = TextPaint(
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: alpha),
              letterSpacing: 2,
            ),
          );
        },
        EffectController(
          duration: 1.5,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}

/// 状态反馈 —— 成功 / 失败 / Toast
class FeedbackShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('状态反馈', Vector2(cx, game.size.y * 0.14), const Color(0xFF69F0AE)));

    add(_SuccessBadge(position: Vector2(game.size.x * 0.28, game.size.y * 0.4)));
    add(_caption('成功 ✓ 描边动画', Vector2(game.size.x * 0.28, game.size.y * 0.4 + 52)));

    add(_ErrorBadge(position: Vector2(game.size.x * 0.72, game.size.y * 0.4)));
    add(_caption('失败抖动 · MoveByEffect', Vector2(game.size.x * 0.72, game.size.y * 0.4 + 52)));

    add(_ToastBanner(position: Vector2(cx, game.size.y * 0.62)));
    add(_caption('Toast 滑入滑出 · SequenceEffect', Vector2(cx, game.size.y * 0.62 + 36)));

    add(_NotificationDot(position: Vector2(game.size.x * 0.82, game.size.y * 0.28)));
    add(_caption('通知角标脉冲', Vector2(game.size.x * 0.82, game.size.y * 0.28 + 28)));
  }
}

class _SuccessBadge extends PositionComponent {
  _SuccessBadge({required super.position})
      : super(size: Vector2.all(72), anchor: Anchor.center);

  double _progress = 0;

  @override
  Future<void> onLoad() async {
    add(
      FunctionEffect<_SuccessBadge>(
        (_, p) => _progress = p,
        EffectController(duration: 1.2, curve: Curves.easeOutCubic),
      ),
    );
    add(
      TimerComponent(
        period: 3,
        repeat: true,
        onTick: () {
          if (parent == null) return;
          _progress = 0;
          add(
            FunctionEffect<_SuccessBadge>(
              (_, p) => _progress = p,
              EffectController(duration: 1.2, curve: Curves.easeOutCubic),
            ),
          );
        },
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      32,
      Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      32,
      Paint()
        ..color = const Color(0xFF69F0AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final path = Path()
      ..moveTo(size.x * 0.28, size.y * 0.52)
      ..lineTo(size.x * 0.44, size.y * 0.66)
      ..lineTo(size.x * 0.72, size.y * 0.36);

    final metrics = path.computeMetrics().first;
    final len = metrics.length * _progress.clamp(0.0, 1.0);
    final extract = metrics.extractPath(0, len);
    canvas.drawPath(
      extract,
      Paint()
        ..color = const Color(0xFF69F0AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }
}

class _ErrorBadge extends PositionComponent {
  _ErrorBadge({required super.position})
      : super(size: Vector2.all(72), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(
      TimerComponent(
        period: 2.5,
        repeat: true,
        onTick: _shake,
      ),
    );
    _shake();
  }

  void _shake() {
    if (parent == null) return;
    add(
      SequenceEffect([
        MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(16, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(-16, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(8, 0), EffectController(duration: 0.05)),
      ]),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      32,
      Paint()..color = const Color(0xFFFF5252).withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      32,
      Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawLine(c + const Offset(-12, -12), c + const Offset(12, 12),
        Paint()..color = const Color(0xFFFF5252)..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawLine(c + const Offset(12, -12), c + const Offset(-12, 12),
        Paint()..color = const Color(0xFFFF5252)..strokeWidth = 4..strokeCap = StrokeCap.round);
  }
}

class _ToastBanner extends PositionComponent {
  _ToastBanner({required super.position})
      : super(size: Vector2(260, 44), anchor: Anchor.center);

  late double _homeY;

  @override
  Future<void> onLoad() async {
    _homeY = position.y;
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.12),
        children: [
          TextComponent(
            text: '操作成功',
            anchor: Anchor.center,
            position: size / 2,
            textRenderer: TextPaint(
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
    _play();
    add(TimerComponent(period: 3.5, repeat: true, onTick: _play));
  }

  void _play() {
    if (parent == null) return;
    position.y = _homeY - 50;
    add(
      SequenceEffect([
        MoveByEffect(Vector2(0, 50), EffectController(duration: 0.45, curve: Curves.easeOutBack)),
        MoveByEffect(Vector2.zero(), EffectController(duration: 1.2)),
        MoveByEffect(Vector2(0, -30), EffectController(duration: 0.35, curve: Curves.easeIn)),
      ]),
    );
  }
}

class _NotificationDot extends PositionComponent {
  _NotificationDot({required super.position})
      : super(size: Vector2.all(40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(
      CircleComponent(
        radius: 10,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = const Color(0xFFFF5252),
      )..add(
          ScaleEffect.by(
            Vector2.all(0.5),
            EffectController(duration: 0.8, alternate: true, infinite: true, curve: Curves.easeInOut),
          ),
        ),
    );
    add(
      CircleComponent(
        radius: 18,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()
          ..color = const Color(0xFFFF5252).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      )..add(
          ScaleEffect.by(
            Vector2.all(0.6),
            EffectController(duration: 0.8, alternate: true, infinite: true),
          ),
        ),
    );
  }
}

/// 庆祝 / 成就 —— 活动页、解锁动画
class CelebrateShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('庆祝 / 成就', Vector2(cx, game.size.y * 0.14), const Color(0xFFFFD740)));

    add(_AchievementCard(position: Vector2(cx, game.size.y * 0.42)));
    add(_caption('成就卡弹入 · elasticOut', Vector2(cx, game.size.y * 0.42 + 72)));

    add(
      TextComponent(
        text: '点击屏幕撒花',
        anchor: Anchor.center,
        position: Vector2(cx, game.size.y * 0.72),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );

    add(TimerComponent(period: 2.5, repeat: true, onTick: () {
      if (game.section == ShowcaseSection.celebrate) {
        game.spawnConfetti();
      }
    }));
    game.spawnConfetti();
  }
}

class _AchievementCard extends PositionComponent {
  _AchievementCard({required super.position})
      : super(size: Vector2(220, 100), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    scale = Vector2.all(0.01);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.9, curve: Curves.elasticOut),
      ),
    );
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD740), Color(0xFFFF9100)],
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
        children: [
          TextComponent(
            text: '🏆 成就解锁',
            anchor: Anchor.center,
            position: Vector2(size.x / 2, size.y * 0.38),
            textRenderer: TextPaint(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          TextComponent(
            text: '首次通关',
            anchor: Anchor.center,
            position: Vector2(size.x / 2, size.y * 0.68),
            textRenderer: TextPaint(
              style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 媒体 / 工具 —— 波形、扫描线、跑马灯
class MediaShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    final cx = game.size.x / 2;
    add(_title('媒体 / 工具', Vector2(cx, game.size.y * 0.14), const Color(0xFF40C4FF)));

    add(_Waveform(position: Vector2(cx, game.size.y * 0.35), waveWidth: game.size.x * 0.75));
    add(_caption('音频波形 · 正弦叠加', Vector2(cx, game.size.y * 0.35 + 50)));

    add(_ScanFrame(position: Vector2(cx, game.size.y * 0.58)));
    add(_caption('扫码框 + 扫描线', Vector2(cx, game.size.y * 0.58 + 70)));

    add(_MarqueeLabel(fullText: 'Flame 非游戏场景 · 跑马灯文字 · 活动 Banner 滚动', y: game.size.y * 0.82));
    add(_caption('Marquee 跑马灯', Vector2(cx, game.size.y * 0.82 + 20)));
  }
}

class _Waveform extends PositionComponent {
  _Waveform({required super.position, required this.waveWidth})
      : super(size: Vector2(waveWidth, 60), anchor: Anchor.center);

  final double waveWidth;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt * 5;
  }

  @override
  void render(Canvas canvas) {
    final mid = size.y / 2;
    final path = Path()..moveTo(0, mid);
    for (var x = 0.0; x <= waveWidth; x += 3) {
      final n = x / waveWidth * pi * 4;
      final y = mid + sin(n + _t) * 12 + sin(n * 2.3 - _t * 1.4) * 6;
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF40C4FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
}

class _ScanFrame extends PositionComponent {
  _ScanFrame({required super.position})
      : super(size: Vector2(130, 130), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final scanLine = RectangleComponent(
      size: Vector2(size.x - 16, 3),
      paint: Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.85),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 8),
    );
    scanLine.add(
      MoveByEffect(
        Vector2(0, size.y - 20),
        EffectController(duration: 1.8, alternate: true, infinite: true, curve: Curves.easeInOut),
      ),
    );
    add(scanLine);
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    const sw = 3.0;
    final paint = Paint()
      ..color = const Color(0xFF69F0AE)
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;
    for (final origin in [
      Offset(0, 0),
      Offset(size.x, 0),
      Offset(0, size.y),
      Offset(size.x, size.y),
    ]) {
      final dx = origin.dx == 0 ? 1.0 : -1.0;
      final dy = origin.dy == 0 ? 1.0 : -1.0;
      canvas.drawLine(origin, origin + Offset(cornerLen * dx, 0), paint);
      canvas.drawLine(origin, origin + Offset(0, cornerLen * dy), paint);
    }
  }

  static const cornerLen = 18.0;
}

class _MarqueeLabel extends Component with HasGameReference<ShowcaseGame> {
  _MarqueeLabel({required this.fullText, required this.y});

  final String fullText;
  final double y;
  late TextComponent _text;
  double _offset = 0;

  @override
  Future<void> onLoad() async {
    _text = TextComponent(
      text: fullText,
      position: Vector2(0, y),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
    add(_text);
    _offset = game.size.x;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _offset -= dt * 60;
    if (_offset < -_text.size.x) {
      _offset = game.size.x;
    }
    _text.position.x = _offset;
  }
}

/// 撒花粒子，供庆祝场景使用。
class ConfettiBurst extends ParticleSystemComponent {
  ConfettiBurst({required super.position}) : super(particle: _buildParticle());

  static Particle _buildParticle() {
    final random = Random();
    const colors = [
      Color(0xFF69F0AE),
      Color(0xFF40C4FF),
      Color(0xFFFFD740),
      Color(0xFFFF5252),
      Color(0xFF7C4DFF),
    ];
    return Particle.generate(
      count: 36,
      lifespan: 1.4,
      generator: (i) {
        final angle = -pi / 2 + (random.nextDouble() - 0.5) * 1.6;
        final speed = 180 + random.nextDouble() * 220;
        return CircleParticle(
          paint: Paint()..color = colors[i % colors.length],
          radius: 3 + random.nextDouble() * 3,
        )
            .accelerated(
              speed: Vector2(cos(angle), sin(angle)) * speed,
              acceleration: Vector2(0, 320),
            )
            .rotating(from: 0, to: pi * 4)
            .scaling(to: 0, curve: Curves.easeIn);
      },
    );
  }
}
