import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resepin/controllers/recipe_controller.dart';
import 'package:resepin/pages/rekomendasi_page.dart';
import 'package:resepin/theme/appColors.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  final RecipeController _recipeController = Get.put(RecipeController());
  bool _isLocalLoading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.03),

                // Header
                Text(
                  "Scan Bahan Makanan",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.01),

                Text(
                  "Ambil foto bahan makanan untuk mendapatkan rekomendasi resep",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.04),

                // Main scan area
                Container(
                  width: width * 0.8,
                  height: height * 0.35,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isLocalLoading
                              ? CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Icon(
                        Icons.auto_awesome,
                        size: 30,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Text(
                        "AI akan menganalisis bahan makanan",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.05),

                // Scan options
                _buildScanOption(
                  icon: Icons.camera_alt,
                  title: "Ambil Foto",
                  subtitle: "Gunakan kamera untuk foto bahan",
                  color: AppColors.primary,
                  onTap: _isLocalLoading ? null : () => _openCamera(),
                  isDisabled: _isLocalLoading,
                ),

                SizedBox(height: height * 0.02),

                _buildScanOption(
                  icon: Icons.photo_library,
                  title: "Pilih dari Galeri",
                  subtitle: "Upload foto bahan dari galeri",
                  color: Colors.indigo,
                  onTap: _isLocalLoading ? null : () => _openGallery(),
                  isDisabled: _isLocalLoading,
                ),

                SizedBox(height: height * 0.03),

                // Tips section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tips untuk hasil terbaik:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "• Pastikan pencahayaan cukup\n• Foto dari jarak yang tidak terlalu jauh\n• Bahan makanan terlihat jelas",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : color,
            width: 2,
          ),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey.shade300 : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey.shade500 : color,
                size: 30,
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
                      color: isDisabled ? Colors.grey.shade500 : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDisabled ? Colors.grey.shade400 : color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(File(image.path), "camera");
      }
    } catch (e) {
      print('Error opening camera: $e');
      Get.snackbar(
        'Error',
        'Gagal membuka kamera. Periksa izin akses kamera.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(File(image.path), "gallery");
      }
    } catch (e) {
      print('Error opening gallery: $e');
      Get.snackbar(
        'Error',
        'Gagal membuka galeri. Periksa izin akses penyimpanan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _processImage(File imageFile, String source) async {
    setState(() {
      _isLocalLoading = true;
    });

    _showLoadingDialog("AI sedang menganalisis gambar dan mencari resep...");

    Future.microtask(() async {
      bool success = await _recipeController.getRecipeRecommendations(imageFile);
      
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
        
        Get.back();
        
        if (success && _recipeController.hasRecommendations) {
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Get.to(
                () => RekomendasiPage(
                  detectedIngredients: _recipeController.detectedIngredients.toList(),
                ),
                transition: Transition.rightToLeft,
                duration: Duration(milliseconds: 300),
              );
            }
          });
        }
      }
    });
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedResponse() {
    Get.dialog(
      AlertDialog(
        title: Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Detected Ingredients:'),
              Text(_recipeController.detectedIngredients.join('\n')),
              SizedBox(height: 16),
              Text('Recipes Count: ${_recipeController.recommendedRecipes.length}'),
              if (_recipeController.recommendedRecipes.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('First Recipe:'),
                Text(_recipeController.recommendedRecipes.first.title),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Close')),
          TextButton(
            onPressed: () {
              _recipeController.debugPrintCurrentState();
              Get.back();
            },
            child: Text('Print to Console'),
          ),
        ],
      ),
    );
  }
}
