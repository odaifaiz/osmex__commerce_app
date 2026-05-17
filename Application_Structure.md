# 📁 Application Structure

## 🔖 Project Overview

**Application Name:** Samana Bakery  
**Type:** E-commerce Mobile Application (Flutter)  
**Architecture Pattern:** Feature-based with Service Layer

---

## 🗂️ Full Folder Tree

```
samana_bakery/
├── lib/
│   ├── main.dart                          # App entry point & initialization
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # Design tokens (spacing, radius, animations)
│   │   │
│   │   └── theme/
│   │       └── app_theme.dart             # Material 3 theme, colors, typography
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── product_model.dart         # Product entity
│   │   │   ├── category_model.dart        # Category entity
│   │   │   └── cart_item_model.dart       # Cart item entity
│   │   │
│   │   └── repositories/
│   │       └── sample_data.dart           # Demo data source
│   │
│   ├── providers/
│   │   ├── cart_provider.dart             # Cart state management
│   │   └── favorites_provider.dart        # Favorites state management
│   │
│   ├── screens/                           # Feature screens
│   │   ├── home/
│   │   │   └── home_screen.dart           # Main home with tabs
│   │   │
│   │   ├── cart/
│   │   │   └── cart_screen.dart           # Shopping cart
│   │   │
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart      # Saved products
│   │   │
│   │   ├── product_detail/
│   │   │   └── product_detail_screen.dart # Product details & add to cart
│   │   │
│   │   └── order_success/
│   │       └── order_success_screen.dart  # Order confirmation
│   │
│   └── widgets/                           # Reusable UI components
│       ├── product_card.dart              # Product grid item
│       ├── category_item.dart             # Category chip
│       ├── custom_button.dart             # Themed button
│       ├── floating_bottom_nav_bar.dart   # Navigation bar
│       ├── hero_banner.dart               # Featured product banner
│       └── quantity_selector.dart         # +/- quantity control
│
├── assets/                                # Static assets
├── test/                                  # Unit/widget tests
├── pubspec.yaml                           # Dependencies
└── android/, ios/, web/, linux/           # Platform-specific code
```

---

## 🏗️ Layer Classification

### ┌─────────────────────────────────────┐
│  PRESENTATION LAYER                    │
├─────────────────────────────────────┤
│  `lib/screens/`                       │
│  `lib/widgets/`                      │
└─────────────────────────────────────┘
          │
          ▼
### ┌─────────────────────────────────────┐
│  BUSINESS LOGIC LAYER (State)         │
├─────────────────────────────────────┤
│  `lib/providers/`                    │
│  - CartProvider                      │
│  - FavoritesProvider                │
└─────────────────────────────────────┘
          │
          ▼
### ┌─────────────────────────────────────┐
│  DATA LAYER                           │
├─────────────────────────────────────┤
│  `lib/data/models/`                  │
│  `lib/data/repositories/`            │
│  - ProductModel                     │
│  - CategoryModel                    │
│  - CartItemModel                    │
│  - SampleData (demo data)           │
└─────────────────────────────────────┘
          │
          ▼
### ┌─────────────────────────────────────┐
│  CORE / SHARED                        │
├─────────────────────────────────────┤
│  `lib/core/`                         │
│  - Theme configuration              │
│  - Design constants                 │
│  - Main entry point (main.dart)     │
└─────────────────────────────────────┘

---

## 🎯 Architecture Pattern: Feature-Based MVVM with Provider

This application follows a **feature-based architecture** with clear separation of concerns:

| Aspect | Implementation |
|--------|----------------|
| **State Management** | Provider (ChangeNotifier pattern) |
| **Data Flow** | Unidirectional (Model → Provider → UI) |
| **Navigation** | Navigator 1.0 with PageRouteBuilder |
| **Theming** | Material 3 with custom design tokens |
| **Data Source** | Static sample data (no API) |

### Why This Architecture?

1. **Provider Pattern**: Chosen for simplicity and efficiency in Flutter
2. **Static Data**: No backend - uses hardcoded `SampleData` for demo
3. **Feature Folders**: Each screen is isolated in its own folder
4. **Widget Reusability**: Common components extracted to `/widgets`

---

## 📦 Purpose of Key Directories

| Directory | Role |
|-----------|------|
| `core/` | Design system, theme constants, app-level configs |
| `data/models/` | Domain entities (Product, Category, CartItem) |
| `data/repositories/` | Data access layer (currently static sample data) |
| `providers/` | Global app state (cart, favorites) |
| `screens/` | Screen-level widgets with full page logic |
| `widgets/` | Atomic and composite reusable UI components |

---

## 🔗 Key File Dependencies

```
main.dart
    ├── AppTheme (theme/app_theme.dart)
    ├── CartProvider (providers/cart_provider.dart)
    ├── FavoritesProvider (providers/favorites_provider.dart)
    └── HomeScreen (screens/home/home_screen.dart)
            ├── FloatingBottomNavBar (widgets/)
            ├── _HomeTab → ProductCard (widgets/)
            ├── _CategoriesTab → CategoryItem (widgets/)
            ├── CartScreen
            └── FavoritesScreen
                    └── ProductDetailScreen
```

---

## 🏷️ Design Tokens Summary (from app_constants.dart)

| Token Type | Values |
|------------|--------|
| **Spacing** | XS=4, SM=8, MD=16, LG=24, XL=32 |
| **Border Radius** | SM=10, MD=16, LG=20, XL=28, XXL=36, Full=100 |
| **Animation** | Fast=150ms, Medium=300ms, Slow=500ms |

---

## ⚠️ Architectural Observations

### Strengths
- Clean separation between UI and business logic
- Consistent design token usage
- Reusable widget composition
- Clear data flow pattern

### Areas for Improvement
- No formal repository abstraction (data is hardcoded)
- No API service layer (would be needed for production)
- Navigation could benefit from GoRouter for complex routing
- No dependency injection framework
- Missing error boundaries and loading states