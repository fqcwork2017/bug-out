import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../bug_out_game.dart';

/// 使用 TextComponent + SequenceEffect 实现波次提示动效。
class WaveBanner extends TextComponent with HasGameReference<BugOutGame> {
  WaveBanner({required String waveText})
      : super(
          text: waveText,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
              color: Colors.white,
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 2, game.size.y * 0.28);
    scale = Vector2.zero();

    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.15),
          EffectController(duration: 0.45, curve: Curves.elasticOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(0.6),
          EffectController(duration: 0.5, curve: Curves.easeIn),
        ),
        RemoveEffect(),
      ]),
    );
  }
}

/// 连击提示：MoveByEffect 上浮 + 缩小消失。
class ComboPopup extends TextComponent with HasGameReference<BugOutGame> {
  ComboPopup({
    required super.text,
    required super.position,
  }) : super(
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD740),
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.4),
          EffectController(duration: 0.15, curve: Curves.easeOut),
        ),
        MoveByEffect(
          Vector2(0, -70),
          EffectController(duration: 0.9, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.25, curve: Curves.easeIn),
        ),
        RemoveEffect(),
      ]),
    );
  }
}
