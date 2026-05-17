# 🧩 Components Analysis

## Overview

The Samana Bakery app is composed of **5 screens** and **6 reusable widget components**. This document analyzes each component's responsibility, inputs, outputs, and interactions.

---

## 📱 SCREENS

### 1. HomeScreen (`lib/screens/home/home_screen.dart`)

**Responsibility:** Main navigation hub and home page with three tab sections (Home, Categories, Profile)

| Aspect | Details |
|--------|---------|
| **Type** | StatefulWidget with IndexedStack for tab persistence |
| **Navigation Source** | Entry point from `main.dart` |
| **Outputs** | Renders 3 child tabs via navigation index |

**Inputs:**
- `SampleData.categories` - Category list
- `SampleData.bestSellers` - Featured products
- `SampleData.products` - All products

**Child Components:**
- `FloatingBottomNavBar` - Navigation control
- `HeroBanner` - Featured product showcase
- `CategoryItem` - Category selection chips
- `ProductCard` - Product grid items

**State:**
- `_navIndex`: Current tab index (0=Home, 1=Categories, 2=Cart, 3=Favorites, 4=Profile)
- `_selectedCategoryIndex`: Selected category in filter (HomeTab, CategoriesTab)
- `_scrollController`: Scroll position for CustomScrollView
- `_searchController`: Search text input

**User Flow:**
```
User opens app → HomeScreen displays HomeTab
  ├── Taps hero "Order Now" → ProductDetailScreen
  ├── Taps category → filters products
  ├── Taps product card → ProductDetailScreen
  ├── Taps bottom nav Cart → CartScreen
  └── Taps bottom nav Favorites → FavoritesScreen
```

---

### 2. CartScreen (`lib/screens/cart/cart_screen.dart`)

**Responsibility:** Display cart items, adjust quantities, calculate totals, and checkout

| Aspect | Details |
|--------|---------|
| **Type** | StatelessWidget with Consumer for reactive updates |
| **Data Source** | `CartProvider` |
| **Outputs** | Cart item list, subtotal, delivery fee, total |

**Inputs:**
- `CartProvider.cartList` - List of CartItemModel
- `CartProvider.subtotal` - Double
- `CartProvider.deliveryFee` - Double (1.50 if subtotal > 0)
- `CartProvider.total` - Double

**Child Components:**
- `_CartItemCard` - Individual cart item (inline)
- `CustomButton` - Checkout button

**State:**
- `cart.cartList` - Reactive via Consumer

**User Flow:**
```
User navigates to Cart
  ├── Sees empty state if cart is empty
  ├── Adjusts quantity (+/- buttons)
  ├── Removes item (X button)
  ├── Clears cart ("Edit" → clearCart())
  └── Taps "Checkout"
        → OrderSuccessScreen (cart cleared)
```

---

### 3. FavoritesScreen (`lib/screens/favorites/favorites_screen.dart`)

**Responsibility:** Display favorited products, allow quick add-to-cart

| Aspect | Details |
|--------|---------|
| **Type** | StatelessWidget with Consumer |
| **Data Source** | `FavoritesProvider` + static `SampleData` |

**Inputs:**
- `FavoritesProvider.favoriteIds` - Set<String>
- `SampleData.products` - All products (for filtering)

**Outputs:**
- Filtered list of favorited products

**Child Components:**
- `_FavoriteCard` - Favorite item row (inline)
- `CachedNetworkImage` - Product images

**State:**
- `favorites.favoriteProducts(SampleData.products)` - Derived list

**User Flow:**
```
User navigates to Favorites
  ├── Sees empty state if no favorites
  ├── Taps item → ProductDetailScreen
  ├── Taps heart → removes from favorites
  └── Taps cart icon → adds to cart
```

---

### 4. ProductDetailScreen (`lib/screens/product_detail/product_detail_screen.dart`)

**Responsibility:** Show full product details, quantity selection, add to cart

| Aspect | Details |
|--------|---------|
| **Type** | StatefulWidget with animations |
| **Inputs** | `ProductModel` (passed via constructor) |
| **Outputs** | Add to cart action, quantity state |

**State:**
- `_quantity` - Selected quantity (int, default 1)
- `_addToCartController` - Button scale animation
- `_totalPrice` - Computed: `product.price * _quantity`

**Child Components:**
- `QuantitySelector` - +/- controls
- `CustomButton` - Add to cart button
- `Hero` - Image transition
- `CachedNetworkImage` - Product image

**User Flow:**
```
User taps product → ProductDetailScreen
  ├── Views image, name, price, description
  ├── Selects quantity
  ├── Views total price (reactive)
  ├── Taps favorite (toggle)
  └── Taps "Add to Cart"
        → Shows SnackBar confirmation
        → Updates CartProvider
```

---

### 5. OrderSuccessScreen (`lib/screens/order_success/order_success_screen.dart`)

**Responsibility:** Display order confirmation with animation

| Aspect | Details |
|--------|---------|
| **Type** | StatefulWidget with staggered animations |
| **Inputs** | `CartProvider` (clears cart on back) |
| **Outputs** | Navigation back to home |

**State:**
- `_controller` - Animation controller (800ms)
- `_scaleAnim`, `_fadeAnim`, `_slideAnim` - Animation curves

**Child Components:**
- `CustomButton` - "Track Order" and "Back to Home"

**User Flow:**
```
User completes checkout → OrderSuccessScreen
  ├── Views success animation (0-480ms: scale)
  ├── Views content fade-in (320-800ms: fade)
  ├── Views order number (#SMB#####)
  ├── Taps "Track Order" → (no-op, placeholder)
  └── Taps "Back to Home"
        → Cart cleared
        → Navigator.popUntil(isFirst)
```

---

## 🧱 WIDGETS

### 1. ProductCard (`lib/widgets/product_card.dart`)

**Responsibility:** Grid item for product display with quick-add and favorite toggle

| Property | Details |
|----------|---------|
| **Type** | StatefulWidget (animations) |
| **Required Inputs** | `product: ProductModel` |
| **Optional Inputs** | `onTap: VoidCallback` |

**Outputs:**
- Tap → Navigation callback
- Add button → CartProvider.addItem()
- Heart button → FavoritesProvider.toggle()

**Animations:**
- `_tapController`: Scale down on tap (120ms)
- `_bounceController`: Bounce on add-to-cart (400ms)
- `_heartController`: Pulse on favorite toggle (350ms)

---

### 2. CategoryItem (`lib/widgets/category_item.dart`)

**Responsibility:** Circle icon chip for category filtering

| Property | Details |
|----------|---------|
| **Type** | StatefulWidget |
| **Required Inputs** | `category: CategoryModel` |
| **Optional Inputs** | `isSelected: bool`, `onTap: VoidCallback` |

**Animation:**
- Scale tap animation (120ms)
- Background color transition (200ms)

---

### 3. CustomButton (`lib/widgets/custom_button.dart`)

**Responsibility:** Themed button with gradient, outlined variant, and animations

| Property | Details |
|----------|---------|
| **Type** | StatefulWidget |
| **Required Inputs** | `label: String` |
| **Optional Inputs** | `onPressed`, `leading`, `trailing`, `isFullWidth`, `isOutlined`, `height`, `fontSize` |

**Variants:**
- **Default**: Gradient background (primary), white text
- **Outlined**: Transparent with primary border

---

### 4. FloatingBottomNavBar (`lib/widgets/floating_bottom_nav_bar.dart`)

**Responsibility:** Custom floating navigation bar with badges

| Property | Details |
|----------|---------|
| **Type** | StatefulWidget (animation controllers) |
| **Required Inputs** | `currentIndex: int`, `onTap: ValueChanged<int>` |

**Badge Logic:**
- Cart index (2): Shows `cart.totalItemsCount`
- Favorites index (3): Shows `favorites.count`
- Displays "9+" for count > 9

---

### 5. HeroBanner (`lib/widgets/hero_banner.dart`)

**Responsibility:** Promotional banner showcasing featured product

| Property | Details |
|----------|---------|
| **Type** | StatelessWidget |
| **Required Inputs** | `featuredProduct: ProductModel` |
| **Optional Inputs** | `onOrderNow: VoidCallback` |

**Features:**
- Gradient background (bannerGradient)
- Decorative circles (positioned absolutely)
- Custom clip radius (asymmetric corners)
- "Order Now" button

---

### 6. QuantitySelector (`lib/widgets/quantity_selector.dart`)

**Responsibility:** +/- quantity control with disabled states

| Property | Details |
|----------|---------|
| **Type** | StatelessWidget |
| **Required Inputs** | `quantity: int`, `onIncrement: VoidCallback`, `onDecrement: VoidCallback` |
| **Optional Inputs** | `minValue: int` (default 1), `maxValue: int` (default 99) |

---

## 🗂️ Data Models

### ProductModel

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique identifier |
| `name` | String | Product name |
| `description` | String | Full description |
| `price` | double | Current price |
| `oldPrice` | double | Original price (for discount display) |
| `imageUrl` | String | Network image URL |
| `categoryId` | String | Link to CategoryModel |
| `tags` | List<String> | Feature tags |
| `isBestSeller` | bool | Featured flag |
| `discountPercent` | int | Discount percentage (0 if no discount) |

**Computed Properties:**
- `discountAmount` = `oldPrice - price`
- `hasDiscount` = `discountPercent > 0`

### CategoryModel

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique identifier |
| `name` | String | Display name |
| `icon` | IconData | Material icon |
| `itemCount` | int | Products in category |

### CartItemModel

| Field | Type | Description |
|-------|------|-------------|
| `product` | ProductModel | Product reference |
| `quantity` | int | Quantity (mutable) |

**Computed:**
- `totalPrice` = `product.price * quantity`

---

## 🔄 Component Interaction Diagram

```
                    ┌──────────────────────┐
                    │      HomeScreen      │
                    │  (Navigation Hub)    │
                    └──────────┬───────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
    ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
    │  HomeTab     │   │CategoriesTab │   │_ProfileTab   │
    │ (Grid view)  │   │ (Filtered)   │   │  (Placeholder)│
    └──────┬───────┘   └──────┬───────┘   └──────────────┘
           │                  │
           ▼                  ▼
    ┌──────────────┐   ┌──────────────┐
    │ ProductCard  │   │ ProductCard  │
    │ (per item)   │   │ (per item)   │
    └──────┬───────┘   └──────┬───────┘
           │                  │
           └────────┬─────────┘
                    ▼
           ┌────────────────┐
           │ProductDetail   │
           │    Screen      │
           └────────┬───────┘
                    │
           ┌────────┴────────┐
           │                 │
           ▼                 ▼
    ┌─────────────┐   ┌─────────────┐
    │CartProvider │   │Favorites    │
    │             │   │ Provider    │
    └──────┬──────┘   └──────┬──────┘
           │                 │
           ▼                 ▼
    ┌─────────────┐   ┌─────────────┐
    │ CartScreen  │   │Favorites    │
    │             │   │ Screen      │
    └─────────────┘   └─────────────┘
```

---

## 🎯 Code Smells & Observations

| Component | Issue | Severity |
|-----------|-------|----------|
| HomeScreen | `_HomeTab`, `_CategoriesTab`, `_ProfileTab` are private classes - hard to test in isolation | Low |
| CartScreen | Uses `dynamic` type for cartItem in `_CartItemCard` | Medium |
| ProductCard | 3 animation controllers - could be simplified | Low |
| SampleData | Hardcoded data should be behind repository interface | Medium |
| OrderSuccessScreen | "Track Order" button does nothing | Low |