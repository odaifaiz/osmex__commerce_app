# 🧠 Code Explanation

This document provides a detailed explanation of every file in the Samana Bakery application.

---

## 📁 lib/main.dart

### Purpose
Application entry point - initializes Flutter, configures system UI, sets up providers, and launches the app.

### Key Functions

#### `main()`
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(...);
  SystemChrome.setPreferredOrientations([...]);
  runApp(MultiProvider(...));
}
```
- **What**: Initializes app with system UI config (transparent status bar, portrait only)
- **When**: App launch
- **Why**: Creates immersive bakery app experience with consistent orientation

#### `SamanaBakeryApp` (Widget)
```dart
class SamanaBakeryApp extends StatelessWidget {
  // Returns MaterialApp with theme and home screen
}
```
- **What**: Root widget wrapping entire app
- **Input**: No direct input, uses context for theme
- **Output**: MaterialApp with providers
- **Notable**: `MediaQuery` wrapper clamps text scaling (0.85-1.15) for accessibility

**Code Quality Issues:**
- No error boundary for crash handling
- No app-level initialization error handling

---

## 📁 lib/core/constants/app_constants.dart

### Purpose
Centralized design tokens for spacing, border radius, shadows, and animation durations.

### All Constants

| Constant | Value | Usage |
|----------|-------|-------|
| `paddingXS` | 4.0 | Minimal spacing |
| `paddingSM` | 8.0 | Tight spacing |
| `paddingMD` | 16.0 | Standard spacing |
| `paddingLG` | 24.0 | Section spacing |
| `paddingXL` | 32.0 | Large gaps |
| `radiusSM` | 10.0 | Small elements |
| `radiusMD` | 16.0 | Cards |
| `radiusLG` | 20.0 | Large cards |
| `radiusXL` | 28.0 | Modals |
| `radiusFull` | 100.0 | Pills |
| `shadowBlur` | 20.0 | Elevation |
| `animationFast` | 150ms | Quick feedback |
| `animationMedium` | 300ms | Standard transitions |
| `animationSlow` | 500ms | Elaborate animations |

---

## 📁 lib/core/theme/app_theme.dart

### Purpose
Complete Material 3 theme configuration with custom colors, typography, and component styling.

### Classes

#### `AppColors`
Static color constants and gradient definitions:
- **Primary palette**: Warm orange-brown bakery theme
- **Gradients**: primaryGradient, bannerGradient, cardGradient

#### `AppTheme`
```dart
static ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(...),
    // ... extensive theme config
  );
}
```

**Components configured:**
- `scaffoldBackgroundColor`: AppColors.background
- `textTheme`: Playfair Display + Poppins fonts
- `cardTheme`: 20px radius, no elevation, cream color
- `appBarTheme`: Transparent, Playfair title
- `bottomNavigationBarTheme`: Fixed type, no labels in this implementation
- `inputDecorationTheme`: Search bar styling
- `elevatedButtonTheme`: Gradient button defaults
- `chipTheme`: Category chip styling

**Code Quality Issues:**
- Hardcoded strings for fonts (should use constants)
- No dark theme (comment: "could be added")

---

## 📁 lib/data/models/

### product_model.dart

```dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final String categoryId;
  final List<String> tags;
  final bool isBestSeller;
  final int discountPercent;
}
```

**Computed Properties:**
- `discountAmount` → oldPrice - price
- `hasDiscount` → discountPercent > 0

**Methods:**
- `operator ==`: Based on id equality
- `hashCode`: Based on id hash

**Issues:**
- No fromJson/toJson (no API layer)
- No immutability with Equatable
- Getters could be @computed for performance

---

### category_model.dart

```dart
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final int itemCount;
}
```

**Notes:**
- Uses Material IconData - limits to Flutter's built-in icons
- Could use String iconName + IconData.fromName for flexibility

---

### cart_item_model.dart

```dart
class CartItemModel {
  final ProductModel product;
  int quantity; // Mutable
}
```

**Computed:**
- `totalPrice` = product.price * quantity

**Methods:**
- `copyWith({int? quantity})` - Immutable update pattern

**Issues:**
- `quantity` is mutable (not final) - breaks immutability
- Should use `quantity` in copyWith or make it a full immutable record

---

## 📁 lib/data/repositories/sample_data.dart

### Purpose
Static demo data provider - no actual repository pattern implementation.

### Functions

#### `get categories`
Returns 6 CategoryModel objects:
- Bread, Pastries, Donuts, Cakes, Coffee, Cookies

#### `get products`
Returns 8 ProductModel objects with full details:
- id: '1' through '8'
- Mix of bestsellers (some true, some false)
- Various discount percentages (10-15%)

#### `get bestSellers`
```dart
static List<ProductModel> get bestSellers =>
    products.where((p) => p.isBestSeller).toList();
```
- Filters products where isBestSeller == true

**Code Quality Issues:**
- No abstraction (Repository interface)
- Direct static access (hard to test, swap data source)
- No data validation on models

---

## 📁 lib/providers/

### cart_provider.dart

```dart
class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
}
```

**Getters:**
| Getter | Returns | Description |
|--------|---------|-------------|
| `items` | Map | Unmodifiable view |
| `cartList` | List | Values of map as list |
| `totalItemsCount` | int | Sum of all quantities |
| `subtotal` | double | Sum of item totals |
| `deliveryFee` | double | 1.50 if subtotal > 0 |
| `total` | double | subtotal + deliveryFee |

**Methods:**
| Method | Behavior |
|--------|----------|
| `addItem(product)` | Increments or adds new |
| `removeItem(product)` | Decrements or removes |
| `removeItemCompletely(id)` | Full removal |
| `clearCart()` | Empty map |
| `setQuantity(product, qty)` | Direct set with auto-remove if qty <= 0 |

**State Flow:**
1. User calls addItem/removeItem
2. Mutates `_items` map
3. Calls `notifyListeners()`
4. All Consumer<CartProvider> widgets rebuild

**Code Quality Issues:**
- Using Map with product.id as key (string-based) - efficient
- Public getters return unmodifiable (good)
- Missing: persist to local storage, no undo functionality

---

### favorites_provider.dart

```dart
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
}
```

**Getters:**
| Getter | Returns |
|--------|---------|
| `favoriteIds` | Set<String> (unmodifiable) |
| `count` | int (favorites length) |

**Methods:**
| Method | Behavior |
|--------|----------|
| `toggle(product)` | Add if not present, remove if present |
| `remove(productId)` | Direct removal |
| `clear()` | Empty set |

**Helper:**
```dart
List<ProductModel> favoriteProducts(List<ProductModel> allProducts) =>
    allProducts.where((p) => _favoriteIds.contains(p.id)).toList();
```

**Code Quality Issues:**
- Missing `favoriteProducts` memoization - filters every call
- No persistence (shared_preferences would be easy addition)

---

## 📁 lib/screens/home/home_screen.dart

**Purpose:** Main navigation hub using IndexedStack for tab persistence

### Classes

#### `HomeScreen`
- `_navIndex` (int): Current tab index
- `_pages` (List<Widget>): Pre-built tab bodies

**Architecture:** Uses `IndexedStack` to keep all tabs in memory - state preserved when switching

---

#### `_HomeTab` (StatefulWidget)
**State:**
- `_selectedCategoryIndex`: Category filter state
- `_scrollController`: CustomScrollView control
- `_searchController`: Search input (unused)

**Build Method Structure:**
```
SafeArea
  └─ CustomScrollView (slivers)
      ├─ SliverToBoxAdapter: _buildTopBar
      ├─ SliverToBoxAdapter: _buildSearchBar
      ├─ SliverToBoxAdapter: HeroBanner
      ├─ SliverToBoxAdapter: _buildCategoriesSection
      ├─ SliverToBoxAdapter: Section Header
      ├─ SliverGrid: Product grid (best sellers)
      └─ SliverToBoxAdapter: Bottom padding
```

**Code Issues:**
- Search bar controller exists but no filtering logic
- Category filtering doesn't affect displayed products

---

#### `_CategoriesTab` (StatefulWidget)
- Similar to HomeTab but filters by category
- Uses `_filteredProducts` getter based on selected category

**Bug:** _filteredProducts filters but grid still shows best sellers (code issue in implementation)

---

#### `_ProfileTab` (StatelessWidget)
- Simple placeholder with avatar icon and "Coming soon..."
- No functionality

---

## 📁 lib/screens/cart/cart_screen.dart

### Classes

#### `CartScreen` (StatelessWidget)
Uses `Consumer<CartProvider>` for reactive rebuilds

**Empty State:**
- Shows when `cart.cartList.isEmpty`
- "Browse Menu" button calls `Navigator.pop(context)`

**Filled State:**
```
Column
 ├─ _buildHeader (title + Edit button)
 ├─ Expanded: ListView of CartItemCards
 └─ _buildOrderSummary (totals + Checkout button)
```

**Order Summary:**
```
Column
 ├─ Row: Subtotal
 ├─ Row: Delivery Fee ($1.50 if subtotal > 0)
 ├─ Divider
 ├─ Row: Total (bold, primary color)
 └─ CustomButton: Checkout
    └─ OnPressed → OrderSuccessScreen
```

---

#### `_CartItemCard` (Inline StatelessWidget)
**Props:** `cartItem`, `cart` (CartProvider)

**Widget Structure:**
```
Row
 ├─ CachedNetworkImage (72x72)
 ├─ Expanded: Column
 │    ├─ Product name (13px, bold)
 │    ├─ Price
 │    ├─ Quantity controls (+/-)
 │    └─ (spacer)
 └─ Column: Remove button + line total
```

**Quantity Buttons:**
- Minus: removes item (decrements or removes from cart)
- Plus: adds item

**Code Issues:**
- Uses `dynamic` type for `cartItem` - should be `CartItemModel`

---

## 📁 lib/screens/favorites/favorites_screen.dart

### Classes

#### `FavoritesScreen` (StatelessWidget)
- Uses `Consumer<FavoritesProvider>` + `SampleData.products`
- Derived `products` = favorites.favoriteProducts(SampleData.products)

**Structure:**
```
Column
 ├─ _buildHeader
 │    ├─ "My Favorites" + item count
 │    └─ "Clear all" button
 └─ Expanded
      ├─ Empty state (if products.isEmpty)
      └─ ListView of _FavoriteCards
```

---

#### `_FavoriteCard` (StatelessWidget)
**Props:** `product: ProductModel`, `onTap: VoidCallback`

**Structure:**
```
Container (Row)
 ├─ ClipRRect (Hero, CachedNetworkImage, 110x110)
 ├─ Expanded: Padding with column
 │    ├─ Discount badge (if hasDiscount)
 │    ├─ Product name
 │    └─ Price row (current + stale if discount)
 └─ Column: Action buttons
      ├─ FavoritesProvider Consumer: Remove heart
      └─ CartProvider Consumer: Add to cart
```

---

## 📁 lib/screens/product_detail/product_detail_screen.dart

### Classes

#### `ProductDetailScreen` (StatefulWidget)
**Props:** `product: ProductModel`

**State:**
- `_quantity` (int): Selected quantity, default 1
- `_addToCartController`: Animation controller
- `_addToCartScale`: Scale animation (1.0 → 0.96)

**Lifecycle:**
- `initState`: Set up animation, sync quantity with cart
- `dispose`: Clean up controller

**Sync Logic:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  final cart = context.read<CartProvider>();
  final qty = cart.getItemQuantity(widget.product.id);
  if (qty > 0) setState(() => _quantity = qty);
});
```
- If product already in cart, use that quantity

**Body Structure:**
```
Column
 ├─ Expanded
 │    └─ SingleChildScrollView
 │         ├─ _buildHeroImage (Hero + CachedNetworkImage)
 │         └─ _buildProductInfo (name, price, desc, qty, tags)
 └─ _buildBottomBar (Add to Cart button)
```

---

#### `_buildProductInfo`
- Product name (Playfair, 26px, bold)
- Price row: current + stale (if discount)
- Description (Poppins, 14px, brown)
- Quantity selector + Total price
- Feature tags (if any)

---

#### `_buildBottomBar`
- Container with white background + shadow
- AnimatedBuilder wraps button
- Scale 1.0 → 0.96 on press (via _addToCartController)
- Shows total in trailing

**Add to Cart Flow:**
1. Controllers forward → reverse (button press animation)
2. cart.setQuantity(product, _quantity)
3. Show SnackBar: "$name added to cart!"

---

## 📁 lib/screens/order_success/order_success_screen.dart

### Animation Controller Setup
```dart
@override
void initState() {
  _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 800),
  );

  _scaleAnim = Tween(0.0 → 1.0)
    .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

  _fadeAnim = Tween(0.0 → 1.0)
    .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

  _slideAnim = Tween(30.0 → 0.0)
    .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

  _controller.forward(); // Auto-play on load
}
```

**Timeline:**
- 0-480ms: Check icon scales from 0 → 1 (elastic)
- 320-800ms: Content fades in + slides up

**Buttons:**
- "Track Order": No functionality (placeholder)
- "Back to Home": Clears cart, pops to first route

---

## 📁 lib/widgets/

### product_card.dart

**Purpose:** Grid card for product display with animations

**Animation Controllers (3 total):**
1. `_tapController` (120ms): Scale 1.0 → 0.96 on tap
2. `_bounceController` (400ms): Bounce on add-to-cart
3. `_heartController` (350ms): Heart pulse on favorite

**Structure:**
```
GestureDetector (tap)
 └─ AnimatedBuilder (scale)
      └─ Container (gradient, shadow)
           ├─ Stack: Image section
           │    ├─ CachedNetworkImage
           │    ├─ Discount badge (top-left if hasDiscount)
           │    ├─ Favorite button (top-right)
           │    └─ Quantity badge (bottom-right if in cart)
           └─ Padding: Info section
                ├─ Product name
                └─ Row: Price + Add button
```

**Add to Cart:**
- Tap button: cart.addItem(product)
- Triggers `_bounceController.forward(from: 0)`

---

### category_item.dart

**Components:**
- Circle with icon (animated background gradient)
- Category name below

**Animation:**
- Scale 1.0 → 0.92 on tap (120ms)
- Background color/shadow transition (200ms)

---

### custom_button.dart

**Props:**
- `label`: Button text
- `onPressed`: Callback
- `leading`/`trailing`: Icon widgets
- `isFullWidth`: Expand to max width
- `isOutlined`: Transparent with border
- `height`: Custom height
- `fontSize`: Text size
- `padding`: Custom padding
- `borderRadius`: Override corner radius

**Animation:** Scale 1.0 → 0.95 on press (120ms)

**Variants:**
- Default: Gradient background (primaryGradient), white text
- Outlined: Transparent bg, primary border, primary text

---

### floating_bottom_nav_bar.dart

**Props:**
- `currentIndex`: Active tab
- `onTap`: Index change callback

**State Management:**
- List of 5 AnimationControllers (one per item)
- Scale 1.0 → 1.2 on active (Curves.easeOutBack)

**Badge System:**
- Index 2 (Cart): Shows cart.totalItemsCount
- Index 3 (Favorites): Shows favorites.count
- Displays "9+" if count > 9
- Empty/none if count == 0

**Container:**
- 70px height
- 30px border radius
- Row of 5 items (60px each)
- 20px horizontal padding, 20px bottom padding

---

### hero_banner.dart

**Props:**
- `featuredProduct`: ProductModel to display
- `onOrderNow`: Callback for button

**Features:**
- Gradient background (bannerGradient)
- Decorative circles (positioned absolutely)
- Custom clipping (top-right, bottom-right corners)
- "Order Now" button

**Layout:** Row with text (flex 5) + image (flex 4)

---

### quantity_selector.dart

**Props:**
- `quantity`: Current value
- `onIncrement`: +1 callback
- `onDecrement`: -1 callback
- `minValue`: Minimum (default 1)
- `maxValue`: Maximum (default 99)

**Behavior:**
- Decrement disabled when quantity ≤ minValue
- Increment disabled when quantity ≥ maxValue
- AnimatedSwitcher for quantity number changes

---

## 📊 Summary Table

| File | Lines | Classes | Key Patterns |
|------|-------|---------|--------------|
| main.dart | 47 | 1 | MultiProvider, SystemChrome |
| app_constants.dart | 28 | 1 | Static constants |
| app_theme.dart | 160 | 2 | ThemeData, ColorScheme |
| product_model.dart | 35 | 1 | Value equality |
| category_model.dart | 9 | 1 | Immutable data |
| cart_item_model.dart | 18 | 1 | Computed properties |
| sample_data.dart | 120 | 1 | Static getters |
| cart_provider.dart | 54 | 1 | ChangeNotifier |
| favorites_provider.dart | 27 | 1 | ChangeNotifier |
| home_screen.dart | 350 | 4 | IndexedStack, CustomScrollView |
| cart_screen.dart | 250 | 2 | Consumer, ListView |
| favorites_screen.dart | 200 | 2 | Consumer, filter |
| product_detail_screen.dart | 280 | 1 | Hero, AnimationController |
| order_success_screen.dart | 150 | 1 | Staggered animation |
| product_card.dart | 220 | 1 | Multiple animations |
| category_item.dart | 80 | 1 | AnimatedContainer |
| custom_button.dart | 110 | 1 | Stateful animation |
| floating_bottom_nav_bar.dart | 180 | 1 | Multiple controllers |
| hero_banner.dart | 90 | 1 | ClipPath |
| quantity_selector.dart | 70 | 1 | Stateless, AnimatedSwitcher |

---

## 🚩 Code Smells Summary

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Unused search logic | home_screen.dart |
| **HIGH** | Category selection doesn't filter | home_screen.dart |
| **MEDIUM** | Dynamic type for cartItem | cart_screen.dart |
| **MEDIUM** | No data persistence | providers/ |
| **MEDIUM** | No repository pattern | SampleData |
| **LOW** | Multiple animation controllers | product_card.dart, floating_bottom_nav_bar.dart |
| **LOW** | Unused controllers | _HomeTabState |
| **LOW** | Placeholder profiles/screens | ProfileTab, Track Order |
| **LOW** | Inline widget definitions | _CartItemCard, _FavoriteCard |

All code is functional and well-structured for a demo/MVP application. Production would require addressing persistence, error handling, and the filtering issues.