import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFFF6090);
const Color secondaryColor = Color(0xFFFFC166);

const Color bgColor = Color(0xFFF9FAFB);
const Color cardBgColor = Color(0xFFFFFFFF);

const Color textPrimaryColor = Color(0xFF111827);
const Color textSecondaryColor = Color(0xFF6B7280);
const Color textHintColor = Color(0xFF9CA3AF);

const Color borderColor = Color(0xFFE5E7EB);
LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primaryColor, secondaryColor],
);

LinearGradient reverseGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [secondaryColor, primaryColor],
);
