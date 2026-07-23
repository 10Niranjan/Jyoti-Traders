import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';

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
  
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin@jyoti.com';
    _passwordController.text = 'admin123';
  }

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
      controller.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      controller.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        businessName: _selectedRole == UserRole.admin 
            ? 'Jyoti Kirana Administration' 
            : _businessNameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      'Jyoti Kirana',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                    Text(
                      _isLogin
                          ? 'Wholesale & Retail Market Hub'
                          : 'Create Retailer or Admin Account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 450.ms),
                    const SizedBox(height: 32),

                    // Card Form Container (Glassmorphic vibe)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                              // Role Selection Selector
                              Text(
                                'Select Account Role',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRoleButton(
                                      title: 'Retailer / Customer',
                                      role: UserRole.customer,
                                      isSelected: _selectedRole == UserRole.customer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildRoleButton(
                                      title: 'Admin / Owner',
                                      role: UserRole.admin,
                                      isSelected: _selectedRole == UserRole.admin,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Name Field
                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: 16),

                              // Phone Field
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter phone number';
                                  if (val.trim().length < 10) return 'Enter a valid 10-digit number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Business Name (only if customer/retailer)
                              if (_selectedRole == UserRole.customer) ...[
                                _buildTextField(
                                  controller: _businessNameController,
                                  label: 'Business / Shop Name',
                                  icon: Icons.store_outlined,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your shop name' : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter email';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
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
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Enter password';
                                if (val.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton(
                              onPressed: authState is AuthLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Create Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad).fadeIn(),

                    const SizedBox(height: 24),

                    // Toggle mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: GoogleFonts.inter(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                            _isLogin ? 'Sign Up' : 'Sign In',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
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
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Simulation Demo Quick Login:',
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
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = true;
                                        _emailController.text = 'admin@jyoti.com';
                                        _passwordController.text = 'admin123';
                                      });
                                      _submit();
                                    },
                                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                                    label: const Text('Admin Demo', style: TextStyle(fontSize: 11)),
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = true;
                                        _emailController.text = 'retailer@jyoti.com';
                                        _passwordController.text = 'retailer123';
                                      });
                                      _submit();
                                    },
                                    icon: const Icon(Icons.store, size: 16),
                                    label: const Text('Retailer Demo', style: TextStyle(fontSize: 11)),
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildRoleButton({
    required String title,
    required UserRole role,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1) 
              : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
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
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
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
