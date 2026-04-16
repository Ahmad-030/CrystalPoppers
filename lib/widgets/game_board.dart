import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../utils/app_theme.dart';
import 'crystal_cell.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final double boardSize = MediaQuery.of(context).size.width - 16;
    final int size = state.config.gridSize;
    final double cellSize = (boardSize - (size + 1) * AppConstants.cellSpacing) / size;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: List.generate(size, (r) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(size, (c) {
            final key = '$r,$c';
            final crystal = state.board.isNotEmpty ? state.board[r][c] : null;
            final isAnimating = state.animatingCells.contains(key);
            final isNew = state.newCells.contains(key);

            return GestureDetector(
              onTap: () => state.onCellTap(r, c),
              child: CrystalCell(
                crystal: crystal,
                isAnimating: isAnimating,
                isNew: isNew,
                size: cellSize,
              ),
            );
          }),
        )),
      ),
    );
  }
}
