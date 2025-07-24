import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/controllers/bookmark_controller.dart';
import 'package:resepin/controllers/recipe_controller.dart';
import 'package:resepin/pages/custom/custom_card_resep_bookmark.dart';
import 'package:resepin/pages/detail_resep_page.dart';
import 'package:resepin/theme/appColors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final AuthController authController = Get.put(AuthController());
    final BookmarkController bookmarkController = Get.put(BookmarkController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.07,
                vertical: height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo ${authController.currentUser.value?.name ?? "User"}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    "Mau masak apa hari ini?",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: height * 0.025),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF6F6F6),
                      hintText: "Cari Resep...",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search, 
                        color: AppColors.primary,
                        size: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  // Section Title dengan refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                        "Resep Bookmark (${bookmarkController.bookmarkedRecipes.length})",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      )),
                      IconButton(
                        onPressed: () => bookmarkController.refreshBookmarks(),
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                ],
              ),
            ),
            // GridView Section (Scrollable)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.07),
                child: Obx(() {
                  // Debug info
                  print('🏠 HOME: Loading: ${bookmarkController.isLoading.value}');
                  print('🏠 HOME: Bookmarks count: ${bookmarkController.bookmarkedRecipes.length}');
                  
                  if (bookmarkController.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat bookmark...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (bookmarkController.bookmarkedRecipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Belum ada resep bookmark",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tambahkan resep ke bookmark untuk melihatnya di sini",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => bookmarkController.refreshBookmarks(),
                            child: Text(
                              'Refresh Bookmark',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: bookmarkController.bookmarkedRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = bookmarkController.bookmarkedRecipes[index];
                      return _buildBookmarkCard(recipe, bookmarkController, context);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update _buildBookmarkCard untuk handle empty ingredients:

  Widget _buildBookmarkCard(Recipe recipe, BookmarkController bookmarkController, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => DetailResepPage(),
          arguments: recipe,
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: recipe.imageUrl.isNotEmpty
                          ? Image.network(
                              recipe.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
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
                                      size: 40,
                                      color: Colors.orange.shade400,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.orange.shade100,
                              child: Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 40,
                                  color: Colors.orange.shade400,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Bookmark button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => bookmarkController.removeBookmark(recipe.id),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
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
                    Text(
                      recipe.title.isNotEmpty ? recipe.title : 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Cookpad Recipe",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
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
}
