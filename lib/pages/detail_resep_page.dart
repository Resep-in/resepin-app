import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/controllers/bookmark_controller.dart';
import 'package:resepin/controllers/recipe_controller.dart';
import 'package:resepin/theme/appColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class DetailResepPage extends StatefulWidget {
  const DetailResepPage({super.key});

  @override
  State<DetailResepPage> createState() => _DetailResepPageState();
}

class _DetailResepPageState extends State<DetailResepPage> {
  late Recipe recipe;
  BookmarkController? _bookmarkController;
  RecipeController? _recipeController;
  bool isLoadingFullData = false;
  String dataSource = 'unknown';

  @override
  void initState() {
    super.initState();
    recipe = Get.arguments as Recipe;
    
    try {
      _bookmarkController = Get.find<BookmarkController>();
    } catch (e) {
      _bookmarkController = Get.put(BookmarkController());
    }
    
    try {
      _recipeController = Get.find<RecipeController>();
    } catch (e) {
      _recipeController = Get.put(RecipeController());
    }

    _determineSourceAndLoadData();
  }

  void _determineSourceAndLoadData() async {
    bool needsFullData = recipe.steps.isEmpty || 
                        recipe.cleanedIngredients.isEmpty ||
                        recipe.ingredientsServing.isEmpty;
    
    if (needsFullData) {
      if (_bookmarkController?.isBookmarked(recipe.id) == true) {
        dataSource = 'bookmark';
      } else {
        dataSource = 'recommendation';
      }
      
      await _loadFullRecipeData();
    } else {
      dataSource = 'full';
    }
  }

  Future<void> _loadFullRecipeData() async {
    if (_recipeController == null) {
      _showErrorMessage('Error', 'Recipe controller tidak tersedia');
      return;
    }
    
    setState(() {
      isLoadingFullData = true;
    });

    try {
      Recipe? fullRecipe = await _recipeController!.getRecipeDetail(recipe.id);
      
      if (fullRecipe != null) {
        setState(() {
          recipe = fullRecipe;
        });
        
        Get.snackbar(
          'Success',
          'Recipe details loaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        _showLoadFailedDialog();
      }
    } catch (e) {
      _showLoadFailedDialog();
    } finally {
      setState(() {
        isLoadingFullData = false;
      });
    }
  }

  void _showLoadFailedDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Failed to Load Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Unable to load recipe details. Please try again or open the original recipe.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _loadFullRecipeData();
            },
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
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
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          recipe.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isLoadingFullData)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Loading details...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bookmark button
                  _bookmarkController != null 
                      ? Obx(() => IconButton(
                          onPressed: () async {
                            await _bookmarkController!.toggleBookmark(recipe);
                            
                            Get.snackbar(
                              _bookmarkController!.isBookmarked(recipe.id) ? "Bookmark" : "Removed", 
                              _bookmarkController!.isBookmarked(recipe.id) 
                                  ? "Recipe added to Bookmark" 
                                  : "Recipe removed from bookmark",
                              backgroundColor: _bookmarkController!.isBookmarked(recipe.id) 
                                  ? Colors.green 
                                  : Colors.grey,
                              colorText: Colors.white,
                            );
                          },
                          icon: Icon(
                            _bookmarkController!.isBookmarked(recipe.id) 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            color: _bookmarkController!.isBookmarked(recipe.id) 
                                ? Colors.red 
                                : Colors.grey,
                            size: 24,
                          ),
                        ))
                      : IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Recipe Image
                    Container(
                      width: double.infinity,
                      height: height * 0.25,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.orange.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: recipe.imageUrl.isNotEmpty
                            ? Stack(
                                children: [
                                  Image.network(
                                    recipe.imageUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.orange.shade100,
                                        child: Center(
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 60,
                                            color: Colors.orange.shade400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: Colors.orange.shade100,
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: Colors.orange.shade400,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Ingredients Table
                    _buildIngredientsTable(width),

                    SizedBox(height: height * 0.03),

                    // Total Calories Summary
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Bahan:",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          Text(
                            "${_getIngredientsCount()} item",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Cooking Instructions
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cooking Instructions:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          ..._buildCookingStepsFromAPI(),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Action Button untuk buka resep asli
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(recipe.fullUrl),
                        icon: Icon(Icons.open_in_new, size: 20),
                        label: Text(
                          "Open Original Recipe",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTable(double width) {
    return Column(
      children: [
        // Ingredients Table Header
        Container(
          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  "INGREDIENT",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "DOSE",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Ingredients Table Content
        Container(
          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _buildIngredientsFromAPI(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIngredientsFromAPI() {
    if (isLoadingFullData) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (recipe.ingredientsServing.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "No ingredient data available",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    List<Map<String, String>> parsedIngredients = [];
    
    for (String ingredientString in recipe.ingredientsServing) {
      try {
        if (ingredientString.startsWith('[') && ingredientString.endsWith(']')) {
          String jsonString = ingredientString.replaceAll("'", '"');
          var decoded = jsonDecode(jsonString);
          
          if (decoded is List) {
            for (var item in decoded) {
              if (item is List && item.length >= 2) {
                String quantity = item[0].toString().trim();
                String name = item[1].toString().trim();
                
                parsedIngredients.add({
                  'quantity': quantity,
                  'name': name,
                });
              }
            }
          }
        } else {
          parsedIngredients.add({
            'quantity': '',
            'name': ingredientString,
          });
        }
      } catch (e) {
        try {
          List<Map<String, String>> manualParsed = _manualParseIngredients(ingredientString);
          parsedIngredients.addAll(manualParsed);
        } catch (manualError) {
          parsedIngredients.add({
            'quantity': '',
            'name': ingredientString,
          });
        }
      }
    }

    if (parsedIngredients.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "Failed to process ingredient data",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return parsedIngredients.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> ingredient = entry.value;
      
      String quantity = ingredient['quantity'] ?? '';
      String name = ingredient['name'] ?? '';
      
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: index != parsedIngredients.length - 1
                ? BorderSide(color: Colors.grey.shade200, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                quantity,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Map<String, String>> _manualParseIngredients(String ingredientString) {
    List<Map<String, String>> result = [];
    
    if (ingredientString.startsWith('[') && ingredientString.endsWith(']')) {
      String content = ingredientString.substring(1, ingredientString.length - 1);
      List<String> parts = content.split('], [');
      
      for (String part in parts) {
        part = part.replaceAll('[', '').replaceAll(']', '');
        List<String> elements = part.split("', '");
        
        if (elements.length >= 2) {
          String quantity = elements[0].replaceAll("'", '').trim();
          String name = elements[1].replaceAll("'", '').trim();
          
          result.add({
            'quantity': quantity,
            'name': name,
          });
        }
      }
    }
    
    return result;
  }

  List<Widget> _buildCookingStepsFromAPI() {
    if (isLoadingFullData) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (recipe.steps.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "No cooking instructions available. Please open the original recipe for full details.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    List<String> steps = recipe.steps.split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    return steps.asMap().entries.map((entry) {
      int index = entry.key;
      String step = entry.value.trim();
      
      step = step.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
      
      return _buildCookingStep(index + 1, step);
    }).toList();
  }

  Widget _buildCookingStep(int stepNumber, String instruction) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getIngredientsCount() {
    if (recipe.ingredientsServing.isEmpty) return 0;
    
    int totalCount = 0;
    for (String ingredientString in recipe.ingredientsServing) {
      try {
        if (ingredientString.startsWith('[') && ingredientString.endsWith(']')) {
          String jsonString = ingredientString.replaceAll("'", '"');
          var parsed = jsonDecode(jsonString);
          if (parsed is List) {
            totalCount += parsed.length;
          }
        } else {
          totalCount += 1;
        }
      } catch (e) {
        if (ingredientString.contains('], [')) {
          totalCount += ingredientString.split('], [').length;
        } else {
          totalCount += 1;
        }
      }
    }
    
    return totalCount;
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar(
          'Error',
          'Cannot open recipe link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot open recipe link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}