import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/services/auth_service.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';

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
    try {
      // Safe integer conversion
      int recipeId;
      if (json['id'] is int) {
        recipeId = json['id'];
      } else if (json['id'] is String) {
        recipeId = int.tryParse(json['id']) ?? 0;
      } else {
        recipeId = 0;
      }

      // Safe list parsing untuk ingredients_serving
      List<String> parseIngredientsServing(dynamic data) {
        try {
          if (data == null) return [];
          
          if (data is String) {
            return [data];
          } else if (data is List) {
            return data.map((e) => e.toString()).toList();
          }
          
          return [];
        } catch (e) {
          print('❌ Error parsing ingredients_serving: $e');
          return [];
        }
      }

      // Safe list parsing untuk cleaned_ingredients
      List<String> parseCleanedIngredients(dynamic data) {
        try {
          if (data == null) return [];
          
          if (data is List) {
            return data.map((e) => e.toString()).toList();
          } else if (data is String) {
            return [data];
          }
          
          return [];
        } catch (e) {
          print('❌ Error parsing cleaned_ingredients: $e');
          return [];
        }
      }

      return Recipe(
        id: recipeId,
        title: json['title']?.toString() ?? '',
        fullUrl: json['full_url']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        searchIndex: json['search_index']?.toString(),
        steps: json['steps']?.toString() ?? '',
        ingredientsServing: parseIngredientsServing(json['ingredients_serving']),
        cleanedIngredients: parseCleanedIngredients(json['cleaned_ingredients']),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
    } catch (e) {
      print('❌ Error parsing Recipe from JSON: $e');
      print('❌ JSON data: $json');
      
      // Return default recipe dengan minimal data
      return Recipe(
        id: 0,
        title: 'Unknown Recipe',
        fullUrl: '',
        imageUrl: '',
        steps: '',
        ingredientsServing: [],
        cleanedIngredients: [],
      );
    }
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
      // From cleaned_ingredients (ini yang lebih bersih)
      for (String ingredient in recipe.cleanedIngredients) {
        if (ingredient.trim().isNotEmpty) {
          String cleanIngredient = ingredient.trim().toLowerCase();
          // Remove common words dan bersihkan
          cleanIngredient = _cleanIngredientName(cleanIngredient);
          if (cleanIngredient.isNotEmpty) {
            uniqueIngredients.add(cleanIngredient);
          }
        }
      }
      
      // From ingredients_serving - parse JSON format
      for (String ingredientServing in recipe.ingredientsServing) {
        try {
          if (ingredientServing.startsWith('[') && ingredientServing.endsWith(']')) {
            var parsed = jsonDecode(ingredientServing);
            if (parsed is List) {
              for (var item in parsed) {
                if (item is List && item.length >= 2) {
                  // item[1] adalah nama ingredient
                  String ingredientName = item[1].toString().toLowerCase().trim();
                  ingredientName = _cleanIngredientName(ingredientName);
                  if (ingredientName.isNotEmpty) {
                    uniqueIngredients.add(ingredientName);
                  }
                }
              }
            }
          }
        } catch (e) {
          print('❌ Error parsing ingredients_serving: $e');
        }
      }
    }
    
    // Sort dan ambil yang paling umum
    List<String> sortedIngredients = uniqueIngredients.toList()..sort();
    
    detectedIngredients.value = sortedIngredients;
    predictedIngredients.value = sortedIngredients; // For compatibility
    
    print('🥬 Extracted ${detectedIngredients.length} unique ingredients');
    print('🥬 Clean ingredients: ${detectedIngredients.take(15).toList()}');
  }

  /// Helper method untuk membersihkan nama ingredient
  String _cleanIngredientName(String ingredient) {
    // Remove common words dan bersihkan
    String cleaned = ingredient.toLowerCase().trim();
    
    // Remove common prefixes dan suffixes
    List<String> wordsToRemove = [
      'piece', 'pieces', 'large', 'small', 'medium', 'firm', 'fresh', 'dried',
      'chopped', 'sliced', 'minced', 'ground', 'coarse', 'fine', 'needed',
      'tablespoon', 'tablespoons', 'teaspoon', 'teaspoons', 'cup', 'cups',
      'gram', 'grams', 'kg', 'ml', 'liter', 'liters', 'lb', 'ounce', 'ounces',
      'for', 'with', 'and', 'or', 'of', 'the', 'a', 'an', 'to', 'in', 'on',
      'package', 'packages', 'bottle', 'bottles', 'can', 'cans', 'jar', 'jars'
    ];
    
    // Split into words and filter
    List<String> words = cleaned.split(' ');
    List<String> filteredWords = [];
    
    for (String word in words) {
      word = word.trim();
      // Skip empty, numbers, atau common words
      if (word.isNotEmpty && 
          !wordsToRemove.contains(word) && 
          !RegExp(r'^\d+(\.\d+)?$').hasMatch(word) &&
          word.length > 2) {
        filteredWords.add(word);
      }
    }
    
    // Join back dan clean up
    String result = filteredWords.join(' ').trim();
    
    // Additional cleaning
    result = result.replaceAll(RegExp(r'\[|\]|\(|\)'), '');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    
    return result;
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

  /// Get detailed recipe data by ID (for all sources)
  Future<Recipe?> getRecipeDetail(int recipeId) async {
    try {
      // Get authentication token using AuthService (consistent dengan method lain)
      String? token = await AuthService.getToken();
      if (token == null) {
        print('❌ No authentication token available');
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final String url = RoutesApi.detailUrl(recipeId);
      print('🔍 Fetching recipe detail for ID: $recipeId');
      print('🔍 Full URL: $url');
      print('🔍 Using token: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Detail Response: ${response.statusCode}');
      print('🔍 Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse recipe data
        if (data != null) {
          Recipe recipe = Recipe.fromJson(data);
          print('✅ Loaded detailed recipe: ${recipe.title}');
          print('✅ Ingredients count: ${recipe.cleanedIngredients.length}');
          print('✅ Steps available: ${recipe.steps.isNotEmpty}');
          
          return recipe;
        }
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - token may be expired');
        
        // Simple handling: just log and return null
        print('⚠️ Token invalid, user may need to login again');
        
        // Show error message via snackbar
        _showErrorMessage(
          'Sesi Berakhir',
          'Token telah berakhir. Silakan login ulang untuk melihat detail.'
        );
        
        return null;
      } else if (response.statusCode == 404) {
        print('❌ Recipe not found');
        return null;
      } else {
        print('❌ Failed to load recipe detail: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
      
      return null;
      
    } catch (e) {
      print('❌ Error getting recipe detail: $e');
      return null;
    }
  }
}