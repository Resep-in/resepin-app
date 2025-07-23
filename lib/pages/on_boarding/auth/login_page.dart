import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resepin/controllers/auth/auth_controller.dart';
import 'package:resepin/pages/on_boarding/auth/register_page.dart';
import 'package:resepin/theme/appColors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  bool _obsecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true, // Tambah ini untuk handle keyboard
      body: SingleChildScrollView( // Wrap dengan SingleChildScrollView
        child: ConstrainedBox( // Maintain height
          constraints: BoxConstraints(
            minHeight: height,
          ),
          child: IntrinsicHeight( // Auto adjust height
            child: Padding(
              padding: EdgeInsets.only(top: height * 0.1),
              child: Center(
                child: Column(
                  children: [
                    // header
                    Text(
                      "Log in",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.025),
                    Text(
                      "Silahkan Masukkan Email dan Password anda",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.07),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(47),
                            topRight: Radius.circular(47),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.07),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Tambah ini
                            children: [
                              // SizedBox(height: height * 0.05), 
                              
                              // email
                              Text(
                                "Email",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Email",
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 30,
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),
                              // end email
                              SizedBox(height: height * 0.02),
                              
                              // password
                              Text(
                                "Password",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obsecurePassword,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Password",
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 30,
                                      horizontal: 10,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obsecurePassword = !_obsecurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obsecurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 26,
                                      ),
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              // end password
                              SizedBox(height: height * 0.02),

                              // button login dengan loading state
                              Obx(() => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null // Disable button saat loading
                                      : () async {
                                          // Validasi input
                                          if (_authController.validateLoginInput(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          )) {
                                            // Panggil method login
                                            await _authController.login(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _authController.isLoading.value
                                        ? AppColors.primary.withOpacity(0.6)
                                        : AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  child: _authController.isLoading.value
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Loading...",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "Login",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              )),

                              SizedBox(height: height * 0.02),
                              
                              // button register
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Belum punya akun?",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => RegisterPage());
                                    },
                                    child: Text(
                                      " Sign Up",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: height * 0.05), // Tambah spacing bawah
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
