import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/pages/custom/custom_menu_profile.dart';
import 'package:resepin/pages/profile/edit_password_page.dart';
import 'package:resepin/pages/profile/edit_profile_page.dart';
import 'package:resepin/pages/profile/info_aplikasi_page.dart';
import 'package:resepin/theme/appColors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // start header profile
          Container(
            height: height * 0.3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(141, 254, 115, 76),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  // backgroundImage: AssetImage('assets/profile_image.png'),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  "Daus",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "admin@gmail.com",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // end header profile
          SizedBox(height: height * 0.02),
          //start menu list
          Column(
            children: [
              CustomMenuProfile(
                title: 'Edit Profile',
                icon: Icons.person,
                onTap: () {
                  Get.to(EditProfilePage());
                },
              ),
              CustomMenuProfile(
                title: 'Edit Password',
                icon: Icons.lock,
                onTap: () {
                  Get.to(EditPasswordPage());
                },
              ),
              CustomMenuProfile(
                title: 'Info Aplikasi',
                icon: Icons.info,
                onTap: () {
                  Get.to(InfoAplikasiPage());
                },
              ),
            ],
          ),
          //end menu list
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
