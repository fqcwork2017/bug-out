import 'package:flutter/material.dart';

import 'showcase_game.dart';

class ShowcaseOverlay extends StatelessWidget {
  const ShowcaseOverlay({super.key, required this.game});

  final ShowcaseGame game;

  @override
  Widget build(BuildContext context) {
    final sectionCount = ShowcaseSection.values.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: '返回',
                ),
                const Spacer(),
                Text(
                  game.sectionName,
                  style: const TextStyle(
                    color: Color(0xFF69F0AE),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: game.previousSection,
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                ),
                IconButton(
                  onPressed: game.nextSection,
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sectionCount, (index) {
                final active = index == game.section.index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF69F0AE)
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const Spacer(),
            Text(
              _hintFor(game.section),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _hintFor(ShowcaseSection section) {
    return switch (section) {
      ShowcaseSection.sprites =>
        'SpriteAnimation · 运行时精灵图集\n点击切换 · 左右滑动 · 12 秒自动轮播',
      ShowcaseSection.particles =>
        'Particle.generate · 组合加速/缩放粒子',
      ShowcaseSection.effects =>
        'Scale / Rotate / Opacity\n点击触发 ShockwaveRing',
      ShowcaseSection.ui =>
        '加载环 · 进度条 · 打字机 · 骨架屏\n典型 App UI 等待动效',
      ShowcaseSection.chart =>
        'FunctionEffect 数字滚动 · 柱状图入场\nMoveAlongPathEffect 路径动画',
      ShowcaseSection.gesture =>
        'DragCallbacks 拖拽 · ColorEffect 变色\n点击产生 TapRipple 涟漪',
      ShowcaseSection.splash =>
        'Splash 启动页 · Logo 弹性入场\nSlogan 淡入 · 跳过按钮呼吸',
      ShowcaseSection.feedback =>
        '成功 ✓ 描边 · 失败抖动\nToast 滑入 · 通知角标脉冲',
      ShowcaseSection.celebrate =>
        '成就卡弹入 · Confetti 撒花\n点击屏幕触发庆祝粒子',
      ShowcaseSection.media =>
        '音频波形 · 扫码扫描线\nMarquee 跑马灯 Banner',
      ShowcaseSection.ambient =>
        '雨 · 雪 · 气泡氛围粒子\n点击屏幕生成气泡',
      ShowcaseSection.motion =>
        '钟摆 · 轨道卫星 · 弹簧球\n物理感循环运动',
      ShowcaseSection.transform =>
        'GlowEffect 外发光 · 雷达扫描\n点击卡片翻转',
      ShowcaseSection.network =>
        '节点拓扑图 · 连线/节点呼吸脉冲',
    };
  }
}
