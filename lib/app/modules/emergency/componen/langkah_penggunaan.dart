import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// DATA MODEL
/// ─────────────────────────────────────────────────────────────────────────────
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

/// ─────────────────────────────────────────────────────────────────────────────
/// EMERGENCY SERVICE GUIDE PAGE
/// ─────────────────────────────────────────────────────────────────────────────
class EmergencyGuidePage extends StatefulWidget {
  const EmergencyGuidePage({super.key});

  @override
  State<EmergencyGuidePage> createState() => _EmergencyGuidePageState();
}

class _EmergencyGuidePageState extends State<EmergencyGuidePage> {
  final _pageCtrl = PageController();
  int _pageIndex = 0;

  final _steps = <GuideStep>[
    GuideStep(
      title: 'Buat Emergency Service',
      description:
      'Tekan tombol “Buat Emergency Service” pada beranda aplikasi untuk '
          'memulai permintaan bantuan darurat.',
      imagePath: 'assets/penggunaan/emergency1.png',
    ),
    GuideStep(
      title: 'Isi Formulir',
      description:
      'Nomor polisi & lokasi terisi otomatis (berdasar GPS). Lengkapi kolom '
          'keluhan serta unggah foto / video diagnosa kerusakan.',
      imagePath: 'assets/penggunaan/emergency3.png',
    ),
    GuideStep(
      title: 'Daftar Emergency Service',
      description:
      'Permintaan sukses tersimpan di daftar Emergency Service — lengkap '
          'dengan detail kendaraan & status penanganan.',
      imagePath: 'assets/penggunaan/emergency2.png',
    ),
    GuideStep(
      title: 'Pantau Mekanik Realtime',
      description:
      'Ketika status berubah menjadi “Mekanik dalam perjalanan”, Anda bisa '
          'memantau posisi mekanik di peta secara realtime.',
      imagePath: 'assets/penggunaan/emergency4.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? Colors.orangeAccent : Colors.blueAccent;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // ─── PAGEVIEW ──────────────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemBuilder: (_, i) => _GuideSlide(step: _steps[i]),
            ),

            // ─── SKIP ──────────────────────────────────────────────────
            Positioned(
              top: 8,
              right: 16,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Lewati',style: TextStyle( color: textColor,),),
              ),
            ),

            // ─── INDICATOR + NAV BUTTONS ──────────────────────────────
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    child: SmoothPageIndicator(
                      controller: _pageCtrl,
                      count: _steps.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 6,
                        activeDotColor: accent,
                        dotColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                      ),
                      onDotClicked: (index) => _pageCtrl.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_pageIndex > 0)
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    ),
                  const SizedBox(width: 8),
                  _CircleButton(
                    icon: _pageIndex == _steps.length - 1
                        ? Icons.check
                        : Icons.arrow_forward_ios,
                    onTap: () {
                      if (_pageIndex == _steps.length - 1) {
                        Navigator.pop(context); // → ganti rute bila perlu
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

/// ─────────────────────────────────────────────────────────────────────────────
/// SLIDE COMPONENT (reuse dari halaman sebelumnya jika ada)
/// ─────────────────────────────────────────────────────────────────────────────
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
          // Illustration
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                step.imagePath,
                width: double.infinity,
                fit: BoxFit.contain,
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

/// ─────────────────────────────────────────────────────────────────────────────
/// CIRCLE BUTTON (reuse / konsisten)
/// ─────────────────────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white24 : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }
}
