import 'package:flutter/material.dart';

// UI එකට අවශ්‍ය Colors
class AppColors {
  static const Color bg = Color(0xFF0F172A);
  static const Color bgElevated = Color(0xFF1E293B);
  static const Color card = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF334155);
  static const Color text = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);
  static const Color primary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF97316);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color inputBg = Color(0xFF0F172A);
  static const Color inputBorder = Color(0xFF334155);
}

// Data Models
class Reading {
  final String id;
  final String poleId;
  final int intensity;
  final String status;
  final double voltage;
  final double power;
  final double temperature;
  final int timestamp;

  Reading({
    required this.id,
    required this.poleId,
    required this.intensity,
    required this.status,
    required this.voltage,
    required this.power,
    required this.temperature,
    required this.timestamp,
  });
}

class Condition {
  final String label;
  final Color color;
  Condition(this.label, this.color);
}

Condition conditionFor(int intensity) {
  if (intensity > 70) return Condition('High', AppColors.success);
  if (intensity > 30) return Condition('Normal', AppColors.primary);
  return Condition('Low', AppColors.warning);
}

// Custom Street Light Icon Placeholder
class StreetLightIcon extends StatelessWidget {
  final double size;
  final bool on;
  final Color color;

  const StreetLightIcon({super.key, required this.size, this.on = false, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Icon(
      on ? Icons.lightbulb : Icons.lightbulb_outline,
      size: size,
      color: on ? color : AppColors.textDim,
    );
  }
}