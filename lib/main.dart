import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/controllers/bookmark_controller.dart';
import 'package:resepin/controllers/recipe_controller.dart';
import 'package:resepin/pages/on_boarding/splash_screen.dart';
import 'package:resepin/pages/on_boarding/auth/login_page.dart';
import 'package:resepin/pages/main_page.dart';
import 'package:resepin/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Resepin',
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const MainPage()),
        GetPage(name: '/splash', page: () => const SplashScreenPage()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(RecipeController());
        Get.put(BookmarkController());
      }),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreenPage();
  }
}