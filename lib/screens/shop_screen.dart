import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Shop', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('0', style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionLabel('⚡ Power-Ups'),
                    const SizedBox(height: 10),
                    _shopItem(context, '🔥', 'Fire Crystal', 'Clears an entire row instantly', '50 💎', 0),
                    _shopItem(context, '💣', 'Bomb Crystal', 'Explodes a 3×3 area', '80 💎', 1),
                    _shopItem(context, '⚡', 'Lightning Crystal', 'Clears all crystals of one color', '120 💎', 2),
                    const SizedBox(height: 20),
                    _sectionLabel('🎯 Extra Moves'),
                    const SizedBox(height: 10),
                    _shopItem(context, '🎯', '+5 Moves', 'Get 5 extra moves for this level', '100 💎', 3),
                    _shopItem(context, '🎯', '+10 Moves', 'Get 10 extra moves for this level', '180 💎', 4),
                    const SizedBox(height: 20),
                    _sectionLabel('🛡 Boosters'),
                    const SizedBox(height: 10),
                    _shopItem(context, '🔮', 'Color Burst', 'Removes all crystals of a chosen color', '150 💎', 5),
                    _shopItem(context, '🌀', 'Shuffle Board', 'Reshuffles the entire board', '60 💎', 6),
                    const SizedBox(height: 24),

                    // Earn gems note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentYellow.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complete levels and earn ⭐ stars to collect 💎 gems!',
                              style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
      );

  Widget _shopItem(BuildContext context, String icon, String name, String desc, String price, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEDE0FF), Color(0xFFD4C0FF)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(desc, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showComingSoon(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9B6EF3), Color(0xFF6C3FC5)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(price, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    ).animate(delay: (delay * 60).ms).fadeIn().slideX(begin: 0.1);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Text('🛍  ', style: TextStyle(fontSize: 18)),
          Text('Shop coming soon!', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
