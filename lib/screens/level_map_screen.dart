import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../widgets/music_toggle_button.dart';
import 'gameplay_screen.dart';

class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..loadPrefs(),
      child: const _LevelMapBody(),
    );
  }
}

class _LevelMapBody extends StatelessWidget {
  const _LevelMapBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final levels = LevelData.levels;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0FF), Color(0xFFEDE0FF), Color(0xFFF5F0FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text('Level Map', style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                    const MusicToggleButton(size: 42),
                  ],
                ),
              ),

              // Level grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, i) {
                    final level = levels[i];
                    final unlocked = level.levelNumber <= state.unlockedLevels;
                    final stars = state.levelStars[level.levelNumber] ?? 0;
                    final best = state.bestScores[level.levelNumber] ?? 0;

                    return _LevelCard(
                      level: level,
                      unlocked: unlocked,
                      stars: stars,
                      bestScore: best,
                      delay: i * 50,
                      onTap: unlocked
                          ? () {
                        state.loadLevel(level);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: state, child: const GameplayScreen())));
                      }
                          : null,
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

class _LevelCard extends StatelessWidget {
  final LevelConfig level;
  final bool unlocked;
  final int stars;
  final int bestScore;
  final int delay;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.bestScore,
    required this.delay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          boxShadow: unlocked
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.18), blurRadius: 14, offset: const Offset(0, 5))]
              : [],
          border: Border.all(
            color: unlocked ? AppColors.primary.withOpacity(0.25) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Star row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Text(
                i < stars ? '⭐' : '☆',
                style: TextStyle(fontSize: 13, color: i < stars ? Colors.amber : Colors.grey.shade400),
              )),
            ),
            const SizedBox(height: 4),

            // Lock / number
            unlocked
                ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9B6EF3), Color(0xFF6C3FC5)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Text(
                  '${level.levelNumber}',
                  style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            )
                : const Text('🔒', style: TextStyle(fontSize: 32)),

            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                level.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? AppColors.textPrimary : Colors.grey,
                ),
              ),
            ),
            if (unlocked && bestScore > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Best: $bestScore',
                style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ).animate(delay: delay.ms).scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOut).fadeIn(),
    );
  }
}