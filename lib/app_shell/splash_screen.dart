import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/data/models/user_model.dart';
import 'package:hybrid_erp_app/data/services/storage_service.dart';
import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/features/dashboard/pages/main_screen.dart';
import 'package:hybrid_erp_app/resources/generated/assets.gen.dart';
import 'package:hybrid_erp_app/shared/constants/app_constants.dart';
import 'package:hybrid_erp_app/shared/dimens/app_dimen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Start logo animation
    await _logoController.forward();

    // Start fade animation for text
    await _fadeController.forward();

    // Wait a bit more for better UX and to ensure all services are initialized
    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to appropriate screen
    if (mounted) {
      await _navigateToAppropriateScreen();
    }
  }

  Future<void> _navigateToAppropriateScreen() async {
    try {
      // Add a small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 200));

      final UserModel? savedUser = await StorageService.getUserCredentials();

      if (savedUser != null &&
          savedUser.rememberMe &&
          savedUser.isValid &&
          await StorageService.isUserLoggedIn()) {
        // Auto-login if remember me is enabled
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MainScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      } else {
        // Navigate to sign-in page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SignInPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      }
    } catch (e) {
      // If there's an error, navigate to sign-in page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SignInPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.background.provider(),
            fit: BoxFit.cover,
            opacity: 0.8,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.multiply),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 240.0.resp(small: 160),
                          height: 120.0.resp(small: 80),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(
                                240.0.resp(small: 160) / 2,
                                120.0.resp(small: 80) / 2,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 140.0.resp(small: 100),
                            height: 80.0.resp(small: 40),
                            child: Assets.images.appLogo.image(
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // App Title Section
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.APP_NAME,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.APP_SUBTITLE,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Loading indicator
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Version info
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.7,
                      child: Text(
                        'Phiên bản ${AppConstants.APP_VERSION}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
