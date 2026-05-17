/// Application-wide constants for the Best Store e-commerce app.
library;

// ── Firebase Collection Names ─────────────────────────────────────────────────
class FirestoreCollections {
  static const String products = 'products';
  static const String users = 'users';
  static const String favorites = 'favorites';
}

// ── API Configuration (used only for one-time product seeding) ────────────────
class ApiConfig {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
}

// ── UI / Layout Constants ─────────────────────────────────────────────────────
class AppConstants {
  static const double radiusFull = 20.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
}

// ── Animation Durations ───────────────────────────────────────────────────────
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration snackbar = Duration(seconds: 3);
  static const Duration pageTransition = Duration(milliseconds: 350);
}

// ── Empty / Error State Sizes ─────────────────────────────────────────────────
class UIConstants {
  static const double emptyStateIconSize = 80.0;
  static const double errorStateIconSize = 64.0;
  static const double bottomNavHeight = 80.0;
  static const double bottomPadding = 110.0;
}