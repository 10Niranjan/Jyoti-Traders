import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/local_storage_service.dart';

/// Which one-time coachmarks the retailer has already dismissed (or seen),
/// seeded from Hive via [LocalStorageService] — persists across app
/// restarts so a hint only ever shows once per device.
class FirstRunHintsController extends StateNotifier<Set<String>> {
  final LocalStorageService _storage;

  FirstRunHintsController(this._storage)
    : super(_storage.getSeenFirstRunHints());

  Future<void> dismiss(String hintId) async {
    if (state.contains(hintId)) return;
    await _storage.markFirstRunHintSeen(hintId);
    state = {...state, hintId};
  }
}

final firstRunHintsProvider =
    StateNotifierProvider<FirstRunHintsController, Set<String>>((ref) {
      return FirstRunHintsController(ref.watch(localStorageProvider));
    });

/// Wraps [child] with a small dismissible tip bubble shown above it exactly
/// once — for a block-level feature (a rail, a bar) the app wants a
/// first-time visitor to notice. Renders bare [child] once [hintId] has been
/// dismissed (or was already seen on a previous launch).
class FirstRunHint extends ConsumerWidget {
  final String hintId;
  final String message;
  final Widget child;

  const FirstRunHint({
    super.key,
    required this.hintId,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(firstRunHintsProvider).contains(hintId);
    if (seen) return child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    ref.read(firstRunHintsProvider.notifier).dismiss(hintId),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
        child,
      ],
    );
  }
}
