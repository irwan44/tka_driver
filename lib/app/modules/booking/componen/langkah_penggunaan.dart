import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GuideStep {
  final String title;
  final String description;
  final String imagePath;
  GuideStep({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class UsageGuidePage extends StatefulWidget {
  const UsageGuidePage({Key? key}) : super(key: key);

  @override
  State<UsageGuidePage> createState() => _UsageGuidePageState();
}

class _UsageGuidePageState extends State<UsageGuidePage> {
  final _pageCtrl = PageController();
  int _pageIndex = 0;

  final _steps = <GuideStep>[
    GuideStep(
      title: 'Request Service',
      description:
          'Tekan tombol “Buat Request Service” untuk memulai permintaan servis '
          'kendaraan Anda.',
      imagePath: 'assets/penggunaan/request1.png',
    ),
    GuideStep(
      title: 'Isi Formulir',
      description:
          'Masukkan nomor polisi, deskripsikan keluhan, lalu unggah foto/video '
          'diagnosa kerusakan.',
      imagePath: 'assets/penggunaan/request2.png',
    ),
    GuideStep(
      title: 'Lihat Daftar Request',
      description:
          'Semua request tersimpan di tab “Request Service” lengkap dengan '
          'status & detail kendaraan.',
      imagePath: 'assets/penggunaan/request3.png',
    ),
    GuideStep(
      title: 'Service Berkala',
      description:
          'Di menu “Service” Anda dapat melihat paket servis, suku cadang '
          'yang diganti, dan biaya jasa.',
      imagePath: 'assets/penggunaan/service.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final accent = isDark ? Colors.orangeAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemBuilder: (_, i) => _GuideSlide(step: _steps[i]),
            ),

            Positioned(
              top: 8,
              right: 16,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Lewati', style: TextStyle(color: textColor)),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Row(
                children: [
                  // Dot indicator
                  Expanded(
                    child: AnimatedSmoothIndicator(
                      activeIndex: _pageIndex,
                      count: _steps.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 6,
                        activeDotColor: accent,
                        dotColor:
                            isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  if (_pageIndex > 0)
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap:
                          () => _pageCtrl.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                    ),

                  const SizedBox(width: 8),

                  _CircleButton(
                    icon:
                        _pageIndex == _steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_ios,
                    onTap: () {
                      if (_pageIndex == _steps.length - 1) {
                        Navigator.pop(context); // ↳ ganti rute jika perlu
                      } else {
                        _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSlide extends StatelessWidget {
  const _GuideSlide({required this.step});

  final GuideStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 62, 24, 120),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                step.imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            step.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white24 : Colors.black12;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
