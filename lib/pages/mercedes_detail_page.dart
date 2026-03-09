import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';

// 地球纹理 URL（Equirectangular 投影，与官方示例一致）
const String _kEarthSurfaceUrl =
    'https://raw.githubusercontent.com/turban/webgl-earth/master/images/2_no_clouds_4k.jpg';

// 德国坐标（纬度 51.1657°N，经度 10.4515°E）
const double _kGermanyLat = 51.1657;
const double _kGermanyLon = 10.4515;

// 自定义滚动行为，支持鼠标拖拽
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// 奔驰详情页
/// 参照 [flutter_earth_globe](https://github.com/Pana-g/flutter_earth_globe) 绘制地球并定位到德国。
/// Web 端需使用 `--wasm` 否则着色器可能不生效：flutter run -d chrome --wasm
class MercedesDetailPage extends StatefulWidget {
  const MercedesDetailPage({super.key});

  @override
  State<MercedesDetailPage> createState() => _MercedesDetailPageState();
}

class _MercedesDetailPageState extends State<MercedesDetailPage> {
  late FlutterEarthGlobeController _globeController;
  bool _disposed = false;
  bool _texturePrecached = false;

  @override
  void initState() {
    super.initState();
    // 参照官方 Quick Start：使用 ImageProvider 作为 surface，并设置 atmosphere
    _globeController = FlutterEarthGlobeController(
      rotationSpeed: 0.01,
      zoom: 1.8,
      surface: const NetworkImage(_kEarthSurfaceUrl),
      showAtmosphere: true,
      atmosphereColor: const Color(0xFF397BB9), // 地球蓝
      atmosphereOpacity: 0.6,
      atmosphereThickness: 0.15,
      atmosphereBlur: 25.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheTexture();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_disposed) _optimizeForGermanyView();
      });
    });
  }

  Future<void> _precacheTexture() async {
    if (_texturePrecached) return;
    if (!mounted) return;
    try {
      await precacheImage(const NetworkImage(_kEarthSurfaceUrl), context);
      if (mounted && !_disposed) _texturePrecached = true;
    } catch (e) {
      debugPrint('Earth texture precache failed: $e');
    }
  }

  void _optimizeForGermanyView() {
    if (_disposed) return;
    try {
      _globeController.setZoom(2.0);
      // 添加德国标记点（官方 API：Point + GlobeCoordinates）
      _globeController.addPoint(Point(
        id: 'germany',
        coordinates: const GlobeCoordinates(_kGermanyLat, _kGermanyLon),
        label: '德国',
        isLabelVisible: true,
        style: const PointStyle(
          color: Colors.blue,
          size: 12,
          altitude: 0.02,
        ),
        onTap: () => debugPrint('Germany tapped'),
      ));
      debugPrint('Germany marker added: $_kGermanyLat°N, $_kGermanyLon°E');
    } catch (e) {
      debugPrint('Optimize Germany view: $e');
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
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
    final double globeSize = isMobile ? screenWidth - 40.0 : 400.0;

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
        behavior: _MouseDragScrollBehavior(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.0 : 40.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: globeSize,
                      height: globeSize,
                      child: Container(
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
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
