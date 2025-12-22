import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 尝试进入沉浸式（移动端生效，浏览器表现有限）
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

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
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bug Out - 3D Gallery',
      theme: theme,
      home: const FLHomePage(title: 'FL 3D Gallery'),
    );
  }
}

class FLHomePage extends StatefulWidget {
  const FLHomePage({super.key, required this.title});
  final String title;

  @override
  State<FLHomePage> createState() => _FLHomePageState();
}

class _FLHomePageState extends State<FLHomePage> {
  static const int itemCount = 10; // 画廊数量为 10
  final PageController _pageController = PageController(viewportFraction: 0.66, initialPage: 0);

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
        final double rotationY = (delta.clamp(-1.0, 1.0)) * 0.8;
        final double scale = (1 - (delta.abs() * 0.12)).clamp(0.88, 1.0);

        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 透视
          ..translate(delta * 24.0) // ignore: deprecated_member_use
          ..rotateY(rotationY);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Opacity(
            opacity: (1 - (delta.abs() * 0.25)).clamp(0.4, 1.0),
            child: Transform.scale(
              scale: scale,
              child: child,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 48),
            SizedBox(
              height: 440,
              child: PageView.builder(
                controller: _pageController,
                itemCount: itemCount,
                padEnds: true,
                itemBuilder: (context, index) => _build3DCard(index),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                int current = _pageController.hasClients
                    ? (_pageController.page ?? _pageController.initialPage).round()
                    : _pageController.initialPage;
                return Text(
                  '${current + 1} / $itemCount',
                  style: const TextStyle(color: Colors.white70),
                );
              },
            ),
            const Expanded(child: SizedBox.shrink()), // 其余内容暂为空白
          ],
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              // 内容暂为空白（占位）
              child: Text(
                '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
