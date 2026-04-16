import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/music_toggle_button.dart';
import '../widgets/double_back_exit.dart';
import 'level_map_screen.dart';
import 'shop_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      message: 'Press back again to exit CrystalPopperz',
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient (replace Container with Image.asset when bg image added)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5F0FF),
                    Color(0xFFEDE0FF),
                    Color(0xFFFFEDF5),
                    Color(0xFFE8F4FF),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),

            // Bg blobs
            Positioned(top: -80, right: -60, child: _blob(200, AppColors.primaryLight.withOpacity(0.14))),
            Positioned(bottom: -100, left: -80, child: _blob(250, AppColors.accent.withOpacity(0.11))),
            Positioned(top: 200, left: -50, child: _blob(140, AppColors.accentBlue.withOpacity(0.09))),

            // Floating crystal deco
            ..._floatingCrystals(context),

            // Music toggle — top right
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16),
                  child: const MusicToggleButton(size: 46),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Logo
                      AnimatedBuilder(
                        animation: _floatCtrl,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, -8 * _floatCtrl.value),
                          child: child,
                        ),
                        child: Column(
                          children: [
                            Text('💎', style: const TextStyle(fontSize: 72))
                                .animate()
                                .scale(duration: 700.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 8),
                            Text(
                              'CrystalPopperz',
                              style: GoogleFonts.fredoka(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [Color(0xFF6C3FC5), Color(0xFFFF6B9D)],
                                  ).createShader(const Rect.fromLTWH(0, 0, 290, 50)),
                                shadows: [Shadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
                              ),
                            ),
                            Text(
                              'Match. Blast. Solve. Progress.',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 44),

                      // PLAY button
                      _mainButton(
                        label: 'PLAY',
                        icon: '🎮',
                        gradient: const LinearGradient(colors: [Color(0xFF9B6EF3), Color(0xFF6C3FC5)]),
                        onTap: () => Navigator.push(context, _route(const LevelMapScreen())),
                        delay: 100,
                      ),
                      const SizedBox(height: 16),

                      // Secondary buttons row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          children: [
                            Expanded(child: _secondaryButton(context, '🛍', 'Shop', () => Navigator.push(context, _route(const ShopScreen())), 200)),
                            const SizedBox(width: 10),
                            Expanded(child: _secondaryButton(context, 'ℹ️', 'About', () => Navigator.push(context, _route(const AboutScreen())), 250)),
                            const SizedBox(width: 10),
                            Expanded(child: _secondaryButton(context, '⚙️', 'Settings', () => Navigator.push(context, _route(const SettingsScreen())), 300)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Crystal showcase strip
                      _crystalStrip(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  List<Widget> _floatingCrystals(BuildContext context) {
    final items = [
      {'e': '💎', 'x': 0.07, 'y': 0.18, 'fs': 26.0, 'd': 0},
      {'e': '🔷', 'x': 0.87, 'y': 0.22, 'fs': 22.0, 'd': 400},
      {'e': '🔥', 'x': 0.04, 'y': 0.55, 'fs': 20.0, 'd': 800},
      {'e': '⚡', 'x': 0.90, 'y': 0.55, 'fs': 22.0, 'd': 200},
      {'e': '💣', 'x': 0.12, 'y': 0.82, 'fs': 18.0, 'd': 600},
      {'e': '💜', 'x': 0.83, 'y': 0.82, 'fs': 22.0, 'd': 1000},
    ];
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return items.map((item) {
      final delay = item['d'] as int;
      return Positioned(
        left: (item['x'] as double) * w,
        top: (item['y'] as double) * h,
        child: AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -12 * _floatCtrl.value + delay / 500),
            child: child,
          ),
          child: Text(item['e'] as String, style: TextStyle(fontSize: item['fs'] as double, color: AppColors.primary.withOpacity(0.3)))
              .animate(delay: delay.ms).fadeIn(duration: 600.ms),
        ),
      );
    }).toList();
  }

  Widget _mainButton({
    required String label,
    required String icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6C3FC5).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ).animate(delay: delay.ms).slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
    );
  }

  Widget _secondaryButton(BuildContext context, String icon, String label, VoidCallback onTap, int delay) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ],
        ),
      ).animate(delay: delay.ms).slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
    );
  }

  Widget _crystalStrip() {
    final crystals = ['💎', '🔷', '💚', '💛', '💜', '🩵', '🟠'];
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: crystals.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Center(child: Text(crystals[i], style: const TextStyle(fontSize: 26))),
        ).animate(delay: (i * 60 + 400).ms).scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);
}
