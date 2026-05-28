import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../bug_out_game.dart';

/// 相机震动封装，使用 MoveByEffect 叠加实现屏幕抖动。
class CameraShake {
  static void shake(BugOutGame game, {double intensity = 12, int pulses = 5}) {
    for (var i = 0; i < pulses; i++) {
      final factor = 1 - i / pulses;
      game.camera.viewfinder.add(
        MoveByEffect(
          Vector2(
            (i.isEven ? 1 : -1) * intensity * factor * 0.6,
            (i.isOdd ? 1 : -1) * intensity * factor * 0.4,
          ),
          EffectController(
            duration: 0.04,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }
}

/// Boss 登场时的全屏闪光环，展示 ScaleEffect + OpacityEffect 组合。
class ShockwaveRing extends CircleComponent with HasGameReference<BugOutGame> {
  ShockwaveRing({required super.position})
      : super(
          radius: 8,
          paint: Paint()
            ..color = const Color(0xFFFFD740).withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(18),
          EffectController(duration: 0.6, curve: Curves.easeOut),
        ),
        RemoveEffect(),
      ]),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.6),
      ),
    );
  }
}
