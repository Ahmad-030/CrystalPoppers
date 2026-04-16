import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/music_toggle_button.dart';

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
                    const SizedBox(height: 10),
                    _infoTile('Version', '1.0.0'),
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ppSection('Privacy Policy', 'Last updated: 2025\n\nThis Privacy Policy describes how CrystalPopperz ("we", "our", or "the game") handles your information.', isTitle: true),
            _ppSection('1. No Data Collection', 'CrystalPopperz does not collect, transmit, or share any personal data. The game is fully offline and requires no internet connection.'),
            _ppSection('2. Local Storage Only', 'Game progress, level completions, and settings are stored locally on your device using Android SharedPreferences. This data never leaves your device.'),
            _ppSection('3. No Permissions Required', 'CrystalPopperz requires no special permissions. We do not access your camera, microphone, contacts, location, or any other device features.'),
            _ppSection('4. No Third-Party Tracking', 'We do not use any third-party analytics, advertising SDKs, or tracking tools. No data is shared with any third party.'),
            _ppSection('5. No Internet Access', 'The game operates completely offline. No network requests are made at any time.'),
            _ppSection('6. Children\'s Privacy', 'CrystalPopperz is safe for all ages. Since we collect no data, there are no privacy concerns for children or minors.'),
            _ppSection('7. Contact', 'If you have any questions about this Privacy Policy, please contact us at:\n\n${AppConstants.devEmail}'),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2025 ${AppConstants.developerName}\nAll rights reserved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ppSection(String title, String body, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: isTitle ? 26 : 16,
              fontWeight: FontWeight.w700,
              color: isTitle ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          if (!isTitle) Divider(color: AppColors.primary.withOpacity(0.1), height: 24),
        ],
      ),
    );
  }
}
