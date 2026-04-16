import 'dart:math';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class GameEngine {
  static final Random _rand = Random();

  // ── Board Generation ──────────────────────────────────────────────────────

  static List<List<Crystal?>> generateBoard(LevelConfig config) {
    final int size = config.gridSize;
    List<List<Crystal?>> board = List.generate(
      size, (_) => List.filled(size, null),
    );

    // Place obstacles
    config.obstacles.forEach((type, positions) {
      for (final pos in positions) {
        final r = pos[0], c = pos[1];
        if (r < size && c < size) {
          final ct = _randomType();
          board[r][c] = Crystal(type: ct, obstacle: type);
        }
      }
    });

    // Fill rest with non-matching crystals
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == null) {
          CrystalType type;
          int tries = 0;
          do {
            type = _randomType();
            tries++;
          } while (tries < 20 && _wouldMatch(board, r, c, type));
          board[r][c] = Crystal(type: type);
        }
      }
    }

    return board;
  }

  static bool _wouldMatch(List<List<Crystal?>> board, int r, int c, CrystalType type) {
    // Check horizontal
    if (c >= 2 &&
        board[r][c - 1]?.type == type &&
        board[r][c - 2]?.type == type) return true;
    // Check vertical
    if (r >= 2 &&
        board[r - 1][c]?.type == type &&
        board[r - 2][c]?.type == type) return true;
    return false;
  }

  static CrystalType _randomType() {
    return CrystalType.values[_rand.nextInt(AppConstants.numCrystalTypes)];
  }

  // ── Swap & Validation ─────────────────────────────────────────────────────

  static bool isAdjacentSwap(int r1, int c1, int r2, int c2) {
    return (r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1);
  }

  static List<List<Crystal?>> swapCrystals(
      List<List<Crystal?>> board, int r1, int c1, int r2, int c2) {
    final newBoard = _copyBoard(board);
    final temp = newBoard[r1][c1];
    newBoard[r1][c1] = newBoard[r2][c2];
    newBoard[r2][c2] = temp;
    return newBoard;
  }

  static bool hasMatchAfterSwap(
      List<List<Crystal?>> board, int r1, int c1, int r2, int c2) {
    final swapped = swapCrystals(board, r1, c1, r2, c2);
    return findAllMatches(swapped).isNotEmpty;
  }

  // ── Match Finding ─────────────────────────────────────────────────────────

  static List<MatchGroup> findAllMatches(List<List<Crystal?>> board) {
    final int size = board.length;
    final Set<String> visited = {};
    final List<MatchGroup> groups = [];

    // Horizontal matches
    for (int r = 0; r < size; r++) {
      int c = 0;
      while (c < size) {
        final crystal = board[r][c];
        if (crystal == null || crystal.obstacle == ObstacleType.stone ||
            crystal.obstacle == ObstacleType.locked) {
          c++;
          continue;
        }
        int len = 1;
        while (c + len < size &&
            board[r][c + len]?.type == crystal.type &&
            board[r][c + len]?.obstacle != ObstacleType.stone &&
            board[r][c + len]?.obstacle != ObstacleType.locked) {
          len++;
        }
        if (len >= 3) {
          final cells = <List<int>>[];
          for (int i = 0; i < len; i++) {
            cells.add([r, c + i]);
          }
          groups.add(MatchGroup(cells: cells, type: crystal.type, length: len));
          for (final cell in cells) visited.add('${cell[0]},${cell[1]}');
        }
        c += len;
      }
    }

    // Vertical matches
    for (int c = 0; c < size; c++) {
      int r = 0;
      while (r < size) {
        final crystal = board[r][c];
        if (crystal == null || crystal.obstacle == ObstacleType.stone ||
            crystal.obstacle == ObstacleType.locked) {
          r++;
          continue;
        }
        int len = 1;
        while (r + len < size &&
            board[r + len][c]?.type == crystal.type &&
            board[r + len][c]?.obstacle != ObstacleType.stone &&
            board[r + len][c]?.obstacle != ObstacleType.locked) {
          len++;
        }
        if (len >= 3) {
          final cells = <List<int>>[];
          for (int i = 0; i < len; i++) {
            if (!visited.contains('${r + i},$c')) {
              cells.add([r + i, c]);
            }
          }
          if (cells.length >= 3) {
            groups.add(MatchGroup(cells: cells, type: crystal.type, length: len));
          }
        }
        r += len;
      }
    }

    return groups;
  }

  // ── Power Crystal Assignment ──────────────────────────────────────────────

  static CrystalPower powerForMatch(int length) {
    if (length >= 5) return CrystalPower.lightning;
    if (length == 4) return CrystalPower.bomb;
    return CrystalPower.none;
  }

  // ── Apply Matches ─────────────────────────────────────────────────────────

  static MatchResult applyMatches(
    List<List<Crystal?>> board,
    List<MatchGroup> matches,
    List<LevelObjective> objectives,
  ) {
    final newBoard = _copyBoard(board);
    int score = 0;
    int obstaclesBreak = 0;
    Map<CrystalType, int> collected = {};
    List<PowerSpawn> powerSpawns = [];

    final Set<String> allMatchedCells = {};
    for (final m in matches) {
      for (final c in m.cells) allMatchedCells.add('${c[0]},${c[1]}');
    }

    for (final match in matches) {
      score += _scoreForMatch(match.length);
      final power = powerForMatch(match.length);

      // Check adjacency for ice breaking
      for (final cell in match.cells) {
        final cr = cell[0], cc = cell[1];
        _checkAdjacentIce(newBoard, cr, cc, (r, c) => obstaclesBreak++);
      }

      // Collect and clear cells
      Crystal? spawned;
      for (int i = 0; i < match.cells.length; i++) {
        final cr = match.cells[i][0], cc = match.cells[i][1];
        final crystal = newBoard[cr][cc];
        if (crystal == null) continue;
        collected[crystal.type] = (collected[crystal.type] ?? 0) + 1;

        if (power != CrystalPower.none && i == match.cells.length ~/ 2) {
          spawned = Crystal(type: match.type, power: power);
          newBoard[cr][cc] = spawned;
          powerSpawns.add(PowerSpawn(row: cr, col: cc, power: power));
        } else {
          newBoard[cr][cc] = null;
        }
      }
    }

    // Update objectives
    for (final obj in objectives) {
      if (!obj.isComplete) {
        switch (obj.type) {
          case ObjectiveType.score:
            obj.current += score;
            break;
          case ObjectiveType.collectColor:
            if (obj.targetCrystal != null) {
              obj.current += collected[obj.targetCrystal] ?? 0;
            }
            break;
          case ObjectiveType.breakObstacles:
            obj.current += obstaclesBreak;
            break;
          case ObjectiveType.collectAny:
            obj.current += collected.values.fold(0, (a, b) => a + b);
            break;
        }
      }
    }

    return MatchResult(
      board: newBoard,
      score: score,
      obstaclesBroken: obstaclesBreak,
      collected: collected,
      powerSpawns: powerSpawns,
    );
  }

  static void _checkAdjacentIce(
    List<List<Crystal?>> board, int r, int c,
    void Function(int, int) onBreak,
  ) {
    final dirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (final d in dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (nr >= 0 && nr < board.length && nc >= 0 && nc < board[0].length) {
        final adj = board[nr][nc];
        if (adj != null && adj.obstacle == ObstacleType.ice) {
          adj.iceHits--;
          if (adj.iceHits <= 0) {
            adj.obstacle = ObstacleType.none;
            onBreak(nr, nc);
          }
        }
      }
    }
  }

  // ── Power Crystal Activation ──────────────────────────────────────────────

  static PowerActivationResult activatePower(
    List<List<Crystal?>> board,
    int r, int c,
    CrystalPower power,
  ) {
    final newBoard = _copyBoard(board);
    int score = 0;
    final Set<String> cleared = {};
    final crystal = newBoard[r][c];
    if (crystal == null) return PowerActivationResult(board: newBoard, score: 0);

    switch (power) {
      case CrystalPower.fire:
        // Clear entire row
        for (int cc = 0; cc < newBoard[r].length; cc++) {
          if (newBoard[r][cc]?.obstacle != ObstacleType.stone) {
            newBoard[r][cc] = null;
            cleared.add('$r,$cc');
            score += 50;
          }
        }
        break;
      case CrystalPower.bomb:
        // 3x3 explosion
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = r + dr, nc = c + dc;
            if (nr >= 0 && nr < newBoard.length &&
                nc >= 0 && nc < newBoard[0].length &&
                newBoard[nr][nc]?.obstacle != ObstacleType.stone) {
              newBoard[nr][nc] = null;
              cleared.add('$nr,$nc');
              score += 60;
            }
          }
        }
        break;
      case CrystalPower.lightning:
        // Clear all same color
        final t = crystal.type;
        for (int rr = 0; rr < newBoard.length; rr++) {
          for (int cc = 0; cc < newBoard[rr].length; cc++) {
            if (newBoard[rr][cc]?.type == t &&
                newBoard[rr][cc]?.obstacle != ObstacleType.stone) {
              newBoard[rr][cc] = null;
              cleared.add('$rr,$cc');
              score += 70;
            }
          }
        }
        break;
      case CrystalPower.none:
        break;
    }
    newBoard[r][c] = null;

    return PowerActivationResult(board: newBoard, score: score, clearedCells: cleared);
  }

  // ── Gravity / Fill ────────────────────────────────────────────────────────

  static List<List<Crystal?>> applyGravity(List<List<Crystal?>> board) {
    final int rows = board.length, cols = board[0].length;
    final newBoard = _copyBoard(board);

    for (int c = 0; c < cols; c++) {
      // Collect non-null crystals from bottom to top
      List<Crystal> column = [];
      for (int r = rows - 1; r >= 0; r--) {
        if (newBoard[r][c] != null) {
          column.add(newBoard[r][c]!);
          newBoard[r][c] = null;
        }
      }
      // Place back from bottom
      for (int i = 0; i < column.length; i++) {
        newBoard[rows - 1 - i][c] = column[i];
      }
    }

    return newBoard;
  }

  static List<List<Crystal?>> fillEmpty(List<List<Crystal?>> board) {
    final newBoard = _copyBoard(board);
    for (int r = 0; r < newBoard.length; r++) {
      for (int c = 0; c < newBoard[r].length; c++) {
        if (newBoard[r][c] == null) {
          newBoard[r][c] = Crystal(type: _randomType(), isNew: true);
        }
      }
    }
    return newBoard;
  }

  // ── Score Calculation ─────────────────────────────────────────────────────

  static int _scoreForMatch(int length) {
    switch (length) {
      case 3: return 60;
      case 4: return 120;
      case 5: return 200;
      default: return 60 + (length - 3) * 40;
    }
  }

  // ── Board Utilities ───────────────────────────────────────────────────────

  static List<List<Crystal?>> _copyBoard(List<List<Crystal?>> board) {
    return board.map((row) => row.map((c) {
      if (c == null) return null;
      return c.copyWith();
    }).toList()).toList();
  }

  static bool hasPossibleMoves(List<List<Crystal?>> board) {
    final size = board.length;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (c + 1 < size && hasMatchAfterSwap(board, r, c, r, c + 1)) return true;
        if (r + 1 < size && hasMatchAfterSwap(board, r, c, r + 1, c)) return true;
      }
    }
    return false;
  }

  static List<List<Crystal?>> shuffle(List<List<Crystal?>> board) {
    final size = board.length;
    final allCrystals = <Crystal>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] != null &&
            board[r][c]!.obstacle == ObstacleType.none) {
          allCrystals.add(board[r][c]!);
        }
      }
    }
    allCrystals.shuffle(_rand);
    final newBoard = _copyBoard(board);
    int idx = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (newBoard[r][c] != null &&
            newBoard[r][c]!.obstacle == ObstacleType.none) {
          newBoard[r][c] = allCrystals[idx++];
        }
      }
    }
    return newBoard;
  }
}

// ── Data Classes ──────────────────────────────────────────────────────────────

class MatchGroup {
  final List<List<int>> cells;
  final CrystalType type;
  final int length;
  const MatchGroup({required this.cells, required this.type, required this.length});
}

class MatchResult {
  final List<List<Crystal?>> board;
  final int score;
  final int obstaclesBroken;
  final Map<CrystalType, int> collected;
  final List<PowerSpawn> powerSpawns;
  const MatchResult({
    required this.board,
    required this.score,
    required this.obstaclesBroken,
    required this.collected,
    required this.powerSpawns,
  });
}

class PowerSpawn {
  final int row, col;
  final CrystalPower power;
  const PowerSpawn({required this.row, required this.col, required this.power});
}

class PowerActivationResult {
  final List<List<Crystal?>> board;
  final int score;
  final Set<String> clearedCells;
  const PowerActivationResult({
    required this.board,
    required this.score,
    this.clearedCells = const {},
  });
}
