import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _obscurePassword = true;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);

    if (_isLogin) {
      controller.signIn(_emailController.text.trim(), _passwordController.text);
    } else {
      controller.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: UserRole.customer,
        businessName: _businessNameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Listen for Auth Error state to show alert
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF070B19)]
                : [const Color(0xFFEFF6FF), AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Jyoti Traders',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                    Text(
                      _isLogin
                          ? l10n.authSubtitleLogin
                          : l10n.authSubtitleSignup,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 450.ms),
                    const SizedBox(height: 32),

                    // Card Form Container (Glassmorphic vibe)
                    Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.3 : 0.05,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : AppColors.primary.withOpacity(0.05),
                            ),
                          ),
                          child: AnimatedSize(
                            duration: 300.ms,
                            curve: Curves.easeInOut,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Sign Up Specific Fields
                                if (!_isLogin) ...[
                                  // Name Field
                                  _buildTextField(
                                    controller: _nameController,
                                    label: l10n.authFullName,
                                    icon: Icons.person_outline,
                                    helperText: l10n.authFullNameHelper,
                                    validator: Validators.name,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z' -]"),
                                      ),
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone Field
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: l10n.authPhoneNumber,
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    helperText: l10n.authPhoneHelper,
                                    validator: Validators.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Business Name
                                  _buildTextField(
                                    controller: _businessNameController,
                                    label: l10n.authBusinessName,
                                    icon: Icons.store_outlined,
                                    helperText: l10n.authBusinessNameHelper,
                                    validator: Validators.businessName,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[A-Za-z0-9 &.-]'),
                                      ),
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Email Field
                                _buildTextField(
                                  controller: _emailController,
                                  label: l10n.authEmailAddress,
                                  icon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                    LengthLimitingTextInputFormatter(254),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: l10n.authPassword,
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                    helperText: _isLogin
                                        ? null
                                        : l10n.authPasswordHelperSignup,
                                    helperMaxLines: 2,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.primary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                      tooltip: _obscurePassword
                                          ? l10n.authShowPassword
                                          : l10n.authHidePassword,
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black12,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.black12,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (_isLogin) {
                                      return (val == null || val.isEmpty)
                                          ? l10n.authEnterPasswordError
                                          : null;
                                    }
                                    return Validators.password(val);
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                ElevatedButton(
                                  onPressed: authState is AuthLoading
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: authState is AuthLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          _isLogin
                                              ? l10n.authSignIn
                                              : l10n.authCreateAccount,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .slideY(
                          begin: 0.1,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        )
                        .fadeIn(),

                    const SizedBox(height: 24),

                    // Toggle mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? l10n.authNoAccount : l10n.authHasAccount,
                          style: GoogleFonts.inter(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState?.reset();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            _isLogin ? l10n.authSignUp : l10n.authSignIn,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),

                    if (_isLogin) ...[
                      const SizedBox(height: 20),
                      // Helper text for quick demoing
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.authDemoLoginLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = true;
                                        _emailController.text =
                                            'admin@jyoti.com';
                                        _passwordController.text = 'admin123';
                                      });
                                      _submit();
                                    },
                                    icon: const Icon(
                                      Icons.admin_panel_settings,
                                      size: 16,
                                    ),
                                    label: Text(
                                      l10n.authAdminDemo,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = true;
                                        _emailController.text =
                                            'retailer@jyoti.com';
                                        _passwordController.text =
                                            'retailer123';
                                      });
                                      _submit();
                                    },
                                    icon: const Icon(Icons.store, size: 16),
                                    label: Text(
                                      l10n.authRetailerDemo,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        helperText: helperText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
