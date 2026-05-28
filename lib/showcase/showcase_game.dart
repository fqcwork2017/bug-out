import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/components/star_field.dart';
import '../game/effects/camera_shake.dart';
import 'showcase_extra_effects.dart';
import 'showcase_more_scenes.dart';
import 'showcase_non_game_pages.dart';
import 'showcase_pages.dart';
import 'sprite_sheet_factory.dart';

enum ShowcaseSection {
  sprites,
  particles,
  effects,
  ui,
  chart,
  gesture,
  splash,
  feedback,
  celebrate,
  media,
  ambient,
  motion,
  transform,
  network,
}

class ShowcaseGame extends FlameGame with TapCallbacks, DragCallbacks {
  ShowcaseGame();

  static const overlayHud = 'hud';

  ShowcaseSection section = ShowcaseSection.sprites;
  double _autoSwitchTimer = 0;

  final ValueNotifier<int> sectionTick = ValueNotifier(0);

  late StarField _background;

  static const _sectionNames = [
    '精灵动画',
    '粒子系统',
    'Effect 动效',
    'UI 动效',
    '数据动效',
    '交互动效',
    '启动页',
    '状态反馈',
    '庆祝成就',
    '媒体工具',
    '氛围天气',
    '物理运动',
    '光效变换',
    '网络拓扑',
  ];

  String get sectionName => _sectionNames[section.index];

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await SpriteSheetFactory.preload();

    _background = StarField();
    add(_background);

    _loadSection(section);
    overlays.add(overlayHud);
  }

  void _clearSection() {
    for (final page in children.whereType<ShowcasePage>().toList()) {
      page.removeAll(page.children);
      page.removeFromParent();
    }
    children.whereType<ParticleSystemComponent>().forEach(remove);
    children.whereType<ShockwaveRing>().forEach(remove);
    children.whereType<TapRipple>().forEach(remove);
    children.whereType<ConfettiBurst>().forEach(remove);
    children.whereType<BubbleBurst>().forEach(remove);
  }

  void _loadSection(ShowcaseSection next) {
    _clearSection();
    section = next;
    _autoSwitchTimer = 0;
    sectionTick.value++;

    final page = switch (next) {
      ShowcaseSection.sprites => SpriteShowcasePage(),
      ShowcaseSection.particles => ParticleShowcasePage(),
      ShowcaseSection.effects => EffectShowcasePage(),
      ShowcaseSection.ui => UiShowcasePage(),
      ShowcaseSection.chart => ChartShowcasePage(),
      ShowcaseSection.gesture => GestureShowcasePage(),
      ShowcaseSection.splash => SplashShowcasePage(),
      ShowcaseSection.feedback => FeedbackShowcasePage(),
      ShowcaseSection.celebrate => CelebrateShowcasePage(),
      ShowcaseSection.media => MediaShowcasePage(),
      ShowcaseSection.ambient => AmbientShowcasePage(),
      ShowcaseSection.motion => MotionShowcasePage(),
      ShowcaseSection.transform => TransformShowcasePage(),
      ShowcaseSection.network => NetworkShowcasePage(),
    };
    add(page);
  }

  void nextSection() {
    final nextIndex = (section.index + 1) % ShowcaseSection.values.length;
    _loadSection(ShowcaseSection.values[nextIndex]);
  }

  void previousSection() {
    final nextIndex = (section.index - 1 + ShowcaseSection.values.length) %
        ShowcaseSection.values.length;
    _loadSection(ShowcaseSection.values[nextIndex]);
  }

  void spawnShockwave(Vector2 position) {
    add(ShockwaveRing(position: position));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _autoSwitchTimer += dt;
    if (_autoSwitchTimer >= 12) {
      nextSection();
    }
  }

  void spawnRipple(Vector2 position) {
    add(TapRipple(position: position));
  }

  void spawnConfetti() {
    add(ConfettiBurst(position: Vector2(size.x / 2, size.y * 0.55)));
  }

  @override
  void onTapUp(TapUpEvent event) {
    switch (section) {
      case ShowcaseSection.effects:
        spawnShockwave(event.localPosition);
      case ShowcaseSection.gesture:
        spawnRipple(event.localPosition);
      case ShowcaseSection.celebrate:
        spawnConfetti();
      case ShowcaseSection.ambient:
        add(BubbleBurst(position: event.localPosition));
      case ShowcaseSection.transform:
      case ShowcaseSection.motion:
      case ShowcaseSection.network:
      case ShowcaseSection.ui:
      case ShowcaseSection.chart:
      case ShowcaseSection.splash:
      case ShowcaseSection.feedback:
      case ShowcaseSection.media:
        break;
      default:
        nextSection();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (section == ShowcaseSection.gesture) return;

    final velocity = event.velocity;
    if (velocity.x.abs() > 200) {
      if (velocity.x > 0) {
        previousSection();
      } else {
        nextSection();
      }
    }
  }
}

/// 标记类，用于清理展示页内容。
abstract class ShowcasePage extends Component with HasGameReference<ShowcaseGame> {}
