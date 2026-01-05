import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

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

void main() async {
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

  // Web 端预加载优化：等待首帧渲染完成
  if (kIsWeb) {
    // 确保 Flutter 引擎完全初始化
    await Future.delayed(const Duration(milliseconds: 100));
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 应用初始化状态 Provider
final appInitializedProvider = StateProvider<bool>((ref) => false);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Web 端：等待首帧渲染后标记为已初始化
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            ref.read(appInitializedProvider.notifier).state = true;
          }
        });
      });
    } else {
      // 非 Web 端：立即标记为已初始化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(appInitializedProvider.notifier).state = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = ref.watch(appInitializedProvider);
    
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
      home: isInitialized 
        ? const FLHomePage()
        : const _AppLoadingScreen(),
    );
  }
}

// 应用加载屏幕（Flutter 内部的 Loading，作为 HTML Loading 的备用）
class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
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
  late PageController _pageController;
  late AnimationController _textAnimationController;

  @override
  void initState() {
    super.initState();
    // 根据平台判断是否是手机端（最可靠），非Web端就是移动设备
    final bool isMobile = !kIsWeb;
    _pageController = PageController(
      viewportFraction: isMobile ? 0.68 : 0.55,
      initialPage: 0,
    );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算item高度为屏幕的2/3
        final double screenHeight = MediaQuery.of(context).size.height;
        final double itemHeight = screenHeight * 2 / 3;
        
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

            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: itemHeight,
                child: RepaintBoundary(
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
                ),
              ),
            );
          },
          child: _GalleryCard(index: index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根据平台判断是否是手机端（最可靠），非Web端就是移动设备
    final bool isMobile = !kIsWeb;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // 计算画廊高度为屏幕的2/3
    final double galleryHeight = screenHeight * 2 / 3;
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: ScrollConfiguration(
        behavior: MouseDragScrollBehavior(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 画廊区域 - 固定高度，居中
              Padding(
                padding: EdgeInsets.only(
                  left: isMobile ? 0.0 : 20.0,
                  right: isMobile ? 0.0 : 20.0,
                  top: isMobile ? 0.0 : 20.0,
                ),
                child: SizedBox(
                  height: galleryHeight,
                  width: double.infinity,
                  child: NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    // 当滚动结束时，自动居中到最近的页面
                    if (_pageController.hasClients) {
                      final double currentPage = _pageController.page ?? 0.0;
                      final int targetPage = currentPage.round().clamp(0, itemCount - 1);
                      
                      // 如果当前页面与目标页面不一致，则滚动到目标页面
                      if (targetPage != currentPage.round()) {
                        _pageController.animateToPage(
                          targetPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    }
                    return true;
                  },
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
              ),
              // 文字区域 - 距离画廊15，居中显示
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 15.0, // 画廊和文案之间的间距
                  bottom: isMobile ? 0.0 : 8.0,
                ),
                child: _ColorizeWaveText(
                text: 'Mercedes-Benz W126',
                animationController: _textAnimationController,
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  fontSize: MediaQuery.of(context).size.width < 600 ? 22 : 28,
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
                ),
              ),
            ],
          ),
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
      // 延迟初始化视频，确保 context 可用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeVideo();
        }
      });
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // 根据平台判断是否是手机端（最可靠），非Web端就是移动设备
      final bool isMobile = !kIsWeb;
      final String videoPath = isMobile 
          ? 'assets/videos/w126_city_phone.mp4' 
          : 'assets/videos/w126_city.mp4';
      _videoController = VideoPlayerController.asset(videoPath);
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
    
    // 根据平台判断是否是手机端（最可靠），非Web端就是移动设备
    final bool isMobile = !kIsWeb;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 2,
        vertical: isMobile ? 0 : 8, // 手机端移除垂直margin
      ),
      width: double.infinity,
      height: double.infinity, // 填充父容器的高度（已在_build3DCard中设置为屏幕的2/3）
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
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFFFFFFF), // 确保白色背景填充整个容器
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
    );
  }
}

// Colorize 模式的波浪文字动画组件
class _ColorizeWaveText extends StatelessWidget {
  final String text;
  final AnimationController animationController;
  final TextStyle textStyle;

  const _ColorizeWaveText({
    required this.text,
    required this.animationController,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Colorize 颜色列表：银色到白色的渐变
    final List<Color> colors = [
      Colors.grey.shade400,  // 银色
      Colors.grey.shade300,
      Colors.grey.shade200,
      Colors.grey.shade100,
      Colors.white,
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,  // 回到银色
    ];

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final double rawValue = animationController.value;
        
        // 判断是否在最后显示白色阶段
        final bool isFinalWhite = rawValue >= 5.0 / 6.0;
        
        return Text.rich(
          TextSpan(
            children: List.generate(text.length, (index) {
              Color currentColor;
              
              if (isFinalWhite) {
                // 最后阶段：所有字符都是白色
                currentColor = Colors.white;
              } else {
                // Colorize 波浪阶段：颜色从左到右波浪式移动
                final double waveDuration = 5.0 / 6.0; // 波浪动画占5/6的时间
                final double normalizedProgress = rawValue / waveDuration;
                
                // 计算该字符在波浪中的位置
                // 从左到右，每个字符有偏移，形成波浪效果
                final double charOffset = index / text.length;
                final double wavePosition = (normalizedProgress * 2.0 + charOffset) % 2.0;
                
                // 将波浪位置映射到颜色列表索引
                final double colorProgress = wavePosition / 2.0;
                final double colorIndex = colorProgress * (colors.length - 1);
                
                // 获取当前颜色和下一个颜色进行插值
                final int colorIndexFloor = colorIndex.floor();
                final int colorIndexCeil = (colorIndex.ceil()).clamp(0, colors.length - 1);
                final double lerpValue = colorIndex - colorIndexFloor;
                
                // 颜色插值，实现平滑的 Colorize 效果
                currentColor = Color.lerp(
                  colors[colorIndexFloor.clamp(0, colors.length - 1)],
                  colors[colorIndexCeil],
                  lerpValue,
                ) ?? Colors.white;
              }

              return TextSpan(
                text: text[index],
                style: textStyle.copyWith(
                  color: currentColor,
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
