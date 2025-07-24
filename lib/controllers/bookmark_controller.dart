import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:resepin/api/api_controller.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/controllers/recipe_controller.dart';

class BookmarkController extends GetxController {
  AuthController get _authController => Get.find<AuthController>();
  
  var bookmarkedRecipes = <Recipe>[].obs;
  var isLoading = false.obs;
  var bookmarkedRecipeIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(milliseconds: 100), () {
      fetchBookmarks();
    });
  }

  bool isBookmarked(int recipeId) {
    return bookmarkedRecipeIds.contains(recipeId);
  }

  String? _getToken() {
    try {
      final token = _authController.accessToken.value;
      if (token.isEmpty) {
        return null;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addBookmark(Recipe recipe) async {
    try {
      isLoading.value = true;
      
      final token = _getToken();
      if (token == null) {
        _showErrorMessage('Error', 'Silakan login terlebih dahulu');
        return false;
      }

      final response = await http.post(
        Uri.parse(RoutesApi.addBookmarkUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipe_id': recipe.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['message'] == 'Recipe bookmarked successfully') {
          if (!bookmarkedRecipeIds.contains(recipe.id)) {
            bookmarkedRecipes.add(recipe);
            bookmarkedRecipeIds.add(recipe.id);
          }
          
          _showSuccessMessage('Bookmark', 'Resep berhasil ditambahkan ke bookmark');
          return true;
        }
      } else if (response.statusCode == 401) {
        _showErrorMessage('Error', 'Token tidak valid. Silakan login ulang');
        _authController.logout();
        return false;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMsg = data['message'] ?? 'Gagal menambahkan bookmark';
        _showErrorMessage('Error', errorMsg);
        return false;
      }
      
      _showErrorMessage('Error', 'Gagal menambahkan bookmark');
      return false;
      
    } catch (e) {
      _showErrorMessage('Error', 'Terjadi kesalahan saat menambahkan bookmark');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeBookmark(int recipeId) async {
    try {
      isLoading.value = true;
      
      final token = _getToken();
      if (token == null) {
        _showErrorMessage('Error', 'Silakan login terlebih dahulu');
        return false;
      }

      final response = await http.post(
        Uri.parse(RoutesApi.removeBookmarkUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipe_id': recipeId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['message'] == 'Recipe bookmark removed successfully') {
          bookmarkedRecipes.removeWhere((recipe) => recipe.id == recipeId);
          bookmarkedRecipeIds.remove(recipeId);
          
          _showSuccessMessage('Bookmark', 'Resep berhasil dihapus dari bookmark');
          return true;
        }
      } else if (response.statusCode == 401) {
        _showErrorMessage('Error', 'Token tidak valid. Silakan login ulang');
        _authController.logout();
        return false;
      }
      
      _showErrorMessage('Error', 'Gagal menghapus bookmark');
      return false;
      
    } catch (e) {
      _showErrorMessage('Error', 'Terjadi kesalahan saat menghapus bookmark');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      isLoading.value = true;
      
      final token = _getToken();
      if (token == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(RoutesApi.listBookmarkUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          List<Recipe> recipes = [];
          Set<int> recipeIds = {};
          
          for (var item in data) {
            try {
              if (item != null && item['recipe'] != null) {
                var recipeData = item['recipe'];
                Recipe recipe = Recipe.fromJson(recipeData);
                
                if (recipe.id > 0 && recipe.title.isNotEmpty) {
                  recipes.add(recipe);
                  recipeIds.add(recipe.id);
                }
              }
            } catch (e) {
              continue;
            }
          }
          
          bookmarkedRecipes.value = recipes;
          bookmarkedRecipeIds.value = recipeIds;
        } else {
          bookmarkedRecipes.clear();
          bookmarkedRecipeIds.clear();
        }
      } else if (response.statusCode == 401) {
        _authController.logout();
      }
      
    } catch (e) {
      // Silent error handling
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(Recipe recipe) async {
    if (isBookmarked(recipe.id)) {
      await removeBookmark(recipe.id);
    } else {
      await addBookmark(recipe);
    }
  }

  Future<void> refreshBookmarks() async {
    await fetchBookmarks();
  }

  void clearBookmarks() {
    bookmarkedRecipes.clear();
    bookmarkedRecipeIds.clear();
  }

  void _showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
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

  Future<Recipe?> getRecipeDetail(int recipeId) async {
    try {
      final RecipeController recipeController = Get.find<RecipeController>();
      return await recipeController.getRecipeDetail(recipeId);
    } catch (e) {
      try {
        final RecipeController recipeController = Get.put(RecipeController());
        return await recipeController.getRecipeDetail(recipeId);
      } catch (e2) {
        _showErrorMessage('Error', 'Terjadi kesalahan saat memuat detail resep');
        return null;
      }
    }
  }
}
