import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_input_field.dart';
import '../../../core/widgets/app_snack_bar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    if (!success && auth.errorMessage != null) {
      AppSnackBar.show(context, auth.errorMessage!, type: SnackBarType.error);
    }
    // On success, authStateChanges in main.dart auto-navigates to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.07),
                            // ── Hero Logo ──────────────────────────────────────
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bakery_dining_rounded,
                                  color: AppColors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            // ── Heading ────────────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: const [
                                  Text(
                                    'Welcome back',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Sign in to continue shopping',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.045),
                            // ── Form ───────────────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AuthInputField(
                                    label: 'Email address',
                                    hint: 'you@example.com',
                                    prefixIcon: Icons.email_outlined,
                                    controller: _emailCtrl,
                                    focusNode: _emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(_passwordFocus),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  AuthInputField(
                                    label: 'Password',
                                    hint: '••••••••',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    controller: _passwordCtrl,
                                    focusNode: _passwordFocus,
                                    isPassword: true,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: _submit,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Password is required';
                                      if (v.length < 6) return 'At least 6 characters';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // ── Sign-in button ─────────────────────────────────
                            Consumer<AuthProvider>(
                              builder: (_, auth, _) => SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: AppColors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // ── Register link ──────────────────────────────────
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, a, _) => const RegisterScreen(),
                                    transitionsBuilder: (_, a, _, child) =>
                                        FadeTransition(opacity: a, child: child),
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Create one',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
