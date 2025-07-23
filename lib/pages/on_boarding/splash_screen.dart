import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resepin/services/auth_service.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/pages/on_boarding/auth/login_page.dart';
import 'package:resepin/pages/main_page.dart';
import 'package:resepin/theme/appColors.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleScaleAnimation;
  late Animation<Offset> _circlePositionAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _circlePositionAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _circleScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(
          const Duration(milliseconds: 500),
          () => _checkAuthStatus(),
        );
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      bool isAuthenticated = await AuthService.isAuthenticated();

      if (isAuthenticated) {
        final authController = Get.put(AuthController());
        await authController.loadSavedData();

        Get.offAll(
          () => const MainPage(),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 500),
        );
      } else {
        Get.offAll(
          () => const LoginPage(),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      Get.offAll(
        () => const LoginPage(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Center(
                child: SlideTransition(
                  position: _circlePositionAnimation,
                  child: Transform.scale(
                    scale: _circleScaleAnimation.value,
                    child: Container(
                      width: screenSize.width * 0.8,
                      height: screenSize.width * 0.8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: _logoOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Image.asset(
                      'assets/logo-putih.png',
                      width: screenSize.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}