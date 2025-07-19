import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resepin/pages/rekomendasi_page.dart';
import 'package:resepin/theme/appColors.dart';
import 'dart:io';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.07),
          child: Column(
            children: [
              SizedBox(height: height * 0.05),
              
              Text(
                "Chef AI Scanner",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                "Scan bahan makanan untuk\nrekomendasi resep terbaik",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: height * 0.05),

              Container(
                width: width * 0.6,
                height: width * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(width * 0.3),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8),
                          Icon(
                            Icons.auto_awesome,
                            size: 30,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 40,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 30,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),

              _buildScanOption(
                icon: Icons.camera_alt,
                title: "Ambil Foto",
                subtitle: "Gunakan kamera untuk foto bahan",
                color: AppColors.primary,
                onTap: () => _openCamera(),
              ),

              SizedBox(height: height * 0.02),

              _buildScanOption(
                icon: Icons.photo_library,
                title: "Pilih dari Galeri",
                subtitle: "Upload foto bahan dari galeri",
                color: Colors.indigo,
                onTap: () => _openGallery(),
              ),

              SizedBox(height: height * 0.03),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tips: Pastikan foto bahan makanan terlihat jelas untuk hasil scan yang optimal",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _openCamera() async {
    try {
      _showLoadingDialog("Membuka kamera...");
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      Get.back();

      if (image != null) {
        _processImage(image, "camera");
      } else {
        Get.snackbar(
          "Info",
          "Tidak ada foto yang diambil",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Gagal membuka kamera: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openGallery() async {
    try {
      _showLoadingDialog("Membuka galeri...");
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      Get.back();

      if (image != null) {
        _processImage(image, "gallery");
      } else {
        Get.snackbar(
          "Info",
          "Tidak ada foto yang dipilih",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Gagal membuka galeri: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _processImage(XFile image, String source) {
    _showLoadingDialog("AI sedang menganalisis bahan makanan...");

    Future.delayed(Duration(seconds: 3), () {
      Get.back();
      
      Get.snackbar(
        "Berhasil!",
        "Bahan makanan berhasil diidentifikasi",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      Future.delayed(Duration(seconds: 2), () {
        Get.to(
          () => RekomendasiPage(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );
      });
    });
  }
}