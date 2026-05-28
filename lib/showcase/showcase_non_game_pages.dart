import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import 'showcase_game.dart';

/// UI 动效：加载环、进度条、打字机 —— 典型 App 启动/等待场景
class UiShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    add(_sectionTitle('UI 动效', Vector2(game.size.x / 2, game.size.y * 0.14), const Color(0xFF80CBC4)));

    add(_ProgressRing(
      position: Vector2(game.size.x * 0.25, game.size.y * 0.38),
      radius: 36,
    ));
    add(_caption('加载环 · RotateEffect', Vector2(game.size.x * 0.25, game.size.y * 0.38 + 58)));

    add(_LoadingBar(position: Vector2(game.size.x * 0.72, game.size.y * 0.38)));
    add(_caption('进度条 · SizeEffect 循环', Vector2(game.size.x * 0.72, game.size.y * 0.38 + 58)));

    add(_TypewriterLabel(
      fullText: 'Flame 也能做 UI 动效',
      position: Vector2(game.size.x / 2, game.size.y * 0.58),
    ));
    add(_caption('打字机文本 · TimerComponent', Vector2(game.size.x / 2, game.size.y * 0.58 + 36)));

    add(_SkeletonBlock(
      position: Vector2(game.size.x / 2, game.size.y * 0.76),
      size: Vector2(game.size.x * 0.7, 56),
    ));
    add(_caption('骨架屏脉冲 · OpacityEffect', Vector2(game.size.x / 2, game.size.y * 0.76 + 44)));
  }
}

class _ProgressRing extends PositionComponent {
  _ProgressRing({required super.position, required this.radius})
      : super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  final double radius;
  double _sweep = 0;

  @override
  Future<void> onLoad() async {
    add(
      RotateEffect.by(
        pi * 2,
        EffectController(duration: 2.5, infinite: true),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sweep = (_sweep + dt * 1.8) % (pi * 2);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      -pi / 2,
      _sweep.clamp(0.5, pi * 1.75),
      false,
      Paint()
        ..color = const Color(0xFF69F0AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }
}

class _LoadingBar extends PositionComponent {
  _LoadingBar({required super.position})
      : super(size: Vector2(140, 10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.1),
        anchor: Anchor.center,
        position: size / 2,
        children: [
          RectangleComponent(
            size: Vector2(size.x * 0.35, size.y),
            paint: Paint()..color = const Color(0xFF40C4FF),
            anchor: Anchor.centerLeft,
            position: Vector2(0, size.y / 2),
          )..add(
              SequenceEffect([
                SizeEffect.to(
                  Vector2(size.x, size.y),
                  EffectController(duration: 1.6, curve: Curves.easeInOut),
                ),
                SizeEffect.to(
                  Vector2(size.x * 0.15, size.y),
                  EffectController(duration: 0.4, curve: Curves.easeIn),
                ),
              ], infinite: true),
            ),
        ],
      ),
    );
  }
}

class _TypewriterLabel extends TextComponent {
  _TypewriterLabel({required this.fullText, required super.position})
      : super(
          text: '',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        );

  final String fullText;
  double _timer = 0;
  int _visible = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= 0.07 && _visible < fullText.length) {
      _timer = 0;
      _visible++;
      text = fullText.substring(0, _visible);
    }
    if (_visible >= fullText.length) {
      _timer += dt;
      if (_timer > 2.5) {
        _timer = 0;
        _visible = 0;
        text = '';
      }
    }
  }
}

class _SkeletonBlock extends RectangleComponent {
  _SkeletonBlock({required super.position, required super.size})
      : super(
          paint: Paint()..color = Colors.white.withValues(alpha: 0.12),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(
      OpacityEffect.to(
        0.35,
        EffectController(
          duration: 0.9,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}

/// 数据可视化动效：柱状图、数字滚动、路径运动
class ChartShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    add(_sectionTitle('数据 / 信息动效', Vector2(game.size.x / 2, game.size.y * 0.14), const Color(0xFFFFAB40)));

    add(_AnimatedCounter(position: Vector2(game.size.x / 2, game.size.y * 0.28)));
    add(_caption('数字滚动 · FunctionEffect', Vector2(game.size.x / 2, game.size.y * 0.28 + 36)));

    add(_AnimatedBarChart(
      position: Vector2(game.size.x / 2, game.size.y * 0.52),
      chartSize: Vector2(game.size.x * 0.72, 140),
    ));
    add(_caption('柱状图入场 · 交错 ScaleEffect', Vector2(game.size.x / 2, game.size.y * 0.52 + 88)));

    add(_PathFollower());
    add(_caption('路径动画 · MoveAlongPathEffect', Vector2(game.size.x / 2, game.size.y * 0.82)));
  }
}

class _AnimatedBarChart extends PositionComponent {
  _AnimatedBarChart({required super.position, required this.chartSize})
      : super(size: chartSize, anchor: Anchor.center);

  final Vector2 chartSize;
  static const _values = [0.55, 0.85, 0.45, 0.95, 0.65];
  static const _colors = [
    Color(0xFF69F0AE),
    Color(0xFF40C4FF),
    Color(0xFF7C4DFF),
    Color(0xFFFFD740),
    Color(0xFFFF5252),
  ];

  @override
  Future<void> onLoad() async {
    final barWidth = chartSize.x / (_values.length * 2);
    for (var i = 0; i < _values.length; i++) {
      final targetH = chartSize.y * _values[i];
      final bar = RectangleComponent(
        size: Vector2(barWidth, targetH),
        paint: Paint()..color = _colors[i],
        anchor: Anchor.bottomCenter,
        position: Vector2(barWidth + i * barWidth * 2, chartSize.y),
        scale: Vector2(1, 0.01),
      );
      bar.add(
        ScaleEffect.to(
          Vector2(1, 1),
          EffectController(
            duration: 0.7,
            curve: Curves.easeOutBack,
            startDelay: i * 0.12,
          ),
        ),
      );
      add(bar);
    }

    add(
      TimerComponent(
        period: 4,
        repeat: true,
        onTick: _replay,
      ),
    );
  }

  void _replay() {
    if (parent == null) return;
    for (final bar in children.whereType<RectangleComponent>()) {
      bar.scale = Vector2(1, 0.01);
      bar.add(
        ScaleEffect.to(
          Vector2(1, 1),
          EffectController(duration: 0.7, curve: Curves.easeOutBack),
        ),
      );
    }
  }
}

class _AnimatedCounter extends TextComponent {
  _AnimatedCounter({required super.position})
      : super(
          text: '0',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD740),
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    _runCountUp();
    add(
      TimerComponent(
        period: 3.5,
        repeat: true,
        onTick: _runCountUp,
      ),
    );
  }

  void _runCountUp() {
    if (parent == null) return;
    text = '0';
    add(
      FunctionEffect<TextComponent>(
        (_, progress) => text = (progress * 9876).round().toString(),
        EffectController(duration: 2.5, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _PathFollower extends Component with HasGameReference<ShowcaseGame> {
  @override
  Future<void> onLoad() async {
    final path = Path()
      ..moveTo(game.size.x * 0.12, game.size.y * 0.68)
      ..quadraticBezierTo(
        game.size.x * 0.5,
        game.size.y * 0.58,
        game.size.x * 0.88,
        game.size.y * 0.68,
      );

    add(_PathGuide(path: path));

    final dot = CircleComponent(
      radius: 8,
      paint: Paint()..color = const Color(0xFF69F0AE),
      anchor: Anchor.center,
    );
    dot.add(
      MoveAlongPathEffect(
        path,
        EffectController(
          duration: 3,
          infinite: true,
          alternate: true,
          curve: Curves.easeInOut,
        ),
        absolute: true,
        oriented: true,
      ),
    );
    add(dot);
  }
}

class _PathGuide extends Component {
  _PathGuide({required this.path});

  final Path path;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

/// 交互动效：拖拽卡片、点击涟漪、色相循环
class GestureShowcasePage extends ShowcasePage {
  @override
  Future<void> onLoad() async {
    add(_sectionTitle('交互 / 手势动效', Vector2(game.size.x / 2, game.size.y * 0.14), const Color(0xFFCE93D8)));

    add(_DraggableCard(
      position: Vector2(game.size.x / 2, game.size.y * 0.42),
      cardSize: Vector2(game.size.x * 0.55, 110),
    ));
    add(_caption('拖拽卡片 · DragCallbacks', Vector2(game.size.x / 2, game.size.y * 0.42 + 78)));

    add(_HueOrb(position: Vector2(game.size.x * 0.22, game.size.y * 0.72)));
    add(_caption('色相循环 · ColorEffect', Vector2(game.size.x * 0.22, game.size.y * 0.72 + 40)));

    add(_ParallaxStrip(position: Vector2(0, game.size.y * 0.86), stripWidth: game.size.x));
    add(_caption('视差条带 · 多层速度差', Vector2(game.size.x / 2, game.size.y * 0.92)));

    add(
      TextComponent(
        text: '点击屏幕产生涟漪',
        anchor: Anchor.center,
        position: Vector2(game.size.x * 0.72, game.size.y * 0.72),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _DraggableCard extends PositionComponent with DragCallbacks {
  _DraggableCard({required super.position, required this.cardSize})
      : super(size: cardSize, anchor: Anchor.center);

  final Vector2 cardSize;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
        children: [
          TextComponent(
            text: '拖我',
            anchor: Anchor.center,
            position: size / 2,
            textRenderer: TextPaint(
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )..add(
          ScaleEffect.by(
            Vector2.all(0.03),
            EffectController(
              duration: 1.2,
              alternate: true,
              infinite: true,
              curve: Curves.easeInOut,
            ),
          ),
        ),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    add(
      ScaleEffect.by(
        Vector2.all(0.06),
        EffectController(duration: 0.12, curve: Curves.easeOut),
      ),
    );
  }
}

class _HueOrb extends CircleComponent {
  _HueOrb({required super.position})
      : super(
          radius: 26,
          paint: Paint()..color = const Color(0xFF69F0AE),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(
      ColorEffect(
        const Color(0xFF7C4DFF),
        EffectController(
          duration: 2.5,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
    add(
      ScaleEffect.by(
        Vector2.all(0.2),
        EffectController(duration: 1.8, alternate: true, infinite: true),
      ),
    );
  }
}

class _ParallaxStrip extends PositionComponent {
  _ParallaxStrip({required super.position, required this.stripWidth})
      : super(size: Vector2(stripWidth, 48));

  final double stripWidth;
  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset += dt * 40;
  }

  @override
  void render(Canvas canvas) {
    for (var layer = 0; layer < 3; layer++) {
      final speed = 1 + layer * 0.6;
      final y = 8 + layer * 12.0;
      final color = [
        const Color(0xFF69F0AE),
        const Color(0xFF40C4FF),
        const Color(0xFF7C4DFF),
      ][layer];
      final dashW = 28.0 + layer * 8;
      var x = -(_offset * speed) % (dashW * 2);
      while (x < stripWidth) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, dashW, 4),
            const Radius.circular(2),
          ),
          Paint()..color = color.withValues(alpha: 0.35 + layer * 0.15),
        );
        x += dashW * 2;
      }
    }
  }
}

/// 点击涟漪，用于手势交互演示。
class TapRipple extends CircleComponent {
  TapRipple({required super.position})
      : super(
          radius: 12,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0xFF69F0AE).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );

  @override
  Future<void> onLoad() async {
    add(
      ScaleEffect.to(
        Vector2.all(6),
        EffectController(duration: 0.55, curve: Curves.easeOut),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.55),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}

TextComponent _sectionTitle(String text, Vector2 position, Color color) {
  return TextComponent(
    text: text,
    anchor: Anchor.center,
    position: position,
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
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
