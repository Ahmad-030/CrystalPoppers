import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum CrystalType { red, blue, green, yellow, purple, cyan, orange }
enum CrystalPower { none, fire, bomb, lightning }
enum ObstacleType { none, ice, locked, stone }

class Crystal {
  CrystalType type;
  CrystalPower power;
  ObstacleType obstacle;
  int iceHits; // for ice: how many hits left
  bool isSelected;
  bool isMatched;
  bool isNew;

  Crystal({
    required this.type,
    this.power = CrystalPower.none,
    this.obstacle = ObstacleType.none,
    this.iceHits = 2,
    this.isSelected = false,
    this.isMatched = false,
    this.isNew = false,
  });

  Crystal copyWith({
    CrystalType? type,
    CrystalPower? power,
    ObstacleType? obstacle,
    int? iceHits,
    bool? isSelected,
    bool? isMatched,
    bool? isNew,
  }) {
    return Crystal(
      type: type ?? this.type,
      power: power ?? this.power,
      obstacle: obstacle ?? this.obstacle,
      iceHits: iceHits ?? this.iceHits,
      isSelected: isSelected ?? this.isSelected,
      isMatched: isMatched ?? this.isMatched,
      isNew: isNew ?? this.isNew,
    );
  }

  Color get color {
    switch (type) {
      case CrystalType.red: return AppColors.crystalRed;
      case CrystalType.blue: return AppColors.crystalBlue;
      case CrystalType.green: return AppColors.crystalGreen;
      case CrystalType.yellow: return AppColors.crystalYellow;
      case CrystalType.purple: return AppColors.crystalPurple;
      case CrystalType.cyan: return AppColors.crystalCyan;
      case CrystalType.orange: return AppColors.crystalOrange;
    }
  }

  Color get lightColor => color.withOpacity(0.3);

  String get emoji {
    switch (type) {
      case CrystalType.red: return '🔴';
      case CrystalType.blue: return '🔵';
      case CrystalType.green: return '🟢';
      case CrystalType.yellow: return '🟡';
      case CrystalType.purple: return '🟣';
      case CrystalType.cyan: return '💠';
      case CrystalType.orange: return '🟠';
    }
  }

  String get powerEmoji {
    switch (power) {
      case CrystalPower.fire: return '🔥';
      case CrystalPower.bomb: return '💣';
      case CrystalPower.lightning: return '⚡';
      case CrystalPower.none: return '';
    }
  }
}

class LevelObjective {
  final String description;
  final int target;
  int current;
  final ObjectiveType type;
  final CrystalType? targetCrystal;

  LevelObjective({
    required this.description,
    required this.target,
    required this.type,
    this.targetCrystal,
    this.current = 0,
  });

  bool get isComplete => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);
}

enum ObjectiveType { score, collectColor, breakObstacles, collectAny }

class LevelConfig {
  final int levelNumber;
  final int movesAllowed;
  final int gridSize;
  final List<LevelObjective> objectives;
  final Map<ObstacleType, List<List<int>>> obstacles;
  final int starThreshold1;
  final int starThreshold2;
  final int starThreshold3;
  final String title;
  final String hint;

  const LevelConfig({
    required this.levelNumber,
    required this.movesAllowed,
    this.gridSize = 8,
    required this.objectives,
    this.obstacles = const {},
    required this.starThreshold1,
    required this.starThreshold2,
    required this.starThreshold3,
    required this.title,
    this.hint = '',
  });
}

class LevelData {
  static List<LevelConfig> get levels => [
    LevelConfig(
      levelNumber: 1,
      movesAllowed: 25,
      title: 'Crystal Beginner',
      hint: 'Match 3 crystals to pop them!',
      objectives: [
        LevelObjective(description: 'Score 500', target: 500, type: ObjectiveType.score),
      ],
      obstacles: {},
      starThreshold1: 300, starThreshold2: 500, starThreshold3: 800,
    ),
    LevelConfig(
      levelNumber: 2,
      movesAllowed: 22,
      title: 'Color Collector',
      hint: 'Collect red crystals!',
      objectives: [
        LevelObjective(description: 'Collect 15 Red', target: 15, type: ObjectiveType.collectColor, targetCrystal: CrystalType.red),
        LevelObjective(description: 'Score 800', target: 800, type: ObjectiveType.score),
      ],
      starThreshold1: 500, starThreshold2: 800, starThreshold3: 1200,
    ),
    LevelConfig(
      levelNumber: 3,
      movesAllowed: 20,
      title: 'Ice Breaker',
      hint: 'Break the ice blocks by matching nearby crystals!',
      objectives: [
        LevelObjective(description: 'Break 8 Ice', target: 8, type: ObjectiveType.breakObstacles),
        LevelObjective(description: 'Score 1000', target: 1000, type: ObjectiveType.score),
      ],
      obstacles: {
        ObstacleType.ice: [[2,2],[2,3],[3,2],[3,3],[4,4],[4,5],[5,4],[5,5]],
      },
      starThreshold1: 700, starThreshold2: 1000, starThreshold3: 1500,
    ),
    LevelConfig(
      levelNumber: 4,
      movesAllowed: 18,
      title: 'Power Surge',
      hint: 'Create power crystals with 4-5 matches!',
      objectives: [
        LevelObjective(description: 'Collect 20 Blue', target: 20, type: ObjectiveType.collectColor, targetCrystal: CrystalType.blue),
        LevelObjective(description: 'Score 1500', target: 1500, type: ObjectiveType.score),
      ],
      starThreshold1: 1000, starThreshold2: 1500, starThreshold3: 2500,
    ),
    LevelConfig(
      levelNumber: 5,
      movesAllowed: 20,
      title: 'Crystal Storm',
      hint: 'Use bombs and lightning wisely!',
      objectives: [
        LevelObjective(description: 'Score 2000', target: 2000, type: ObjectiveType.score),
        LevelObjective(description: 'Collect 30 Any', target: 30, type: ObjectiveType.collectAny),
      ],
      obstacles: {
        ObstacleType.stone: [[0,3],[0,4],[7,3],[7,4],[3,0],[4,0],[3,7],[4,7]],
      },
      starThreshold1: 1200, starThreshold2: 2000, starThreshold3: 3000,
    ),
    // Levels 6-15
    LevelConfig(
      levelNumber: 6,
      movesAllowed: 22,
      title: 'Rainbow Rush',
      hint: 'Match all colors for bonus!',
      objectives: [
        LevelObjective(description: 'Score 2500', target: 2500, type: ObjectiveType.score),
      ],
      starThreshold1: 1500, starThreshold2: 2500, starThreshold3: 4000,
    ),
    LevelConfig(
      levelNumber: 7,
      movesAllowed: 18,
      title: 'Frozen World',
      hint: 'Break all ice to win!',
      objectives: [
        LevelObjective(description: 'Break 12 Ice', target: 12, type: ObjectiveType.breakObstacles),
        LevelObjective(description: 'Score 2000', target: 2000, type: ObjectiveType.score),
      ],
      obstacles: {
        ObstacleType.ice: [[1,1],[1,2],[1,3],[2,1],[2,2],[3,3],[4,4],[5,5],[5,6],[6,5],[6,6],[7,7]],
      },
      starThreshold1: 1500, starThreshold2: 2000, starThreshold3: 3500,
    ),
    LevelConfig(
      levelNumber: 8,
      movesAllowed: 15,
      title: 'Bomb Squad',
      hint: 'Create bombs by matching 4!',
      objectives: [
        LevelObjective(description: 'Score 3000', target: 3000, type: ObjectiveType.score),
        LevelObjective(description: 'Collect 25 Green', target: 25, type: ObjectiveType.collectColor, targetCrystal: CrystalType.green),
      ],
      starThreshold1: 2000, starThreshold2: 3000, starThreshold3: 5000,
    ),
    LevelConfig(
      levelNumber: 9,
      movesAllowed: 20,
      title: 'Crystal Maze',
      hint: 'Navigate around the barriers!',
      objectives: [
        LevelObjective(description: 'Score 3500', target: 3500, type: ObjectiveType.score),
        LevelObjective(description: 'Collect 40 Any', target: 40, type: ObjectiveType.collectAny),
      ],
      obstacles: {
        ObstacleType.locked: [[2,2],[2,5],[5,2],[5,5]],
        ObstacleType.stone: [[0,0],[0,7],[7,0],[7,7],[3,3],[3,4],[4,3],[4,4]],
      },
      starThreshold1: 2500, starThreshold2: 3500, starThreshold3: 6000,
    ),
    LevelConfig(
      levelNumber: 10,
      movesAllowed: 25,
      title: 'Grand Finale I',
      hint: 'Master all mechanics!',
      objectives: [
        LevelObjective(description: 'Score 5000', target: 5000, type: ObjectiveType.score),
        LevelObjective(description: 'Break 10 Ice', target: 10, type: ObjectiveType.breakObstacles),
      ],
      obstacles: {
        ObstacleType.ice: [[1,0],[1,7],[6,0],[6,7],[0,1],[0,6],[7,1],[7,6],[3,3],[4,4]],
      },
      starThreshold1: 3000, starThreshold2: 5000, starThreshold3: 8000,
    ),
  ];
}
