import 'package:flutter/material.dart';

class ApiConstants {
  // Base URL untuk JSON Server
  // Untuk Android Emulator gunakan 10.0.2.2
  // Untuk iOS Simulator gunakan localhost
  // Untuk Physical Device gunakan IP Address komputer Anda
  // Untuk Web gunakan localhost
  static const String baseUrl = 'https://unconfected-respectful-velvet.ngrok-free.dev/php_api';
  
  // Endpoints
  static const String users = '/users';
  static const String hotels = '/hotels';
  static const String bookings = '/bookings';
  static const String favorites = '/favorites';
  static const String reviews = '/reviews';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}

class AppColors {
  // Island Paradise Primary Colors - Ocean Teal
  static const primaryColor = Color(0xFF00ACC1);
  static const primaryDark = Color(0xFF0097A7);
  static const primaryLight = Color(0xFF26C6DA);
  
  // Island Paradise Secondary Colors - Sunset Orange
  static const secondaryColor = Color(0xFFFF6F00);
  static const secondaryDark = Color(0xFFE65100);
  static const secondaryLight = Color(0xFFFF8F00);
  
  // Island Paradise Accent Colors - Coral Pink
  static const accentColor = Color(0xFFFF6E40);
  static const accentDark = Color(0xFFFF5252);
  static const accentLight = Color(0xFFFF9E80);
  
  // Island Paradise Success - Palm Green
  static const success = Color(0xFF43A047);
  static const successLight = Color(0xFF66BB6A);
  
  // Status Colors
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF29B6F6);
  
  // Neutral Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const grey = Color(0xFF9E9E9E);
  static const greyLight = Color(0xFFE0E0E0);
  static const greyDark = Color(0xFF616161);
  
  // Background Colors - Paradise White
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFF8F0);
  
  // Text Colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);
  static const textOnPrimary = Color(0xFFFFFFFF);
  
  // Gradient Colors
  static const List<Color> oceanGradient = [
    Color(0xFF00ACC1), // Teal
    Color(0xFF0288D1), // Blue
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFFF6F00), // Orange
    Color(0xFFFF6E40), // Coral
  ];
  
  static const List<Color> paradiseGradient = [
    Color(0xFF00ACC1), // Teal
    Color(0xFF43A047), // Green
    Color(0xFFFF6F00), // Orange
  ];
  
  static const List<Color> twilightGradient = [
    Color(0xFF5E35B1), // Purple
    Color(0xFFFF6E40), // Coral
  ];
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double circular = 999.0;
}

class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
}

class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}
