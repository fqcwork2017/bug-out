import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/bullet.dart';
import 'components/enemy.dart';
import 'components/player.dart';
import 'components/star_field.dart';
import 'effects/animated_text.dart';
import 'effects/camera_shake.dart';
import 'effects/particle_effects.dart';

enum GameState { menu, playing, paused, gameOver }

class BugOutGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks, DragCallbacks {
  BugOutGame();

  static const overlayMenu = 'menu';
  static const overlayHud = 'hud';
  static const overlayGameOver = 'gameOver';
  static const overlayPause = 'pause';

  GameState state = GameState.menu;
  int score = 0;
  int highScore = 0;
  int lives = 3;
  int wave = 1;
  int combo = 0;
  double comboTimer = 0;
  int enemiesRemaining = 0;
  int enemiesSpawned = 0;
  int enemiesToSpawn = 0;

  late Player player;
  late StarField starField;

  double _fireCooldown = 0;
  double _spawnCooldown = 0;
  final Random _random = Random();
  final ValueNotifier<int> hudTick = ValueNotifier(0);

  final Set<LogicalKeyboardKey> _pressedKeys = {};

  void refreshHud() => hudTick.value++;

  double get fireInterval => max(0.08, 0.22 - wave * 0.008);

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    starField = StarField();
    add(starField);

    player = Player();
    add(player);

    overlays.add(overlayMenu);
  }

  void startGame() {
    score = 0;
    lives = 3;
    wave = 1;
    combo = 0;
    comboTimer = 0;
    state = GameState.playing;

    children.whereType<Enemy>().forEach(remove);
    children.whereType<Bullet>().forEach(remove);
    children.whereType<ParticleSystemComponent>().forEach(remove);
    children.whereType<WaveBanner>().forEach(remove);
    children.whereType<ComboPopup>().forEach(remove);
    children.whereType<ShockwaveRing>().forEach(remove);

    player.reset();
    _startWave();

    overlays.remove(overlayMenu);
    overlays.remove(overlayGameOver);
    overlays.remove(overlayPause);
    overlays.add(overlayHud);
    refreshHud();
  }

  void _startWave() {
    enemiesSpawned = 0;
    enemiesToSpawn = 6 + wave * 3;
    enemiesRemaining = enemiesToSpawn;
    _spawnCooldown = 0.4;
    add(WaveBanner(waveText: 'WAVE $wave'));
    if (wave % 5 == 0) {
      add(ShockwaveRing(position: size / 2));
    }
    refreshHud();
  }

  void nextWave() {
    wave++;
    _startWave();
  }

  void addScore(int points) {
    combo++;
    comboTimer = 2.5;
    final multiplier = 1 + (combo ~/ 5);
    score += points * multiplier;
    if (score > highScore) {
      highScore = score;
    }
    if (combo >= 5 && combo % 5 == 0) {
      add(ComboPopup(
        text: 'COMBO x$combo',
        position: player.position + Vector2(0, -50),
      ));
    }
    refreshHud();
  }

  void resetCombo() {
    combo = 0;
    comboTimer = 0;
    refreshHud();
  }

  void damagePlayer() {
    if (state != GameState.playing) return;

    lives--;
    CameraShake.shake(this);
    resetCombo();
    player.flash();

    refreshHud();
    if (lives <= 0) {
      gameOver();
    }
  }

  void gameOver() {
    state = GameState.gameOver;
    overlays.remove(overlayHud);
    overlays.remove(overlayPause);
    overlays.add(overlayGameOver);
  }

  void togglePause() {
    if (state == GameState.playing) {
      state = GameState.paused;
      overlays.add(overlayPause);
      pauseEngine();
    } else if (state == GameState.paused) {
      state = GameState.playing;
      overlays.remove(overlayPause);
      resumeEngine();
    }
  }

  void spawnEnemy() {
    final size = Vector2(36 + _random.nextDouble() * 8, 36 + _random.nextDouble() * 8);
    final x = size.x / 2 + _random.nextDouble() * (this.size.x - size.x);
    final kind = _pickEnemyKind();
    add(Enemy(kind: kind, position: Vector2(x, -size.y), size: size));
    enemiesSpawned++;
  }

  EnemyKind _pickEnemyKind() {
    if (wave % 5 == 0 && enemiesSpawned == enemiesToSpawn - 1) {
      return EnemyKind.boss;
    }
    final roll = _random.nextDouble();
    if (wave >= 4 && roll < 0.15) return EnemyKind.tank;
    if (wave >= 2 && roll < 0.35) return EnemyKind.zigzag;
    return EnemyKind.normal;
  }

  void fireBullet() {
    if (state != GameState.playing) return;
    add(Bullet(
      position: player.position + Vector2(0, -player.size.y / 2 - 4),
      velocity: Vector2(0, -520),
      damage: 1,
      fromPlayer: true,
    ));
  }

  void spawnHitSparks(Vector2 position) {
    add(ParticleEffects.hitSparks(position: position));
  }

  void enemyDestroyed(Enemy enemy) {
    addScore(enemy.kind.scoreValue);
    if (enemy.kind == EnemyKind.boss) {
      add(ParticleEffects.bossExplosion(
        position: enemy.position.clone(),
        color: enemy.kind.color,
      ));
      CameraShake.shake(this, intensity: 18, pulses: 7);
    } else {
      add(ParticleEffects.explosion(
        position: enemy.position.clone(),
        color: enemy.kind.color,
      ));
    }
    enemy.removeFromParent();
    enemiesRemaining--;

    if (enemiesRemaining <= 0 && enemiesSpawned >= enemiesToSpawn) {
      nextWave();
    }
    refreshHud();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state != GameState.playing) return;

    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) resetCombo();
    }

    _handleKeyboardMovement(dt);
    _handleKeyboardFire(dt);

    _fireCooldown -= dt;
    if (_fireCooldown <= 0) {
      fireBullet();
      _fireCooldown = fireInterval;
    }

    if (enemiesSpawned < enemiesToSpawn) {
      _spawnCooldown -= dt;
      if (_spawnCooldown <= 0) {
        spawnEnemy();
        _spawnCooldown = max(0.25, 1.1 - wave * 0.06);
      }
    }
  }

  void _handleKeyboardMovement(double dt) {
    var direction = Vector2.zero();
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      direction.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      direction.x += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      direction.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      direction.y += 1;
    }
    if (direction.length2 > 0) {
      player.moveByDirection(direction.normalized(), dt);
    }
  }

  void _handleKeyboardFire(double dt) {
    // Auto-fire handles shooting; space could trigger rapid burst in future.
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _pressedKeys
      ..clear()
      ..addAll(keysPressed);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        if (state == GameState.playing || state == GameState.paused) {
          togglePause();
          return KeyEventResult.handled;
        }
      }
      if (state == GameState.menu &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space)) {
        startGame();
        return KeyEventResult.handled;
      }
      if (state == GameState.gameOver &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        startGame();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (state == GameState.menu) {
      startGame();
    } else if (state == GameState.gameOver) {
      startGame();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (state != GameState.playing) return;
    player.moveByDelta(event.localDelta);
  }
}
