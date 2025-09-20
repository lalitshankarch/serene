import 'package:flutter/material.dart';

/// Centralized color scheme for the app
/// Edit these colors to change the app's appearance globally
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(
    0xFF74b1ff,
  ); // Indigo-500 - Modern, trustworthy

  // Background Colors
  static const Color background = Color(
    0xFFFAFAFA,
  ); // Neutral-50 - Clean background
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // Slate-900 - High contrast
  static const Color textSecondary = Color(
    0xFF475569,
  ); // Slate-600 - Medium contrast
  static const Color textTertiary = Color(
    0xFF94A3B8,
  ); // Slate-400 - Low emphasis

  // Accent Colors
  static const Color accentGrey = Color(
    0xFF6B7280,
  ); // Gray-500 - Professional neutral
  static const Color accentBlue = Color(
    0xFF9bc7ff,
  ); // Gray-500 - Professional neutral
  static const Color accentBlue2 = Color(
    0xFFe6f1ff,
  ); // Gray-500 - Professional neutral

  // UI Element Colors
  static const Color shadowColor = Color(
    0x0F000000,
  ); // 6% opacity - Subtle shadows
  static const Color dividerColor = Color(
    0xFFE2E8F0,
  ); // Slate-200 - Subtle dividers
  static const Color borderColor = Color(
    0xFFCBD5E1,
  ); // Slate-300 - Clean borders

  // Status Colors
  static const Color success = Color(
    0xFF10B981,
  ); // Emerald-500 - Fresh, positive
  static const Color warning = Color(
    0xFFF59E0B,
  ); // Amber-500 - Attention-grabbing
  static const Color error = Color(
    0xFFEF4444,
  ); // Red-500 - Clear error indication
  static const Color info = Color(0xFF3B82F6); // Blue-500 - Informational

  // Navigation Colors
  static const Color navSelected = primaryBlue;
  static const Color navUnselected = Color(
    0xFF94A3B8,
  ); // Slate-400 - Subtle unselected

  // Category Colors (for usage stats) - Harmonious palette with consistent saturation
  static const Map<String, Color> categoryColors = {
    'Social': Color(0xFFEC4899), // Pink-500 - Social, warm
    'Productivity': Color(0xFF8B5CF6), // Violet-500 - Focus, productivity
    'Finance': Color(0xFF10B981), // Emerald-500 - Growth, money
    'Entertainment': Color(0xFFF59E0B), // Amber-500 - Fun, entertainment
    'Shopping': Color(0xFFEF4444), // Red-500 - Urgent, shopping
    'Internet': Color(0xFF3B82F6), // Blue-500 - Digital, web
    'Utility': Color(0xFF6B7280), // Gray-500 - Neutral, utility
    'Communication': Color(0xFF06B6D4), // Cyan-500 - Communication, clear
    'News': Color(0xFF8B5CF6), // Violet-500 - Information, news
    'Games': Color(0xFF84CC16), // Lime-500 - Playful, games
    'Education': Color(0xFF6366F1), // Indigo-500 - Learning, knowledge
    'Health': Color(0xFF10B981), // Emerald-500 - Health, wellness
    'Travel': Color(0xFFF97316), // Orange-500 - Adventure, travel
    'Other': Color(0xFF6B7280), // Gray-500 - Neutral, other
  };
}
