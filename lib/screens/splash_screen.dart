import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainMenuScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (place assets/images/splash_bg.png in project)
          Positioned.fill(
            child: Image.asset(
              'assets/img.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => AnimatedBuilder(
                animation: _bgController,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(const Color(0xFF6C3FC5), const Color(0xFF4A25A0), _bgController.value)!,
                        Color.lerp(const Color(0xFFFF6B9D), const Color(0xFFFF9A3C), _bgController.value)!,
                        Color.lerp(const Color(0xFF4D96FF), const Color(0xFF00D4FF), _bgController.value)!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(top: 70, left: 28, child: Text('💎', style: TextStyle(fontSize: 32, color: Colors.white60))),
          const Positioned(top: 70, right: 28, child: Text('🔷', style: TextStyle(fontSize: 28, color: Colors.white60))),
          const Positioned(bottom: 130, left: 36, child: Text('💚', style: TextStyle(fontSize: 26, color: Colors.white60))),
          const Positioned(bottom: 130, right: 36, child: Text('💛', style: TextStyle(fontSize: 28, color: Colors.white60))),
          const Positioned(top: 210, left: 10, child: Text('⚡', style: TextStyle(fontSize: 22, color: Colors.white54))),
          const Positioned(top: 210, right: 10, child: Text('🔥', style: TextStyle(fontSize: 22, color: Colors.white54))),
          const Positioned(bottom: 250, left: 8, child: Text('💣', style: TextStyle(fontSize: 20, color: Colors.white54))),
          const Positioned(bottom: 250, right: 8, child: Text('💜', style: TextStyle(fontSize: 24, color: Colors.white54))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['💎', '🔷', '💚', '💛', '💜']
                      .asMap()
                      .entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(e.value, style: const TextStyle(fontSize: 34))
                        .animate(delay: (e.key * 100).ms)
                        .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut)
                        .fadeIn(),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Crystal',
                  style: GoogleFonts.fredoka(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [Shadow(color: Color(0xFF4A25A0), blurRadius: 20, offset: Offset(0, 6))],
                  ),
                ).animate(delay: 200.ms).slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                Text(
                  'Popperz',
                  style: GoogleFonts.fredoka(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                    shadows: const [Shadow(color: Color(0xFF4A25A0), blurRadius: 20, offset: Offset(0, 6))],
                  ),
                ).animate(delay: 350.ms).slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                const SizedBox(height: 12),
                Text(
                  'Match. Blast. Solve. Progress.',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 56),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.85)),
                    ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true), delay: (i * 120).ms)
                        .scale(begin: const Offset(0.4, 0.4), end: const Offset(1.3, 1.3), duration: 500.ms),
                  ),
                ).animate(delay: 900.ms).fadeIn(),
                const SizedBox(height: 14),
                Text(
                  'Loading...',
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                ).animate(delay: 900.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}