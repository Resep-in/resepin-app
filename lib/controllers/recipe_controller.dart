import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/services/auth_service.dart';

class Recipe {
  final int id;
  final String title;
  final String fullUrl;
  final String imageUrl;
  final String? searchIndex;
  final String steps;
  final List<String> ingredientsServing;
  final List<String> cleanedIngredients;
  final String? createdAt;
  final String? updatedAt;

  Recipe({
    required this.id,
    required this.title,
    required this.fullUrl,
    required this.imageUrl,
    this.searchIndex,
    required this.steps,
    required this.ingredientsServing,
    required this.cleanedIngredients,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parse ingredients_serving
    List<String> parseIngredientsServing(dynamic ingredientsData) {
      try {
        if (ingredientsData == null) return [];
        
        if (ingredientsData is String) {
          // Parse string format "[['1', 'piece large firm tofu'], ['250 g', 'french bean']]"
          if (ingredientsData.startsWith('[') && ingredientsData.endsWith(']')) {
            var parsed = jsonDecode(ingredientsData);
            if (parsed is List) {
              return parsed.map((item) {
                if (item is List && item.length >= 2) {
                  return '${item[0]} ${item[1]}'; // Combine quantity and ingredient
                }
                return item.toString();
              }).cast<String>().toList();
            }
          }
          return [ingredientsData];
        } else if (ingredientsData is List) {
          return ingredientsData.cast<String>();
        }
        
        return [];
      } catch (e) {
        print('❌ Error parsing ingredients_serving: $e');
        return [];
      }
    }

    return Recipe(
      id: json['id']?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      fullUrl: json['full_url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      searchIndex: json['search_index']?.toString(),
      steps: json['steps']?.toString() ?? '',
      ingredientsServing: parseIngredientsServing(json['ingredients_serving']),
      cleanedIngredients: json['cleaned_ingredients'] != null 
          ? List<String>.from(json['cleaned_ingredients'])
          : [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'full_url': fullUrl,
      'image_url': imageUrl,
      'search_index': searchIndex,
      'steps': steps,
      'ingredients_serving': ingredientsServing,
      'cleaned_ingredients': cleanedIngredients,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class RecipeController extends GetxController {
  // Loading states
  var isLoading = false.obs;
  var isRecommending = false.obs;
  
  // Data states
  var detectedIngredients = <String>[].obs;
  var recommendedRecipes = <Recipe>[].obs;
  var errorMessage = ''.obs;
  
  // Add these for compatibility
  final RxList<String> predictedIngredients = <String>[].obs;
  final RxList<Recipe> recipes = <Recipe>[].obs;
  
  // Clear all data
  void clearData() {
    detectedIngredients.clear();
    recommendedRecipes.clear();
    predictedIngredients.clear();
    recipes.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isRecommending.value = false;
    print('🧹 RecipeController data cleared');
  }

  /// Upload image untuk mendapatkan rekomendasi resep
  Future<bool> getRecipeRecommendations(File imageFile) async {
    try {
      isRecommending.value = true;
      errorMessage.value = '';
      recommendedRecipes.clear();
      detectedIngredients.clear();

      // Get authentication token
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      print('🔍 RECIPE RECOMMENDATIONS REQUEST:');
      print('📤 URL: ${RoutesApi.recommendUrl()}');
      print('🔑 Token: ${token.substring(0, 20)}...');
      print('📷 Image Path: ${imageFile.path}');
      print('📁 Image Size: ${await imageFile.length()} bytes');

      // Validate image file
      if (!await imageFile.exists()) {
        throw Exception('File gambar tidak ditemukan');
      }

      // Check file size (max 5MB)
      int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar. Maksimal 5MB');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(RoutesApi.recommendUrl()),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add image file with proper MIME type
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'recipe_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);

      print('📦 Request Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}');
      print('🚀 Sending recommendation request...');

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Server tidak merespons dalam 30 detik');
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 RECOMMENDATION RESPONSE:');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Raw Body Preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        try {
          // Parse response - handle both array and object formats
          dynamic responseData = jsonDecode(response.body);
          print('🔍 Response Type: ${responseData.runtimeType}');
          
          List<Recipe> recipes = [];
          
          if (responseData is List) {
            // Response adalah array langsung
            print('📋 Response is direct array with ${responseData.length} recipes');
            
            for (int i = 0; i < responseData.length; i++) {
              try {
                var recipeJson = responseData[i];
                print('🔧 Parsing recipe $i: ${recipeJson['title'] ?? 'No title'}');
                
                Recipe recipe = Recipe.fromJson(recipeJson);
                recipes.add(recipe);
                
              } catch (e) {
                print('❌ Error parsing recipe $i: $e');
                continue;
              }
            }
            
          } else if (responseData is Map<String, dynamic>) {
            // Response adalah object dengan nested data
            Map<String, dynamic> responseMap = responseData;
            List<String> possibleKeys = ['recipes', 'data', 'items', 'results'];
            
            for (String key in possibleKeys) {
              if (responseMap.containsKey(key) && responseMap[key] is List) {
                List<dynamic> recipesJson = responseMap[key];
                print('✅ Found recipes in key: $key');
                
                for (var recipeJson in recipesJson) {
                  try {
                    Recipe recipe = Recipe.fromJson(recipeJson);
                    recipes.add(recipe);
                  } catch (e) {
                    print('❌ Error parsing recipe: $e');
                  }
                }
                break;
              }
            }
          }
          
          // Update state
          recommendedRecipes.value = recipes;
          this.recipes.value = recipes; // For compatibility
          
          // Extract ingredients dari semua recipes
          _extractAllIngredients(recipes);
          
          print('✅ Successfully loaded ${recipes.length} recipes');
          print('🥬 Total detected ingredients: ${detectedIngredients.length}');
          
          if (recipes.isNotEmpty) {
            print('🍳 Sample recipes:');
            for (int i = 0; i < recipes.length && i < 3; i++) {
              print('   ${i + 1}. ${recipes[i].title}');
            }
          }

          // Show success message
          _showSuccessMessage(
            'Berhasil!', 
            'Ditemukan ${recipes.length} rekomendasi resep'
          );
          
          return true;
          
        } catch (e) {
          print('❌ JSON Parsing Error: $e');
          throw Exception('Gagal memproses response: $e');
        }
      } else {
        return _handleErrorResponse(response);
      }
      
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Exception in getRecipeRecommendations: $e');
      
      _showErrorMessage(
        'Error',
        _getReadableErrorMessage(e.toString()),
      );
      
      return false;
    } finally {
      isRecommending.value = false;
      print('🏁 Recipe recommendations request finished');
    }
  }

  /// Extract unique ingredients dari semua recipes
  void _extractAllIngredients(List<Recipe> recipes) {
    Set<String> uniqueIngredients = {};
    
    for (Recipe recipe in recipes) {
      // From cleaned_ingredients
      for (String ingredient in recipe.cleanedIngredients) {
        if (ingredient.trim().isNotEmpty) {
          uniqueIngredients.add(ingredient.trim().toLowerCase());
        }
      }
      
      // From ingredients_serving (extract ingredient names)
      for (String ingredientServing in recipe.ingredientsServing) {
        try {
          // Extract ingredient name from "quantity ingredient" format
          List<String> parts = ingredientServing.split(' ');
          if (parts.length >= 2) {
            // Skip quantity, get ingredient name
            String ingredient = parts.skip(1).join(' ').trim().toLowerCase();
            if (ingredient.isNotEmpty) {
              uniqueIngredients.add(ingredient);
            }
          }
        } catch (e) {
          print('❌ Error extracting ingredient from: $ingredientServing');
        }
      }
    }
    
    detectedIngredients.value = uniqueIngredients.toList();
    predictedIngredients.value = uniqueIngredients.toList(); // For compatibility
    
    print('🥬 Extracted ${detectedIngredients.length} unique ingredients');
    print('🥬 Sample ingredients: ${detectedIngredients.take(10).toList()}${detectedIngredients.length > 10 ? '...' : ''}');
  }

  bool _handleErrorResponse(http.Response response) {
    String errorMsg = 'HTTP Error ${response.statusCode}';
    
    try {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      errorMsg = errorData['message'] ?? errorMsg;
      
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        List<String> errorMessages = [];
        
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errorMessages.add('$key: ${value.first}');
          }
        });
        
        if (errorMessages.isNotEmpty) {
          errorMsg = errorMessages.join('\n');
        }
      }
    } catch (e) {
      print('❌ Could not parse error response: $e');
    }
    
    throw Exception(errorMsg);
  }

  /// Helper methods
  String _getReadableErrorMessage(String error) {
    if (error.contains('Token tidak ditemukan')) {
      return 'Sesi Anda telah berakhir. Silakan login ulang.';
    } else if (error.contains('Connection failed') || error.contains('timeout')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
    } else if (error.contains('422')) {
      return 'Format gambar tidak valid. Coba dengan gambar lain.';
    } else if (error.contains('500')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    } else if (error.contains('Ukuran file terlalu besar')) {
      return 'Ukuran gambar terlalu besar. Pilih gambar yang lebih kecil.';
    } else {
      return 'Terjadi kesalahan: ${error.replaceAll('Exception: ', '')}';
    }
  }

  void _showSuccessMessage(String title, String message) {
    Future.microtask(() {
      Get.snackbar(
        title,
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
      );
    });
  }

  void _showErrorMessage(String title, String message) {
    Future.microtask(() {
      Get.snackbar(
        title,
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(16),
      );
    });
  }

  /// Debug methods
  void debugPrintCurrentState() {
    print('🔍 CURRENT RECIPE CONTROLLER STATE:');
    print('⏳ Is Loading: ${isLoading.value}');
    print('🔄 Is Recommending: ${isRecommending.value}');
    print('🥬 Detected Ingredients: ${detectedIngredients.value}');
    print('🍳 Recommended Recipes Count: ${recommendedRecipes.length}');
    print('❌ Error Message: ${errorMessage.value}');
    
    if (recommendedRecipes.isNotEmpty) {
      print('🍳 First Recipe Details:');
      Recipe first = recommendedRecipes.first;
      print('   - ID: ${first.id}');
      print('   - Title: ${first.title}');
      print('   - Image URL: ${first.imageUrl}');
      print('   - Ingredients: ${first.cleanedIngredients}');
    }
  }

  // Get recipe by index for UI
  Recipe? getRecipeAt(int index) {
    if (index >= 0 && index < recommendedRecipes.length) {
      return recommendedRecipes[index];
    }
    return null;
  }

  // Check if has recommendations
  bool get hasRecommendations => recommendedRecipes.isNotEmpty;
  
  // Get recipes count
  int get recipesCount => recommendedRecipes.length;

  /// Test methods for debugging
  Future<bool> testServerHealth() async {
    try {
      print('🏥 Testing server health...');
      
      String? token = await AuthService.getToken();
      if (token == null) {
        print('❌ No token for health check');
        return false;
      }

      final response = await http.get(
        Uri.parse('${RoutesApi.baseUrl}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print('🏥 Health check - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Server is healthy');
        return true;
      } else {
        print('❌ Server health issue: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Server health check failed: $e');
      return false;
    }
  }
}