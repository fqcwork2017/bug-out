import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  final CarouselSliderController _carouselController = CarouselSliderController();
  late AnimationController _textAnimationController;
  bool _disposed = false; // 添加标志防止重复 dispose

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
    if (_disposed) return; // 防止重复 dispose
    _disposed = true;
    
    _textAnimationController.stop(); // 先停止动画
    _textAnimationController.dispose();
    super.dispose();
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
              // 画廊区域 - 使用 CarouselSlider
              Padding(
                padding: EdgeInsets.only(
                  left: isMobile ? 0.0 : 20.0,
                  right: isMobile ? 0.0 : 20.0,
                  top: isMobile ? 0.0 : 20.0,
                ),
                child: SizedBox(
                  height: galleryHeight,
                  width: double.infinity,
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: itemCount,
                    itemBuilder: (context, index, realIndex) {
                      return _GalleryCard(index: index);
                    },
                    // 使用 on-demand carousel slider 效果
                    options: CarouselOptions(
                      height: galleryHeight,
                      viewportFraction: 0.9,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                      // 手指/鼠标按压时暂停轮播，可跟随滑动
                      pauseAutoPlayOnTouch: true,
                      pauseAutoPlayOnManualNavigate: true,
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
  bool _disposed = false; // 添加标志防止重复 dispose

  @override
  void initState() {
    super.initState();
    // 第一个 item (index == 0) 加载视频
    if (widget.index == 0) {
      // 延迟初始化视频，确保 context 可用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_disposed) {
          _initializeVideo();
        }
      });
    }
  }

  Future<void> _initializeVideo() async {
    if (_disposed) return; // 如果已 dispose，不再执行
    try {
      // 根据平台判断是否是手机端（最可靠），非Web端就是移动设备
      final bool isMobile = !kIsWeb;
      final String videoPath = isMobile 
          ? 'assets/videos/w126_city_phone.mp4' 
          : 'assets/videos/w126_city.mp4';
      _videoController = VideoPlayerController.asset(videoPath);
      await _videoController!.initialize();
      if (mounted && !_disposed) {
        setState(() {
          _isVideoInitialized = true;
        });
        // 自动播放并循环
        _videoController!.setLooping(true);
        _videoController!.play();
      } else {
        // 如果已经 dispose，立即清理
        _videoController?.dispose();
        _videoController = null;
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    if (_disposed) return; // 防止重复 dispose
    _disposed = true;
    
    try {
      _videoController?.pause();
      _videoController?.dispose();
      _videoController = null;
    } catch (e) {
      debugPrint('Error disposing video controller: $e');
    }
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
      height: double.infinity, // 填充父容器的高度
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
                  // 点击（非滑动）时停止轮播并进入详情页
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MercedesDetailPage(),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              )
            : widget.index == 0 && !_isVideoInitialized
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MercedesDetailPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
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

// 奔驰详情页
class MercedesDetailPage extends StatefulWidget {
  const MercedesDetailPage({super.key});

  @override
  State<MercedesDetailPage> createState() => _MercedesDetailPageState();
}

class _MercedesDetailPageState extends State<MercedesDetailPage> {
  late FlutterEarthGlobeController _globeController;
  bool _disposed = false; // 添加标志防止重复 dispose

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    // 德国位于欧洲中部：纬度 51.17°N，经度 10.45°E
    // 设置合适的初始参数以显示欧洲/德国区域
    // 使用网络图片加载地球纹理（使用可靠的地球纹理URL）
    _globeController = FlutterEarthGlobeController(
      rotationSpeed: 0.01, // 慢速旋转，方便查看
      zoom: 1.8, // 放大以便更好地查看德国及欧洲区域
      // 加载地球纹理图片
      // 使用地球纹理图片（Equirectangular投影）
      // 使用可靠的地球纹理URL
      surface: const NetworkImage(
        'https://raw.githubusercontent.com/turban/webgl-earth/master/images/2_no_clouds_4k.jpg',
      ),
      // 备选URL（如果上面的不可用）：
      // 'https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg'
      // 或者使用本地资源：Image.asset('assets/images/earth_texture.jpg')
      // 启用大气层效果，让地球更真实
      showAtmosphere: true,
      atmosphereColor: Colors.cyan,
      atmosphereOpacity: 0.7,
      atmosphereThickness: 0.15,
    );
    // 等待地球加载完成后，优化视图以突出显示德国
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && !_disposed) {
          _optimizeForGermanyView();
        }
      });
    });
  }

  // 优化视图以显示德国
  void _optimizeForGermanyView() {
    if (_disposed) return; // 如果已 dispose，不再执行
    try {
      // 设置合适的缩放级别以突出显示德国及欧洲区域
      _globeController.setZoom(2.0);
      
      // 由于 Point 和 GlobeCoordinates API 在当前版本可能不可用
      // 我们通过设置合适的初始参数和缩放来让用户更容易找到德国
      // 德国位于欧洲中部，用户可以通过手动旋转地球找到
      debugPrint('Germany location: 51.17°N, 10.45°E');
      debugPrint('Globe optimized for viewing Germany/Europe region');
    } catch (e) {
      debugPrint('Note: Some features may not be available: $e');
    }
  }

  @override
  void dispose() {
    if (_disposed) return; // 防止重复 dispose
    _disposed = true;
    
    try {
      _globeController.dispose();
    } catch (e) {
      debugPrint('Error disposing globe controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = !kIsWeb;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double globeSize = isMobile 
        ? screenWidth - 40.0  // 移动端：屏幕宽度减去左右padding
        : 400.0;  // Web端：固定400宽度
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '德国奔驰',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: MouseDragScrollBehavior(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.0 : 40.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 地球模型
              Center(
                child: Column(
                  children: [
                    Container(
                      width: globeSize,
                      height: globeSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterEarthGlobe(
                          controller: _globeController,
                          radius: globeSize / 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 德国位置说明
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '📍 德国位置',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.blue.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '纬度 51.17°N，经度 10.45°E',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade300,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '（地球已放大显示欧洲区域，可手动旋转查看）',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                '一、企业概况',
                '奔驰，全称梅赛德斯-奔驰（Mercedes-Benz），是隶属于德国戴姆勒集团的标志性汽车品牌。该品牌由卡尔·本茨与戈特利布·戴姆勒于1926年共同创立，总部位于德国斯图加特。奔驰不仅是德国汽车工业的先驱，更是全球豪华汽车市场的领导者之一，其品牌影响力深远，产品行销全球190多个国家和地区。',
              ),
              _buildSection(
                context,
                '二、品牌历史与文化',
                '品牌起源：奔驰的历史可以追溯到19世纪末。1886年，卡尔·本茨发明了世界上第一辆三轮汽车，同年，戈特利布·戴姆勒也发明了世界上第一辆四轮汽车。这两项发明标志着汽车时代的开始，也为奔驰品牌的发展奠定了基础。\n\n品牌合并：1926年，卡尔·本茨和戈特利布·戴姆勒的公司合并，成立了戴姆勒-奔驰汽车公司，从此他们生产的所有汽车都命名为"梅赛德斯-奔驰"。\n\n品牌文化：奔驰的企业文化以创新与卓越为核心。从卡尔·奔驰和戈特利布·戴姆勒的创新精神，到今天的全面电动化转型，奔驰始终以卓越的技术和创新理念引领行业发展。其核心价值观体现在品质、创新和责任三个方面，致力于为用户提供卓越的产品和服务。',
              ),
              _buildSection(
                context,
                '三、产品矩阵与市场表现',
                '产品矩阵：奔驰的产品矩阵丰富多样，涵盖轿车、SUV、高性能车等多个品类。旗下拥有梅赛德斯-AMG、smart、迈巴赫等知名子品牌，分别满足消费者对速度与激情、城市通勤、顶级豪华等不同需求。\n\n市场表现：\n全球市场：奔驰在全球市场上有着广泛的影响力，无论是在欧洲、北美还是亚洲市场，都以其卓越的品质和创新的技术赢得了消费者的青睐。\n中国市场：中国作为全球最大的汽车市场，对奔驰的发展具有重要意义。近年来，奔驰在中国市场的表现尤为突出，销量持续增长，市场份额不断扩大。同时，奔驰也在不断加大在华投资，深化本土化战略，以更好地满足中国消费者的需求。例如，奔驰在华已建立了多个生产基地，实现了包括C级车、E级车、GLC SUV等主力车型的本土化生产。',
              ),
              _buildSection(
                context,
                '四、技术研发与创新',
                '技术创新：奔驰依托戴姆勒集团的全球研发资源，持续推动汽车产业的技术革新。从早期的内燃机技术突破，到如今在智能驾驶领域的L2+级辅助驾驶系统应用，再到纯电动EQ系列车型的推出，奔驰始终走在行业前沿。\n\n研发团队：奔驰的研发团队分布在德国、美国、中国等多个国家和地区，通过跨区域协作整合全球智慧，确保每一项技术创新都能精准匹配不同市场的用户需求。\n\n新能源布局：面对全球汽车行业的绿色发展，奔驰积极布局新能源领域，推出了EQC、EQS等多款新能源车型。这些车型以其零排放、低能耗等特点，为消费者提供了更加环保的出行选择。',
              ),
              _buildSection(
                context,
                '五、品牌矩阵与协同发展',
                '子品牌定位：奔驰旗下的子品牌如梅赛德斯-AMG、迈巴赫、smart等，与奔驰主品牌形成互补，覆盖了从大众化豪华到超高端定制的全价格带与用户圈层。\n\n协同发展：这些子品牌在技术研发、市场营销等方面与奔驰主品牌紧密协作，共同构筑了戴姆勒集团丰富的品牌生态。例如，梅赛德斯-AMG专注于打造极致驾驶体验的车型，满足了消费者对速度与激情的追求；迈巴赫则以顶级豪华定位，为高端用户提供定制化的奢华出行方案。',
              ),
              _buildSection(
                context,
                '六、本土化生产与市场策略',
                '本土化生产：奔驰在华已建立了多个生产基地，实现了部分车型的本土化生产。这种"全球品质+本地适配"的模式，让奔驰在中国市场赢得了广泛认可。\n\n市场策略：奔驰根据不同市场的需求和特点，制定针对性的市场策略。例如，在中国市场，奔驰注重与本土企业的合作，共同推动新能源汽车产业的发展；同时，奔驰还加大在华投资，深化本土化战略，以更好地满足中国消费者的需求。',
              ),
              _buildSection(
                context,
                '七、财务表现与挑战',
                '财务表现：尽管奔驰在全球市场上表现出色，但其财务表现也面临一定挑战。例如，在2025年第二季度，奔驰的净利润同比大幅下降，这主要受到新能源过渡期成本上升与产品竞争力调整尚未完成的影响。\n\n应对策略：为了应对这些挑战，奔驰采取了一系列措施，如优化成本结构、加大在新能源领域的投入、推动产品阵容的全面焕新等。这些措施有助于奔驰提升盈利能力，保持其在全球豪华车市场的领先地位。',
              ),
              _buildSection(
                context,
                '八、未来展望',
                '产品策略：奔驰将继续坚持"油电同质、油电同智"的产品策略，从产品、智能、体系三大维度推进转型。例如，奔驰计划在未来几年内引入超15款全新和改款产品，覆盖新生代豪华、核心豪华和高端豪华三大细分市场。\n\n智能化升级：奔驰将加快智能化升级步伐，向所有搭载MB.OS操作系统的车型推送多次整车软件OTA更新。同时，奔驰还将逐步覆盖全部产品矩阵的AI赋能智能座舱和跻身行业第一梯队的领航辅助驾驶系统。\n\n可持续发展：奔驰将继续坚持可持续发展理念，推动汽车行业向更清洁、更智能的未来迈进。例如，奔驰承诺到2040年实现全球零排放，并通过绿色生产、绿色产品和绿色运营践行可持续发展理念。',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade300,
              height: 1.8,
              fontSize: 15,
            ),
          ),
        ],
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
