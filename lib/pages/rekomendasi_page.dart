import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/controllers/recipe_controller.dart';
import 'package:resepin/pages/detail_resep_page.dart';
import 'package:resepin/theme/appColors.dart';

class RekomendasiPage extends StatefulWidget {
  final List<String>? detectedIngredients;
  
  const RekomendasiPage({
    super.key,
    this.detectedIngredients,
  });

  @override
  State<RekomendasiPage> createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {
  final RecipeController _recipeController = Get.find<RecipeController>();

  @override
  void initState() {
    super.initState();
    // Data sudah tersedia dari controller, tidak perlu fetch lagi
  }
  
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      "Recomendation Recipes",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            // Detected Ingredients Section
            Obx(() {
              if (_recipeController.detectedIngredients.isNotEmpty) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Detected Substances:",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _recipeController.detectedIngredients.take(10).map((ingredient) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade300, width: 1),
                            ),
                            child: Text(
                              ingredient,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_recipeController.detectedIngredients.length > 10)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "+${_recipeController.detectedIngredients.length - 10} other ingredients",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // SizedBox(height: 16),

            // // Recipe count and filter
            // Obx(() {
            //   if (_recipeController.recommendedRecipes.isNotEmpty) {
            //     return Padding(
            //       padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            //       child: Row(
            //         children: [
            //           Text(
            //             "${_recipeController.recommendedRecipes.length} resep ditemukan",
            //             style: GoogleFonts.poppins(
            //               fontSize: 16,
            //               fontWeight: FontWeight.w600,
            //               color: Colors.black,
            //             ),
            //           ),
            //           Spacer(),
            //           Icon(
            //             Icons.restaurant_menu,
            //             color: AppColors.primary,
            //             size: 20,
            //           ),
            //         ],
            //       ),
            //     );
            //   }
            //   return SizedBox.shrink();
            // }),

            SizedBox(height: 16),

            // Grid View for Recipes
            Expanded(
              child: Obx(() {
                if (_recipeController.isRecommending.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          "Searching for recipe recommendations...",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!_recipeController.hasRecommendations) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No recipe recommendations found",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Try using different food ingredient images",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Try Again",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _recipeController.recipesCount,
                    itemBuilder: (context, index) {
                      Recipe recipe = _recipeController.getRecipeAt(index)!;
                      // Convert Recipe object to Map untuk sesuai dengan format UI awal
                      Map<String, dynamic> recipeMap = {
                        'title': recipe.title,
                        'calories': '${recipe.cleanedIngredients.length} ingredients',
                        'tag': _getRecipeTag(recipe),
                      };
                      return _buildRecipeCard(recipeMap, recipe);
                    },
                  ),
                );
              }),
            ),

            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }

  // 🔧 UI Card sesuai dengan format awal
  Widget _buildRecipeCard(Map<String, dynamic> recipe, Recipe recipeObject) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => DetailResepPage(),
          arguments: recipeObject,
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );
        Get.snackbar(
          "Info",
          "Opening recipe ${recipe['title']}",
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.brown.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern untuk simulasi makanan
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              image: null,
                            ),
                            child: Image.network(
                              recipeObject.imageUrl.isNotEmpty 
                                  ? recipeObject.imageUrl 
                                  : 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.orange.shade100,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Colors.orange.shade400,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      recipe['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Calories
                    // Text(
                    //   recipe['calories'],
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w400,
                    //     color: Colors.grey.shade600,
                    //   ),
                    // ),
                    
                    // Tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTagColor(recipe['tag']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe['tag'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan tag berdasarkan Recipe object
  String _getRecipeTag(Recipe recipe) {
    // Extract tag dari title atau gunakan default
    String title = recipe.title.toLowerCase();
    
    if (title.contains('chicken') || title.contains('ayam')) {
      return 'Ayam';
    } else if (title.contains('beef') || title.contains('daging')) {
      return 'Daging';
    } else if (title.contains('fish') || title.contains('ikan')) {
      return 'Ikan';
    } else if (title.contains('vegetable') || title.contains('sayur')) {
      return 'Sayuran';
    } else if (title.contains('rice') || title.contains('nasi')) {
      return 'Nasi';
    } else if (title.contains('soup') || title.contains('sup')) {
      return 'Sup';
    } else if (title.contains('dessert') || title.contains('manis')) {
      return 'Dessert';
    } else {
      return 'Lainnya';
    }
  }

  // Helper method untuk mendapatkan warna tag
  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'chicken':
        return Colors.orange;
      case 'beef':
        return Colors.red;
      case 'fish':
        return Colors.blue;
      case 'vegetable':
        return Colors.green;
      case 'rice':
        return Colors.amber;
      case 'soup':
        return Colors.indigo;
      case 'dessert':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }
}