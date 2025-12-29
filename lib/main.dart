import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// 自定义滚动行为，支持鼠标拖拽
class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 尝试进入沉浸式（移动端生效，浏览器表现有限）
  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 极夜黑主题
    final theme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF000000),
        primary: Color(0xFF000000),
      ),
      // 使用系统字体，避免从外部加载 Roboto
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: kIsWeb 
          ? '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
          : null,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bug Out - 3D Gallery',
      theme: theme,
      scrollBehavior: MouseDragScrollBehavior(),
      home: const FLHomePage(),
    );
  }
}

class FLHomePage extends StatefulWidget {
  const FLHomePage({super.key});

  @override
  State<FLHomePage> createState() => _FLHomePageState();
}

class _FLHomePageState extends State<FLHomePage> with TickerProviderStateMixin {
  static const int itemCount = 10; // 画廊数量为 10
  final PageController _pageController = PageController(viewportFraction: 0.55, initialPage: 0);
  late AnimationController _textAnimationController;

  @override
  void initState() {
    super.initState();
    // 动画时长：基础动画5秒 + 暂停1秒 = 6秒
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), // 进一步减慢动画速度，包含1秒暂停
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  Widget _build3DCard(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = _pageController.hasClients && _pageController.position.haveDimensions
            ? (_pageController.page ?? _pageController.initialPage.toDouble())
            : _pageController.initialPage.toDouble();
        final double delta = (index - page);
        // 进一步减小旋转角度，避免圆角变形
        final double rotationY = (delta.clamp(-1.0, 1.0)) * 0.5;
        final double scale = (1 - (delta.abs() * 0.12)).clamp(0.88, 1.0);

        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0006) // 进一步调整透视参数，减少变形
          ..translate(delta * 20.0) // ignore: deprecated_member_use, 减小偏移量
          ..rotateY(rotationY);

        return RepaintBoundary(
          // 使用 RepaintBoundary 优化渲染性能
          child: ClipRRect(
            // 在变换之前裁剪，确保圆角在 3D 变换时保持正确
            borderRadius: BorderRadius.circular(16),
            child: Transform(
              transform: transform,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high, // 提高渲染质量
              child: Opacity(
                opacity: (1 - (delta.abs() * 0.25)).clamp(0.4, 1.0),
                child: Transform.scale(
                  scale: scale,
                  filterQuality: FilterQuality.high, // 提高渲染质量
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _GalleryCard(index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: ScrollConfiguration(
        behavior: MouseDragScrollBehavior(),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: MediaQuery.of(context).size.height < 700 ? 0.0 : 20.0, // 手机端移除上下间距，让画廊占满
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: itemCount,
                  padEnds: true,
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  physics: const PageScrollPhysics(),
                  itemBuilder: (context, index) => _build3DCard(index),
                ),
              ),
            ),
            // 画廊下方中央文案
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height < 700 ? 0.0 : 16.0, // 手机端紧挨画廊
              ),
              child: _CharacterByCharacterColorizeText(
                text: 'Mercedes-Benz W126',
                animationController: _textAnimationController,
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  fontSize: MediaQuery.of(context).size.width < 600 ? 22 : 28, // 手机端减小字体
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.grey.shade400,
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.grey.shade600,
                      offset: Offset(0, 0),
                    ),
                  ],
                ) ?? TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  fontSize: MediaQuery.of(context).size.width < 600 ? 22 : 28,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.grey,
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.grey,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                colors: [
                  Colors.white,
                  Colors.grey.shade100,
                  Colors.grey.shade600,
                  Colors.white,
                  Colors.grey.shade500,
                  Colors.grey.shade200,
                  Colors.white,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatefulWidget {
  final int index;
  const _GalleryCard({required this.index});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // 第一个 item (index == 0) 加载视频
    if (widget.index == 0) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/w126_city.mp4');
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        // 自动播放并循环
        _videoController!.setLooping(true);
        _videoController!.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 16.0; // 统一的圆角值
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        width: double.infinity,
        clipBehavior: Clip.antiAlias, // 确保圆角正确裁剪
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // 明确设置为白色
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)), // 四个角都使用相同的圆角
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            // 确保内部内容也遵循圆角
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: widget.index == 0 && _isVideoInitialized && _videoController != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      // 视频播放器
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      // 点击控制播放/暂停
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  )
                : widget.index == 0 && !_isVideoInitialized
                    ? Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        clipBehavior: Clip.antiAlias, // 确保内部圆角正确裁剪
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), // 再次确保内部也是白色
                          borderRadius: BorderRadius.all(Radius.circular(borderRadius)), // 四个角都使用相同的圆角
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            // 内容暂为空白（占位）
                            child: Text(
                              '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.black, // 文本颜色设为黑色以便在白色背景上可见
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

// 从左到右逐个字符变化的颜色动画组件
class _CharacterByCharacterColorizeText extends StatelessWidget {
  final String text;
  final AnimationController animationController;
  final TextStyle textStyle;
  final List<Color> colors;

  const _CharacterByCharacterColorizeText({
    required this.text,
    required this.animationController,
    required this.textStyle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Text.rich(
          TextSpan(
            children: List.generate(text.length, (index) {
              final double rawValue = animationController.value;
              final bool isLastChar = index == text.length - 1;
              
              Color currentColor;
              double intensity;
              
              if (rawValue >= 5.0 / 6.0) {
                // 暂停阶段：所有字符都是白色（最后1/6的时间，即1秒）
                intensity = 1.0;
                currentColor = Colors.white;
              } else {
                // 波浪动画阶段
                final double waveDuration = 4.0 / 6.0; // 波浪动画占4/6的时间
                final int totalChars = text.length;
                final int waveChars = totalChars - 1; // 除最后一个字外的字符数
                
                if (isLastChar) {
                  // 最后一个字：当其他字都变白后才开始变白
                  final double lastCharStartTime = waveDuration * 0.85; // 在85%时开始变白
                  
                  if (rawValue < lastCharStartTime) {
                    // 最后一个字保持银色
                    intensity = 0.0;
                    currentColor = Colors.grey.shade400;
                  } else {
                    // 最后一个字开始变白
                    final double lastCharProgress = (rawValue - lastCharStartTime) / (5.0 / 6.0 - lastCharStartTime);
                    intensity = lastCharProgress.clamp(0.0, 1.0);
                    currentColor = Color.lerp(
                      Colors.grey.shade400,
                      Colors.white,
                      intensity,
                    )!;
                  }
                } else {
                  // 除最后一个字外：每个字在特定时间段变白，下一个字开始时立即变回银色
                  // 计算每个字符变白的开始时间和持续时间
                  final double charStartProgress = index / waveChars; // 从左到右的顺序
                  final double charDuration = 1.0 / waveChars; // 每个字符占用的时间比例
                  final double charStartTime = charStartProgress * waveDuration;
                  final double charEndTime = charStartTime + charDuration * waveDuration;
                  
                  if (rawValue < charStartTime) {
                    // 还没轮到，保持银色
                    intensity = 0.0;
                    currentColor = Colors.grey.shade400;
                  } else if (rawValue >= charEndTime) {
                    // 已经过了变白时间，立即变回银色
                    intensity = 0.0;
                    currentColor = Colors.grey.shade400;
                  } else {
                    // 变白过程中
                    final double charProgress = (rawValue - charStartTime) / (charEndTime - charStartTime);
                    intensity = charProgress.clamp(0.0, 1.0);
                    currentColor = Color.lerp(
                      Colors.grey.shade400, // 银色
                      Colors.white, // 白色
                      intensity,
                    )!;
                  }
                }
              }

              return TextSpan(
                text: text[index],
                style: textStyle.copyWith(
                  color: currentColor,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0 * intensity,
                      color: Colors.white.withOpacity(intensity * 0.8),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              );
            }),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
