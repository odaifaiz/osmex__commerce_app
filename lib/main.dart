import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase initialisation ───────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── System UI styling ─────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BestStoreApp());
}

class BestStoreApp extends StatelessWidget {
  const BestStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Products — Firestore stream
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // Favorites — Firestore stream, uid set by _AuthGate
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        // Cart — local, no Firebase needed
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Osmex Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Clamp font scaling so layout stays predictable
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: child!,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Listens to Firebase auth state and routes to either [HomeScreen]
/// or [LoginScreen]. Also wires the user UID into [FavoritesProvider].
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Waiting for Firebase to determine state ─────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final user = snapshot.data;

        // ── Wire UID into FavoritesProvider ────────────────────────────────
        // Use addPostFrameCallback so we don't call notifyListeners
        // during a build cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<FavoritesProvider>().setUser(user?.uid);
        });

        if (user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

/// Simple full-screen loader shown while Firebase resolves auth state.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
            SizedBox(height: 20),
            Text(
              'Osmex Store',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
