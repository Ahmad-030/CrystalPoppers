import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/audio_manager.dart';
import '../utils/app_theme.dart';

/// Compact toggle button showing 🎵 / 🔇.
/// Can be sized via [size]; default 44.
class MusicToggleButton extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const MusicToggleButton({
    super.key,
    this.size = 44,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<MusicToggleButton> createState() => _MusicToggleButtonState();
}

class _MusicToggleButtonState extends State<MusicToggleButton> {
  final AudioManager _audio = AudioManager.instance;

  @override
  void initState() {
    super.initState();
    _audio.addListener(_rebuild);
  }

  @override
  void dispose() {
    _audio.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _audio.musicEnabled;
    return GestureDetector(
      onTap: () => _audio.toggleMusic(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (enabled
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.4)
                : Colors.grey.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: enabled
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 8)]
              : [],
        ),
        child: Center(
          child: Text(
            enabled ? '🎵' : '🔇',
            style: TextStyle(fontSize: widget.size * 0.46),
          ).animate(key: ValueKey(enabled)).scale(
                begin: const Offset(0.6, 0.6),
                duration: 200.ms,
                curve: Curves.elasticOut,
              ),
        ),
      ),
    );
  }
}

/// Full-row music + SFX toggle row — used in Settings screen.
class AudioSettingsRow extends StatefulWidget {
  const AudioSettingsRow({super.key});
  @override
  State<AudioSettingsRow> createState() => _AudioSettingsRowState();
}

class _AudioSettingsRowState extends State<AudioSettingsRow> {
  final AudioManager _audio = AudioManager.instance;

  @override
  void initState() {
    super.initState();
    _audio.addListener(_rebuild);
  }

  @override
  void dispose() {
    _audio.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleRow(
          label: 'Background Music',
          emoji: _audio.musicEnabled ? '🎵' : '🔇',
          value: _audio.musicEnabled,
          onChanged: (_) => _audio.toggleMusic(),
        ),
        const SizedBox(height: 12),
        _buildToggleRow(
          label: 'Sound Effects',
          emoji: _audio.sfxEnabled ? '🔊' : '🔈',
          value: _audio.sfxEnabled,
          onChanged: (_) => _audio.toggleSfx(),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String emoji,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
