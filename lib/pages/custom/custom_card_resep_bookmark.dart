import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/theme/appColors.dart';

class CustomCardResepBookmark extends StatelessWidget {
  const CustomCardResepBookmark({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 200, // Add fixed height to prevent unbounded constraints
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
            left: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
            right: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    "assets/resep.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Color(0xFFE0E0E0),
                        child: Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    "Nama Masakan",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
