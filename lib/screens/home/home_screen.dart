import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_card.dart';
import '../../widgets/floating_bottom_nav_bar.dart';
import '../../widgets/hero_banner.dart';
import '../product_detail/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeTab(),
      const _CategoriesTab(),
      const CartScreen(),
      const FavoritesScreen(),
      const _ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Tab
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProduct(ProductModel product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => ProductDetailScreen(product: product),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildTopBar()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const SizedBox.shrink();
                if (provider.bestSellers.isEmpty) return const SizedBox.shrink();
                return HeroBanner(
                  featuredProduct: provider.bestSellers.first,
                  onOrderNow: () => _navigateToProduct(provider.bestSellers.first),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: _buildCategoriesSection()),
          SliverToBoxAdapter(child: _buildSectionHeader('Best Sellers', 'See all')),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const ProductGridShimmer(count: 6);
              }
              if (provider.error != null) {
                return SliverToBoxAdapter(child: _buildError(provider.error!));
              }
              return _buildProductGrid(provider.bestSellers);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 28),
          Text(
            'Osmex',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.primaryDark,
              height: 1,
            ),
          ),
          const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for pastries, bread...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, i) => CategoryItem(
                  category: categories[i],
                  isSelected: _selectedCategoryIndex == i,
                  onTap: () => setState(() => _selectedCategoryIndex = i),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(action,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.bakery_dining_outlined,
                  size: 60,
                  color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              const Text('No products yet',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75, // Adjusted to match mockup better
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => ProductCard(
            product: products[i],
            onTap: () => _navigateToProduct(products[i]),
          ),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProductProvider>().loadData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Categories Tab
// ─────────────────────────────────────────────────────────────────────────────
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  int _selectedCategoryIndex = 0;

  List<ProductModel> get _filteredProducts {
    final provider = context.read<ProductProvider>();
    final categories = provider.categories;
    if (categories.isEmpty) return [];
    final categoryId = categories[_selectedCategoryIndex].id;
    return provider.products.where((p) => p.categoryId == categoryId).toList();
  }

  void _navigateToProduct(ProductModel product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => ProductDetailScreen(product: product),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredProducts.length} items',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              final categories = provider.categories;
              return SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => CategoryItem(
                    category: categories[i],
                    isSelected: _selectedCategoryIndex == i,
                    onTap: () => setState(() => _selectedCategoryIndex = i),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bakery_dining_outlined,
                            size: 60,
                            color: AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('No items in this category',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, i) => ProductCard(
                      product: _filteredProducts[i],
                      onTap: () => _navigateToProduct(_filteredProducts[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _ProfileInfoCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
            ),
            const SizedBox(height: 12),
            _ProfileInfoCard(
              icon: Icons.person_outline_rounded,
              label: 'Display Name',
              value: name,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Consumer<AuthProvider>(
                builder: (_, auth, _) => OutlinedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () => auth.signOut(),
                  icon: auth.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.error),
                        )
                      : const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(
                    auth.isLoading ? 'Signing out...' : 'Sign Out',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
