import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fade + slide-up entrance for one grid/list item, staggered by [index].
///
/// Delay is capped after [maxStaggeredIndex] items so a long grid doesn't
/// make a later item wait a full second to appear — everything past that
/// index enters together instead of queuing further. Give the item itself a
/// stable `key` (e.g. `ValueKey(product.id)`) in its `itemBuilder` so the
/// entrance only plays once per element, not on every list rebuild.
class StaggeredEntrance extends StatelessWidget {
  final int index;
  final Widget child;
  final int maxStaggeredIndex;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.maxStaggeredIndex = 8,
  });

  @override
  Widget build(BuildContext context) {
    final cappedIndex = index > maxStaggeredIndex ? maxStaggeredIndex : index;
    return child
        .animate(delay: Duration(milliseconds: 30 + cappedIndex * 40))
        .fadeIn(duration: const Duration(milliseconds: 260), curve: Curves.easeOut)
        .slideY(begin: 0.12, end: 0, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
  }
}
