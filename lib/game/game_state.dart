import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import 'game_engine.dart';

enum GamePhase { idle, swapping, matching, falling, filling, checkComplete, paused }

class GameState extends ChangeNotifier {
  // ── Board & Level ─────────────────────────────────────────────────────────
  List<List<Crystal?>> board = [];
  late LevelConfig config;
  int movesLeft = 0;
  int score = 0;
  int comboMultiplier = 1;
  int comboCount = 0;
  GamePhase phase = GamePhase.idle;
  bool isProcessing = false;

  // ── Selection ─────────────────────────────────────────────────────────────
  int? selectedRow, selectedCol;

  // ── UI State ──────────────────────────────────────────────────────────────
  Set<String> animatingCells = {};
  Set<String> newCells = {};
  String? lastPowerEffect;
  bool showComboText = false;
  String comboText = '';

  // ── Level Progress ────────────────────────────────────────────────────────
  bool levelComplete = false;
  bool gameOver = false;
  int earnedStars = 0;

  // ── Prefs ─────────────────────────────────────────────────────────────────
  int unlockedLevels = 1;
  Map<int, int> levelStars = {};
  Map<int, int> bestScores = {};

  void loadLevel(LevelConfig cfg) {
    config = cfg;
    movesLeft = cfg.movesAllowed;
    score = 0;
    comboMultiplier = 1;
    comboCount = 0;
    selectedRow = null;
    selectedCol = null;
    levelComplete = false;
    gameOver = false;
    earnedStars = 0;
    phase = GamePhase.idle;
    isProcessing = false;
    // Re-init objectives
    board = GameEngine.generateBoard(cfg);
    notifyListeners();
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    unlockedLevels = prefs.getInt('unlockedLevels') ?? 1;
    final starsRaw = prefs.getStringList('levelStars') ?? [];
    final scoresRaw = prefs.getStringList('bestScores') ?? [];
    for (final s in starsRaw) {
      final parts = s.split(':');
      if (parts.length == 2) levelStars[int.parse(parts[0])] = int.parse(parts[1]);
    }
    for (final s in scoresRaw) {
      final parts = s.split(':');
      if (parts.length == 2) bestScores[int.parse(parts[0])] = int.parse(parts[1]);
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevels', unlockedLevels);
    await prefs.setStringList('levelStars',
        levelStars.entries.map((e) => '${e.key}:${e.value}').toList());
    await prefs.setStringList('bestScores',
        bestScores.entries.map((e) => '${e.key}:${e.value}').toList());
  }

  // ── Tap/Swap Logic ────────────────────────────────────────────────────────

  void onCellTap(int r, int c) {
    if (isProcessing || levelComplete || gameOver) return;
    final crystal = board[r][c];
    if (crystal == null) return;

    // Locked tiles can't be selected
    if (crystal.obstacle == ObstacleType.locked || crystal.obstacle == ObstacleType.stone) return;

    // If a power crystal tapped directly — activate it
    if (selectedRow == null && crystal.power != CrystalPower.none) {
      _activatePower(r, c, crystal.power);
      return;
    }

    if (selectedRow == null) {
      selectedRow = r; selectedCol = c;
      board[r][c] = crystal.copyWith(isSelected: true);
      notifyListeners();
      return;
    }

    // Deselect if same
    if (selectedRow == r && selectedCol == c) {
      board[r][c] = crystal.copyWith(isSelected: false);
      selectedRow = null; selectedCol = null;
      notifyListeners();
      return;
    }

    // Adjacent swap
    final sr = selectedRow!, sc = selectedCol!;
    board[sr][sc] = board[sr][sc]?.copyWith(isSelected: false);
    selectedRow = null; selectedCol = null;

    if (GameEngine.isAdjacentSwap(sr, sc, r, c)) {
      if (GameEngine.hasMatchAfterSwap(board, sr, sc, r, c)) {
        _doSwap(sr, sc, r, c);
      } else {
        // Invalid swap — no matches
        notifyListeners();
      }
    } else {
      // Re-select new cell
      selectedRow = r; selectedCol = c;
      board[r][c] = crystal.copyWith(isSelected: true);
      notifyListeners();
    }
  }

  void _doSwap(int r1, int c1, int r2, int c2) async {
    if (isProcessing) return;
    isProcessing = true;
    movesLeft--;
    phase = GamePhase.swapping;
    notifyListeners();

    board = GameEngine.swapCrystals(board, r1, c1, r2, c2);
    await Future.delayed(AppConstants.swapDuration);

    await _processMatches();
  }

  Future<void> _processMatches() async {
    phase = GamePhase.matching;
    int cascadeCount = 0;

    while (true) {
      final matches = GameEngine.findAllMatches(board);
      if (matches.isEmpty) break;

      cascadeCount++;
      comboCount = cascadeCount;

      // Flash matched cells
      animatingCells = {
        for (final m in matches) for (final c in m.cells) '${c[0]},${c[1]}'
      };
      notifyListeners();
      await Future.delayed(AppConstants.popDuration);
      animatingCells = {};

      // Apply matches
      final objectives = List<LevelObjective>.from(
        config.objectives.map((o) => o),
      );
      final result = GameEngine.applyMatches(board, matches, config.objectives);
      board = result.board;
      score += result.score * cascadeCount;

      if (cascadeCount > 1) {
        comboText = 'COMBO x$cascadeCount!';
        showComboText = true;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 400));
        showComboText = false;
      }

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 100));

      // Gravity
      phase = GamePhase.falling;
      board = GameEngine.applyGravity(board);
      notifyListeners();
      await Future.delayed(AppConstants.fallDuration);

      // Fill
      phase = GamePhase.filling;
      board = GameEngine.fillEmpty(board);
      newCells = {};
      for (int r = 0; r < board.length; r++) {
        for (int c = 0; c < board[r].length; c++) {
          if (board[r][c]?.isNew == true) {
            newCells.add('$r,$c');
            board[r][c] = board[r][c]!.copyWith(isNew: false);
          }
        }
      }
      notifyListeners();
      await Future.delayed(AppConstants.fallDuration);
      newCells = {};
    }

    // Check shuffle if no moves
    if (!GameEngine.hasPossibleMoves(board)) {
      board = GameEngine.shuffle(board);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _checkWinLoss();
    isProcessing = false;
    phase = GamePhase.idle;
    notifyListeners();
  }

  void _activatePower(int r, int c, CrystalPower power) async {
    if (isProcessing) return;
    isProcessing = true;
    movesLeft--;

    final result = GameEngine.activatePower(board, r, c, power);
    board = result.board;
    score += result.score;
    lastPowerEffect = power.name;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    lastPowerEffect = null;

    board = GameEngine.applyGravity(board);
    notifyListeners();
    await Future.delayed(AppConstants.fallDuration);

    board = GameEngine.fillEmpty(board);
    notifyListeners();
    await Future.delayed(AppConstants.fallDuration);

    await _processMatches();
  }

  void _checkWinLoss() {
    final allDone = config.objectives.every((o) => o.isComplete);
    if (allDone) {
      levelComplete = true;
      earnedStars = _calcStars();
      _onLevelComplete();
    } else if (movesLeft <= 0) {
      gameOver = true;
    }
    notifyListeners();
  }

  int _calcStars() {
    if (score >= config.starThreshold3) return 3;
    if (score >= config.starThreshold2) return 2;
    if (score >= config.starThreshold1) return 1;
    return 0;
  }

  void _onLevelComplete() {
    final lvl = config.levelNumber;
    // Update stars
    if ((levelStars[lvl] ?? 0) < earnedStars) levelStars[lvl] = earnedStars;
    // Update best score
    if ((bestScores[lvl] ?? 0) < score) bestScores[lvl] = score;
    // Unlock next
    final next = lvl + 1;
    if (next <= LevelData.levels.length && next > unlockedLevels) {
      unlockedLevels = next;
    }
    _savePrefs();
  }

  void pause() { phase = GamePhase.paused; notifyListeners(); }
  void resume() { phase = GamePhase.idle; notifyListeners(); }

  void restart() => loadLevel(config);
}
