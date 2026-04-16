import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/music_toggle_button.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text('Settings', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionTitle('🔊 Audio'),
                    const SizedBox(height: 10),
                    const AudioSettingsRow(),
                    const SizedBox(height: 28),
                    _sectionTitle('🎮 Game'),

                    const SizedBox(height: 8),
                    _infoTile('Developer', AppConstants.developerName),
                    const SizedBox(height: 8),
                    _infoTile('Contact', AppConstants.devEmail),
                    const SizedBox(height: 28),
                    _sectionTitle('📜 Legal'),
                    const SizedBox(height: 10),
                    _linkTile(context, '🔒 Privacy Policy', () => _openPrivacyPolicy(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
  ).animate().fadeIn().slideX(begin: -0.1);

  Widget _infoTile(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
        Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    ),
  );

  Widget _linkTile(BuildContext context, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
        ],
      ),
    ),
  );

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyWebView()));
  }
}