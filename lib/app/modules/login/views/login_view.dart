import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tka_customer/app/modules/login/controllers/login_controller.dart';

import '../../../../main.dart';
import '../../booking/componen/langkah_penggunaan.dart';
import '../../emergency/componen/langkah_penggunaan.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController c = Get.put(LoginController());
    final RxBool isObscure = true.obs;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color accent(int idx) =>
        idx == 0 ? const Color(0xFF1976D2) : const Color(0xFFEF6C00);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101114) : Colors.white,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: LayoutBuilder(
            builder: (context, cons) {
              final w = cons.maxWidth;
              final bool isTablet = w >= 600;
              final double hPad = isTablet ? w * .20 : 28;
              final double logoH = isTablet ? 120 : 70;
              final double headingSize = isTablet ? 30 : 22;
              final double helperSize = isTablet ? 16 : 12.5;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ───────── LOGO
                        Align(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Image.asset(AssetsRes.LOGO, height: logoH),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ───────── HEADER (menggunakan Obx agar ikut berubah)
                        Obx(() {
                          final idx = c.selectedTab.value;
                          return Column(
                            children: [
                              Text(
                                idx == 0 ? "Masuk Driver" : "Masuk PIC",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: headingSize,
                                  fontWeight: FontWeight.w800,
                                  color: accent(idx),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                idx == 0
                                    ? "Driver: kelola servis & update perjalanan."
                                    : "PIC: pantau permintaan & laporan kendaraan.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: helperSize,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),

                        // ───────── TABBAR
                        Obx(
                          () => Container(
                            // ── padding luar kotak
                            padding: const EdgeInsets.all(
                              12,
                            ), // padding di dalam kotak
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if (!isDark)
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: TabBar(
                              onTap: c.changeTab,
                              // hilangkan garis bawah
                              dividerColor: Colors.transparent,
                              indicatorColor: Colors.transparent,
                              indicatorWeight: 0,
                              // indikator chip
                              indicatorPadding: const EdgeInsets.all(4),
                              indicator: BoxDecoration(
                                color: accent(c.selectedTab.value),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor:
                                  isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                              labelStyle: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.local_shipping_outlined,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Driver'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.supervisor_account_outlined,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Text('PIC'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ───────── FORM EMAIL
                        _field(
                          ctx: context,
                          isDark: isDark,
                          controller: c.emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          helper: 'Masukkan email valid',
                          helperSize: helperSize,
                        ),
                        const SizedBox(height: 16),

                        // ───────── FORM PASSWORD
                        Obx(
                          () => _field(
                            ctx: context,
                            isDark: isDark,
                            controller: c.passwordController,
                            hint: 'Kata Sandi',
                            icon: Icons.lock_outline,
                            obscure: isObscure.value,
                            helper: 'Min. 6 karakter',
                            helperSize: helperSize,
                            suffix: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 18,
                              icon: Icon(
                                isObscure.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                              ),
                              onPressed: () => isObscure.toggle(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ───────── BUTTON LOGIN
                        Obx(() {
                          final idx = c.selectedTab.value;
                          return ElevatedButton(
                            onPressed:
                                c.isLoading.value
                                    ? null
                                    : () =>
                                        idx == 0 ? c.doLogin() : c.doLoginPIC(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent(idx),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 0,
                            ),
                            child:
                                c.isLoading.value
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "MASUK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          );
                        }),
                        const SizedBox(height: 40),

                        // ───────── QUICK GUIDE
                        Text(
                          "Panduan Cepat",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _guideBtn(
                              label: 'Reguler',
                              color: Colors.green,
                              onTap: () => Get.to(() => const UsageGuidePage()),
                            ),
                            _guideBtn(
                              label: 'Emergency',
                              color: Colors.redAccent,
                              onTap:
                                  () =>
                                      Get.to(() => const EmergencyGuidePage()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),

                        // ───────── VERSION
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (ctx, snap) {
                            final v = snap.data?.version ?? '–';
                            return Text(
                              'Versi $v',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: helperSize,
                                color:
                                    isDark
                                        ? Colors.white38
                                        : Colors.grey.shade500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────── FIELD HELPER
  Widget _field({
    required BuildContext ctx,
    required bool isDark,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String helper,
    required double helperSize,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white : Colors.grey.shade700,
        ),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          color: isDark ? Colors.white54 : Colors.grey.shade500,
        ),
        helperText: helper,
        helperStyle: GoogleFonts.nunito(
          fontSize: helperSize,
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : const Color(0xFFF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
      ),
    );
  }

  // ───────────────────────── GUIDE BUTTON
  Widget _guideBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
