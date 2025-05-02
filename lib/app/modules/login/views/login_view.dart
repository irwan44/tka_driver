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
    final LoginController controller = Get.put(LoginController());
    final RxBool isObscure = true.obs;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final bool isTablet = w >= 600;
            final bool stackButtons = w < 350;

            final double hPad = isTablet ? w * 0.20 : 28;
            final double logoH = isTablet ? 120 : 70;
            final double headingSize = isTablet ? 28 : 20;
            final double subHeadingSize = isTablet ? 18 : 14;
            final double helperSize = isTablet ? 16 : 12;
            final double fieldVPad = isTablet ? 20 : 16;
            final double btnVPad = isTablet ? 18 : 16;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(AssetsRes.LOGO, height: logoH),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "Selamat Datang!",
                        style: GoogleFonts.nunito(
                          fontSize: headingSize,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Silakan masuk untuk melanjutkan",
                        style: GoogleFonts.nunito(
                          fontSize: subHeadingSize,
                          color: isDark ? Colors.white70 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: controller.emailController,
                        decoration: _fieldDecoration(
                          context,
                          isDark,
                          hint: "Email",
                          icon: Icons.email_outlined,
                          helper: "Anda harus memasukkan email yang valid",
                          helperSize: helperSize,
                          vPad: fieldVPad,
                        ),
                        style: GoogleFonts.nunito(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: isObscure.value,
                          decoration: _fieldDecoration(
                            context,
                            isDark,
                            hint: "Kata Sandi",
                            icon: Icons.lock_outline,
                            helper: "Password minimal 6 karakter",
                            helperSize: helperSize,
                            vPad: fieldVPad,
                            suffix: IconButton(
                              icon: Icon(
                                isObscure.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              onPressed: () => isObscure.toggle(),
                            ),
                          ),
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : () => controller.doLogin(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: btnVPad),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            child:
                                controller.isLoading.value
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      "MASUK",
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        "Panduan Aplikasi",
                        style: GoogleFonts.nunito(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      stackButtons
                          ? Column(
                            children: [
                              _buildGuideBtn(
                                label: 'Reguler Service',
                                color: Colors.green,
                                onTap:
                                    () => Get.to(() => const UsageGuidePage()),
                              ),
                              const SizedBox(height: 12),
                              _buildGuideBtn(
                                label: 'Emergency',
                                color: Colors.redAccent,
                                onTap:
                                    () => Get.to(
                                      () => const EmergencyGuidePage(),
                                    ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildGuideBtn(
                                  label: 'Reguler Service',
                                  color: Colors.green,
                                  onTap:
                                      () =>
                                          Get.to(() => const UsageGuidePage()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGuideBtn(
                                  label: 'Emergency',
                                  color: Colors.redAccent,
                                  onTap:
                                      () => Get.to(
                                        () => const EmergencyGuidePage(),
                                      ),
                                ),
                              ),
                            ],
                          ),

                      const SizedBox(height: 50),

                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) {
                          final v = snap.data?.version ?? '–';
                          return Text(
                            'Versi Aplikasi $v',
                            style: GoogleFonts.nunito(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: helperSize,
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
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    bool isDark, {
    required String hint,
    required IconData icon,
    required String helper,
    required double helperSize,
    double vPad = 16,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: isDark ? Colors.white : Colors.black),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: GoogleFonts.nunito(
        color: isDark ? Colors.white70 : Colors.grey,
      ),
      helperText: helper,
      helperStyle: GoogleFonts.nunito(
        color: isDark ? Colors.white70 : Colors.grey,
        fontSize: helperSize,
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
      contentPadding: EdgeInsets.symmetric(vertical: vPad),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildGuideBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.info_outline, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
