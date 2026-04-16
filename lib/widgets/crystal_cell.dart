import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class CrystalCell extends StatelessWidget {
  final Crystal? crystal;
  final bool isAnimating;
  final bool isNew;
  final double size;

  const CrystalCell({
    super.key,
    required this.crystal,
    this.isAnimating = false,
    this.isNew = false,
    this.size = AppConstants.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    if (crystal == null) {
      return SizedBox(width: size, height: size);
    }

    final c = crystal!;
    Widget cell = _buildCrystalBody(c);

    if (isAnimating) {
      cell = cell
          .animate()
          .scale(begin: const Offset(1, 1), end: const Offset(0, 0), duration: 250.ms, curve: Curves.easeIn)
          .fadeOut(duration: 200.ms);
    } else if (isNew) {
      cell = cell
          .animate()
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 200.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 150.ms);
    } else if (c.isSelected) {
      cell = cell
          .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 400.ms);
    }

    return SizedBox(width: size, height: size, child: cell);
  }

  Widget _buildCrystalBody(Crystal c) {
    // Stone obstacle
    if (c.obstacle == ObstacleType.stone) {
      return _buildStoneCell();
    }

    // Locked tile
    if (c.obstacle == ObstacleType.locked) {
      return _buildLockedCell(c);
    }

    // Ice overlay
    final bool hasIce = c.obstacle == ObstacleType.ice;

    Widget crystal = Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.color.withOpacity(0.9),
            c.color,
            c.color.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: c.color.withOpacity(c.isSelected ? 0.7 : 0.4),
            blurRadius: c.isSelected ? 12 : 6,
            spreadRadius: c.isSelected ? 2 : 0,
          ),
        ],
        border: c.isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Stack(
        children: [
          // Crystal shine
          Positioned(
            top: 4, left: 4,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Crystal shape icon
          Center(
            child: Text(
              _crystalIcon(c.type),
              style: TextStyle(fontSize: size * 0.42),
            ),
          ),
          // Power indicator
          if (c.power != CrystalPower.none)
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  c.powerEmoji,
                  style: TextStyle(fontSize: size * 0.26),
                ),
              ),
            ),
        ],
      ),
    );

    if (hasIce) {
      crystal = Stack(
        children: [
          crystal,
          Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.lightBlue.withOpacity(0.4),
              border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.8), width: 1.5),
            ),
            child: Center(
              child: Text('❄️', style: TextStyle(fontSize: size * 0.3)),
            ),
          ),
        ],
      );
    }

    return crystal;
  }

  Widget _buildStoneCell() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8D8D8D), Color(0xFF555555)],
        ),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Center(
        child: Text('🪨', style: TextStyle(fontSize: size * 0.42)),
      ),
    );
  }

  Widget _buildLockedCell(Crystal c) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: c.color.withOpacity(0.5),
        border: Border.all(color: Colors.amber, width: 1.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              _crystalIcon(c.type),
              style: TextStyle(fontSize: size * 0.32),
            ),
          ),
          const Center(child: Text('🔒', style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _crystalIcon(CrystalType type) {
    switch (type) {
      case CrystalType.red: return '💎';
      case CrystalType.blue: return '🔷';
      case CrystalType.green: return '💚';
      case CrystalType.yellow: return '💛';
      case CrystalType.purple: return '💜';
      case CrystalType.cyan: return '🩵';
      case CrystalType.orange: return '🟠';
    }
  }
}
