import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class SampleData {
  static List<CategoryModel> get categories => [
        CategoryModel(
          id: 'bread',
          name: 'Bread',
          icon: Icons.breakfast_dining,
          itemCount: 24,
        ),
        CategoryModel(
          id: 'pastries',
          name: 'Pastries',
          icon: Icons.cake_outlined,
          itemCount: 32,
        ),
        CategoryModel(
          id: 'donuts',
          name: 'Donuts',
          icon: Icons.donut_large_outlined,
          itemCount: 18,
        ),
        CategoryModel(
          id: 'cakes',
          name: 'Cakes',
          icon: Icons.cake,
          itemCount: 25,
        ),
        CategoryModel(
          id: 'coffee',
          name: 'Coffee',
          icon: Icons.local_cafe_outlined,
          itemCount: 16,
        ),
        CategoryModel(
          id: 'cookies',
          name: 'Cookies',
          icon: Icons.cookie_outlined,
          itemCount: 20,
        ),
      ];

  static List<ProductModel> get products => [
        ProductModel(
          id: '1',
          name: 'Chocolate Croissant',
          description:
              'A buttery, flaky croissant filled with rich dark chocolate. '
              'Our croissants are made fresh every morning with premium French butter, '
              'creating the perfect layered texture that melts in your mouth.',
          price: 2.50,
          oldPrice: 2.95,
          imageUrl:
              'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80',
          categoryId: 'pastries',
          tags: ['Freshly Baked', 'Premium Ingredients', 'Made with Love'],
          isBestSeller: true,
          discountPercent: 15,
        ),
        ProductModel(
          id: '2',
          name: 'Portuguese Tart',
          description:
              'Crispy, buttery pastry filled with smooth custard and a touch of '
              'caramelized sugar on top. A classic favorite! Our recipe comes from '
              'a traditional Portuguese bakery, perfected over generations.',
          price: 1.80,
          oldPrice: 2.10,
          imageUrl:
              'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600&q=80',
          categoryId: 'pastries',
          tags: ['Classic Recipe', 'Premium', 'Made with Love'],
          isBestSeller: true,
          discountPercent: 15,
        ),
        ProductModel(
          id: '3',
          name: 'Hazelnut Donut',
          description:
              'Light and fluffy donut topped with creamy hazelnut glaze and '
              'premium crushed hazelnuts. Each donut is hand-decorated for '
              'the perfect indulgent treat.',
          price: 2.20,
          oldPrice: 2.60,
          imageUrl:
              'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=80',
          categoryId: 'donuts',
          tags: ['Freshly Baked', 'Nut Glaze', 'Premium'],
          isBestSeller: true,
          discountPercent: 10,
        ),
        ProductModel(
          id: '4',
          name: 'Chocolate Cake',
          description:
              'Indulgent triple-layered chocolate cake with silky ganache frosting '
              'and chocolate shavings. Made with 70% dark Belgian chocolate for '
              'the most intense flavor experience.',
          price: 3.40,
          oldPrice: 4.00,
          imageUrl:
              'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
          categoryId: 'cakes',
          tags: ['Belgian Chocolate', 'Premium', 'Special Occasion'],
          isBestSeller: true,
          discountPercent: 15,
        ),
        ProductModel(
          id: '5',
          name: 'Sourdough Loaf',
          description:
              'Artisan sourdough bread with a crispy crust and chewy interior. '
              'Fermented for 24 hours for maximum flavor. Our signature loaf '
              'that has been our bestseller for over a decade.',
          price: 4.50,
          oldPrice: 5.00,
          imageUrl:
              'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=600&q=80',
          categoryId: 'bread',
          tags: ['Artisan', '24h Fermented', 'Made with Love'],
          isBestSeller: false,
          discountPercent: 10,
        ),
        ProductModel(
          id: '6',
          name: 'Cinnamon Roll',
          description:
              'Soft, pillowy cinnamon rolls swirled with cinnamon sugar and '
              'topped with cream cheese frosting. Served warm for the ultimate '
              'comfort experience.',
          price: 2.80,
          oldPrice: 3.20,
          imageUrl:
              'https://images.unsplash.com/photo-1605286978633-2dec93b18b2a?w=600&q=80',
          categoryId: 'pastries',
          tags: ['Freshly Baked', 'Cream Cheese Frosting', 'Warm'],
          isBestSeller: false,
          discountPercent: 12,
        ),
        ProductModel(
          id: '7',
          name: 'Blueberry Muffin',
          description:
              'Moist and fluffy muffins bursting with fresh blueberries. '
              'Made with real blueberries, pure vanilla extract, and topped '
              'with a golden sugar crust.',
          price: 1.90,
          oldPrice: 2.20,
          imageUrl:
              'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=600&q=80',
          categoryId: 'pastries',
          tags: ['Fresh Berries', 'Fluffy', 'Morning Delight'],
          isBestSeller: false,
          discountPercent: 13,
        ),
        ProductModel(
          id: '8',
          name: 'Caramel Eclair',
          description:
              'Classic French eclair filled with silky caramel cream and '
              'topped with glossy caramel glaze. A sophisticated treat '
              'for the discerning palate.',
          price: 3.10,
          oldPrice: 3.60,
          imageUrl:
              'https://images.unsplash.com/photo-1570145820259-b5b80c5c8bd6?w=600&q=80',
          categoryId: 'pastries',
          tags: ['French Classic', 'Caramel', 'Premium'],
          isBestSeller: false,
          discountPercent: 14,
        ),
      ];

  static List<ProductModel> get bestSellers =>
      products.where((p) => p.isBestSeller).toList();
}
