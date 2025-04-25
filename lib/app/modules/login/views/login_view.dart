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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(AssetsRes.LOGO, height: 70),
                ),
                const SizedBox(height: 24),
                Text(
                  "Selamat Datang!",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Silakan masuk untuk melanjutkan",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 32),
                // Field Email
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    hintText: "Email",
                    hintStyle: GoogleFonts.nunito(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    helperText: "Anda harus memasukkan email yang valid",
                    helperStyle: GoogleFonts.nunito(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    filled: true,
                    fillColor:
                        isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
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
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () => isObscure.toggle(),
                      ),
                      hintText: "Kata Sandi",
                      hintStyle: GoogleFonts.nunito(
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                      helperText: "Password minimal 6 karakter",
                      helperStyle: GoogleFonts.nunito(
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol Masuk
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Reguler Service',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // latar jingga
                        elevation: 0, // flat look
                        padding: const EdgeInsets.symmetric(
                          // ruang nyaman
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.to(() => const UsageGuidePage()),
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Emergency Service',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.to(() => const EmergencyGuidePage()),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snap) {
                    final v = snap.data?.version ?? '–';
                    return Text(
                      'Versi Aplikasi $v',
                      style: GoogleFonts.nunito(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
