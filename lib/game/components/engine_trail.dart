import 'package:flame/components.dart';

import '../bug_out_game.dart';
import '../effects/particle_effects.dart';

/// 引擎尾焰：定时发射 Flame 粒子，展示持续型粒子动效。
class EngineTrail extends Component with HasGameReference<BugOutGame> {
  EngineTrail(this.owner);

  final PositionComponent owner;
  double _cooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;

    _cooldown -= dt;
    if (_cooldown <= 0) {
      _cooldown = 0.045;
      game.add(
        ParticleEffects.engineExhaust(
          position: owner.position + Vector2(0, owner.size.y / 2 - 4),
        ),
      );
    }
  }
}
