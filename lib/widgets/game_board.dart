import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../utils/app_theme.dart';
import 'crystal_cell.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Track where a drag started (row, col)
  int? _dragStartRow;
  int? _dragStartCol;
  bool _dragHandled = false;

  void _onPanStart(DragStartDetails details, GameState state, double cellSize, int size) {
    final localPos = details.localPosition;
    final col = (localPos.dx / cellSize).floor();
    final row = (localPos.dy / cellSize).floor();
    if (row >= 0 && row < size && col >= 0 && col < size) {
      _dragStartRow = row;
      _dragStartCol = col;
      _dragHandled = false;
      // Select the cell on drag start
      state.onCellTap(row, col);
    }
  }

  void _onPanEnd(DragEndDetails details, GameState state, double cellSize, int size) {
    _dragStartRow = null;
    _dragStartCol = null;
    _dragHandled = false;
  }

  void _onPanUpdate(DragUpdateDetails details, GameState state, double cellSize, int size) {
    if (_dragHandled || _dragStartRow == null || _dragStartCol == null) return;

    final dx = details.delta.dx;
    final dy = details.delta.dy;
    final threshold = cellSize * 0.3;

    int? targetRow;
    int? targetCol;

    if (dx.abs() > threshold && dx.abs() > dy.abs()) {
      targetRow = _dragStartRow!;
      targetCol = _dragStartCol! + (dx > 0 ? 1 : -1);
    } else if (dy.abs() > threshold && dy.abs() > dx.abs()) {
      targetRow = _dragStartRow! + (dy > 0 ? 1 : -1);
      targetCol = _dragStartCol!;
    }

    if (targetRow != null && targetCol != null &&
        targetRow >= 0 && targetRow < size &&
        targetCol >= 0 && targetCol < size) {
      _dragHandled = true;
      state.onCellTap(targetRow, targetCol);
    }
  }

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
      child: GestureDetector(
        onPanStart: (d) => _onPanStart(d, state, cellSize, size),
        onPanUpdate: (d) => _onPanUpdate(d, state, cellSize, size),
        onPanEnd: (d) => _onPanEnd(d, state, cellSize, size),
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
      ),
    );
  }
}