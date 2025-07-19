import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/theme/appColors.dart';

class DetailResepPage extends StatefulWidget {
  final String recipeName;
  
  const DetailResepPage({
    super.key,
    this.recipeName = "Nasi Goreng Seafood",
  });

  @override
  State<DetailResepPage> createState() => _DetailResepPageState();
}

class _DetailResepPageState extends State<DetailResepPage> {
  bool isFavorite = false;

  final List<Map<String, dynamic>> ingredients = [
    {"name": "Jasmine Rice", "amount": "2 Cups", "calories": "1299.0"},
    {"name": "Ketchup", "amount": "3 Tbsp", "calories": "45.0"},
    {"name": "Sesame Oil", "amount": "2 Tbsp", "calories": "240.0"},
    {"name": "Udang Segar", "amount": "200g", "calories": "85.0"},
    {"name": "Cumi-cumi", "amount": "150g", "calories": "92.0"},
    {"name": "Telur", "amount": "2 butir", "calories": "155.0"},
    {"name": "Bawang Merah", "amount": "3 siung", "calories": "16.0"},
    {"name": "Bawang Putih", "amount": "4 siung", "calories": "18.0"},
    {"name": "Cabai Merah", "amount": "2 buah", "calories": "8.0"},
    {"name": "Kecap Manis", "amount": "2 Tbsp", "calories": "35.0"},
  ];

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
                    child: Text(
                      widget.recipeName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      Get.snackbar(
                        isFavorite ? "Bookmart" : "Dihapus", 
                        isFavorite ? "Resep ditambahkan ke Bookmark" : "Resep dihapus dari bookmark",
                        backgroundColor: isFavorite ? Colors.green : Colors.grey,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
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
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop',
                          ),
                          fit: BoxFit.cover,
                          onError: (error, stackTrace) {},
                        ),
                        color: Colors.orange.shade100,
                      ),
                      child: Container(
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
                    ),

                    SizedBox(height: height * 0.03),

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
                            flex: 3,
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
                            flex: 2,
                            child: Text(
                              "TAKARAN",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "CALORIES",
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
                        children: ingredients.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> ingredient = entry.value;
                          
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: index != ingredients.length - 1
                                    ? BorderSide(color: Colors.grey.shade200, width: 1)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    ingredient["name"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    ingredient["amount"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${ingredient["calories"]} cal",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

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
                            "Total Kalori:",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          Text(
                            "${_calculateTotalCalories()} cal",
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
                            "Petunjuk Memasak:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          _buildCookingStep(
                            1,
                            "Remukkan roti menjadi potongan-potongan kecil. Siram dengan air dingin, tutup dengan kain basah dan biarkan selama 30 menit.",
                          ),
                          _buildCookingStep(
                            2,
                            "Panaskan 2 sdt minyak zaitun dalam wajan yang dalam.",
                          ),
                          _buildCookingStep(
                            3,
                            "Tambahkan siung bawang putih yang sudah dipisahkan, kulitnya masih utuh, buat sayatan kecil dengan pisau untuk membukanya dan terus goreng selama 5 menit.",
                          ),
                          _buildCookingStep(
                            4,
                            "Sisihkan bawang putih. Dalam minyak yang tersisa, tempat kita menggoreng semuanya, didihkan roti, aduk terus selama 15 menit dan tambahkan lada hitam bubuk.",
                          ),
                          _buildCookingStep(
                            5,
                            "Tambahkan bawang putih, terus aduk selama sekitar 20 menit. Roti akan siap saat sudah lembut dan berwarna keemasan.",
                          ),
                        ],
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

  String _calculateTotalCalories() {
    double total = 0;
    for (var ingredient in ingredients) {
      total += double.parse(ingredient["calories"]);
    }
    return total.toStringAsFixed(1);
  }
}