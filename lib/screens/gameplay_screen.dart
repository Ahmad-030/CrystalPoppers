import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';
import '../widgets/game_board.dart';
import '../widgets/music_toggle_button.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  bool _pauseVisible = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    // Show level complete/game over once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.levelComplete && !_pauseVisible) {
        AudioManager.instance.playWin();
        _showLevelComplete(context, state);
      } else if (state.gameOver && !_pauseVisible) {
        AudioManager.instance.playLose();
        _showGameOver(context, state);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _togglePause(state);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Main game UI
              Column(
                children: [
                  _buildTopBar(context, state),
                  const SizedBox(height: 6),
                  _buildObjectivesBar(state),
                  const SizedBox(height: 8),
                  const Expanded(child: Center(child: GameBoard())),
                  const SizedBox(height: 8),
                  _buildBottomHint(state),
                  const SizedBox(height: 8),
                ],
              ),

              // Combo text pop-up
              if (state.showComboText)
                Center(
                  child: Text(
                    state.comboText,
                    style: GoogleFonts.fredoka(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)],
                        ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 2)),
                      ],
                    ),
                  )
                      .animate()
                      .scale(begin: const Offset(0.5, 0.5), duration: 300.ms, curve: Curves.elasticOut)
                      .then()
                      .scale(end: const Offset(1.2, 1.2), duration: 200.ms),
                ),

              // Pause overlay
              if (_pauseVisible) _buildPauseOverlay(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Pause button
          _iconBtn(
            '⏸',
            onTap: () => _togglePause(state),
            color: AppColors.primary.withOpacity(0.1),
          ),
          const SizedBox(width: 8),
          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${state.config.levelNumber}',
                  style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                Text(
                  state.config.title,
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Score
          _scoreChip(state.score),
          const SizedBox(width: 8),
          // Moves
          _movesChip(state.movesLeft),
          const SizedBox(width: 8),
          // Music toggle
          const MusicToggleButton(size: 40),
        ],
      ),
    );
  }

  Widget _buildObjectivesBar(GameState state) {
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.config.objectives.length,
        itemBuilder: (_, i) {
          final obj = state.config.objectives[i];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: obj.isComplete ? AppColors.accentGreen.withOpacity(0.15) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: obj.isComplete ? AppColors.accentGreen : AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(obj.isComplete ? '✅' : '🎯', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      obj.description,
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(
                      width: 80,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: obj.progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(obj.isComplete ? AppColors.accentGreen : AppColors.primary),
                        ),
                      ),
                    ),
                    Text(
                      '${obj.current}/${obj.target}',
                      style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomHint(GameState state) {
    if (state.config.hint.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentYellow.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentYellow.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                state.config.hint,
                style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, GameState state) {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⏸', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'Paused',
                  style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${state.config.levelNumber} — ${state.config.title}',
                  style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Music toggle in pause
                const AudioSettingsRow(),

                const SizedBox(height: 20),
                _pauseBtn('▶  Resume', AppColors.primary, Colors.white, () => _togglePause(state)),
                const SizedBox(height: 10),
                _pauseBtn('🔄  Restart Level', Colors.white, AppColors.primary, () {
                  setState(() => _pauseVisible = false);
                  state.restart();
                }, border: AppColors.primary),
                const SizedBox(height: 10),
                _pauseBtn('🏠  Main Menu', Colors.white, Colors.red.shade400, () {
                  setState(() => _pauseVisible = false);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }, border: Colors.red.shade300),
              ],
            ),
          ),
        ).animate().scale(begin: const Offset(0.8, 0.8), duration: 250.ms, curve: Curves.easeOutBack).fadeIn(),
      ),
    );
  }

  Widget _pauseBtn(String label, Color bg, Color fg, VoidCallback onTap, {Color? border}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: bg == Colors.white ? 0 : 4,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border != null ? BorderSide(color: border, width: 1.5) : BorderSide.none,
          ),
        ),
        child: Text(label, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _scoreChip(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFFFF9A3C).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⭐', style: const TextStyle(fontSize: 14)),
          Text('$score', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _movesChip(int moves) {
    final low = moves <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: low ? Colors.red.shade50 : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: low ? Colors.red.shade300 : AppColors.primary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎯', style: const TextStyle(fontSize: 14)),
          Text('$moves', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: low ? Colors.red : AppColors.primary)),
        ],
      ),
    );
  }

  Widget _iconBtn(String icon, {required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
      ),
    );
  }

  void _togglePause(GameState state) {
    setState(() => _pauseVisible = !_pauseVisible);
    if (_pauseVisible) {
      state.pause();
      AudioManager.instance.pauseMusic();
    } else {
      state.resume();
      AudioManager.instance.resumeMusic();
    }
  }

  void _showLevelComplete(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LevelCompleteDialog(state: state),
    );
  }

  void _showGameOver(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GameOverDialog(state: state),
    );
  }
}

// ── Level Complete Dialog ─────────────────────────────────────────────────────

class _LevelCompleteDialog extends StatelessWidget {
  final GameState state;
  const _LevelCompleteDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: const TextStyle(fontSize: 60))
                .animate().scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text('Level Complete!', style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary))
                .animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 16),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  i < state.earnedStars ? '⭐' : '☆',
                  style: TextStyle(fontSize: 40, color: i < state.earnedStars ? Colors.amber : Colors.grey.shade300),
                ).animate(delay: (300 + i * 150).ms).scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 400.ms),
              )),
            ),
            const SizedBox(height: 16),

            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐ Score: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('${state.score}', style: GoogleFonts.fredoka(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Next level
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  final nextIdx = state.config.levelNumber;
                  if (nextIdx < LevelData.levels.length) {
                    state.loadLevel(LevelData.levels[nextIdx]);
                  } else {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Next Level ➜', style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Back to Map', style: GoogleFonts.nunito(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game Over Dialog ──────────────────────────────────────────────────────────

class _GameOverDialog extends StatelessWidget {
  final GameState state;
  const _GameOverDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💀', style: const TextStyle(fontSize: 60))
                .animate().scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text('Out of Moves!', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.red.shade400)),
            const SizedBox(height: 8),
            Text('Score: ${state.score}', style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  state.restart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('🔄  Try Again', style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Back to Map', style: GoogleFonts.nunito(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
