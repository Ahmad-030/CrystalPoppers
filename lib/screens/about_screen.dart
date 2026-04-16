import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F0FF), Color(0xFFFFEDF5), Color(0xFFE8F4FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('About', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // App icon area
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF9B6EF3), Color(0xFF6C3FC5)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: const Center(child: Text('💎', style: TextStyle(fontSize: 56))),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 20),
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          foreground: Paint()
                            ..shader = const LinearGradient(colors: [Color(0xFF6C3FC5), Color(0xFFFF6B9D)]).createShader(const Rect.fromLTWH(0, 0, 250, 44)),
                        ),
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

                      Text(
                        'Match. Blast. Solve. Progress.',
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ).animate(delay: 300.ms).fadeIn(),

                      const SizedBox(height: 28),

                      // Description card
                      _card(
                        child: Column(
                          children: [
                            const Text('📖', style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 10),
                            Text(
                              'CrystalPopperz is a dazzling match-3 puzzle game! Swap and match colorful crystals, create powerful combos, and blast your way through hundreds of exciting levels. With fire crystals, bombs, lightning strikes, and more — every level is a new challenge!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                            ),
                          ],
                        ),
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      // Features
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✨ Features', style: GoogleFonts.fredoka(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            ...[
                              '💎 8×8 Crystal Match-3 Board',
                              '🔥 Fire, Bomb & Lightning Power Crystals',
                              '🧊 Ice, Locked & Stone Obstacles',
                              '🎯 Unique Level Objectives',
                              '🔁 Combo Chain Reactions',
                              '⭐ 3-Star Level Rating System',
                              '🔇 Offline — No Internet Required',
                            ].map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Text(f.substring(0, 2), style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(f.substring(2), style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      // Developer card
                      _card(
                        child: Column(
                          children: [
                            const Text('👨‍💻', style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 8),
                            Text('Developer', style: GoogleFonts.fredoka(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(AppConstants.developerName, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Text(
                                '📧  ${AppConstants.devEmail}',
                                style: GoogleFonts.nunito(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 24),
                      Text(
                        '© 2025 ${AppConstants.developerName}',
                        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
          border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
        ),
        child: child,
      );
}
