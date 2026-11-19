import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// A short-lived "X added to cart"-style confirmation, scoped to whichever
/// screen embeds it — not a [SnackBar]. This app has a single
/// `MaterialApp.router` and therefore one app-root [ScaffoldMessenger], so a
/// `SnackBar` renders above the *entire* app rather than just the screen
/// that triggered it: navigate away before its duration elapses and it
/// keeps floating over whatever screen you land on next. This widget
/// sidesteps that by living inside the host screen's own widget tree —
/// it's destroyed the instant that screen is popped, and hides itself
/// after [show]'s `duration` regardless.
///
/// Usage: keep a `GlobalKey<InlineToastState>`, place `InlineToast(key: ...)`
/// somewhere in the screen's layout, call `key.currentState?.show('message')`.
class InlineToast extends StatefulWidget {
  const InlineToast({super.key});

  @override
  State<InlineToast> createState() => InlineToastState();
}

class InlineToastState extends State<InlineToast> {
  String? _message;
  String? _actionLabel;
  VoidCallback? _onAction;
  Timer? _timer;

  void show(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    _timer?.cancel();
    setState(() {
      _message = message;
      _actionLabel = actionLabel;
      _onAction = onAction;
    });
    _timer = Timer(duration, () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _dismissAndRun(VoidCallback? action) {
    _timer?.cancel();
    setState(() => _message = null);
    action?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: _message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _message!,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
                      ),
                    ),
                    if (_actionLabel != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _dismissAndRun(_onAction),
                        child: Text(
                          _actionLabel!,
                          style: GoogleFonts.inter(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
