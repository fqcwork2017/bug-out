import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _FLHomePageState extends State<FLHomePage> {
  static const int itemCount = 10; // 画廊数量为 10
  final PageController _pageController = PageController(viewportFraction: 0.55, initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final int index;
  const _GalleryCard({required this.index});

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
            child: Container(
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
