import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Consistent success/error snackbar — every call site across the app
/// (checkout, category delete, delivery settings, profile) hand-rolled the
/// same `ScaffoldMessenger.showSnackBar` with slightly different
/// `SnackBarBehavior`; this is the one shared version, floating by default.
void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
