import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_input_field.dart';
import '../../../core/widgets/app_snack_bar.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _nameCtrl.text,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            // ── Back button ───────────────────────────────────────
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a, _) => const LoginScreen(),
                                  transitionsBuilder: (_, a, _, child) =>
                                      FadeTransition(opacity: a, child: child),
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              ),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(13),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 18, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // ── Heading ───────────────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: const [
                                  Text(
                                    'Create account',
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
                                    'Join Samana Bakery and start shopping',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            // ── Form ──────────────────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AuthInputField(
                                    label: 'Full name',
                                    hint: 'John Doe',
                                    prefixIcon: Icons.person_outline_rounded,
                                    controller: _nameCtrl,
                                    focusNode: _nameFocus,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(_emailFocus),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Full name is required';
                                      }
                                      if (v.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
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
                                    hint: 'Min. 6 characters',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    controller: _passwordCtrl,
                                    focusNode: _passwordFocus,
                                    isPassword: true,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(_confirmFocus),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Password is required';
                                      if (v.length < 6) return 'At least 6 characters required';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  AuthInputField(
                                    label: 'Confirm password',
                                    hint: 'Re-enter your password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    controller: _confirmCtrl,
                                    focusNode: _confirmFocus,
                                    isPassword: true,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: _submit,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (v != _passwordCtrl.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            // ── Register button ───────────────────────────────────
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
                                            'Create Account',
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
                            // ── Login link ────────────────────────────────────────
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, a, _) => const LoginScreen(),
                                    transitionsBuilder: (_, a, _, child) =>
                                        FadeTransition(opacity: a, child: child),
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
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
                            const SizedBox(height: 32),
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
