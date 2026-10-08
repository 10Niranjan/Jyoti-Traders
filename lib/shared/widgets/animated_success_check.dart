import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// One-shot "order placed" animation: a ring draws itself, the tick strokes
/// in, then a small burst of dots radiates out. Painted rather than played
/// from a Lottie file — no animation asset exists for this app, and a
/// one-shot controller settles cleanly under widget tests (unlike a looping
/// one). Honours the OS "remove animations" setting by jumping to the end.
class AnimatedSuccessCheck extends StatefulWidget {
  final double size;

  const AnimatedSuccessCheck({super.key, this.size = 132});

  @override
  State<AnimatedSuccessCheck> createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) =>
              CustomPaint(painter: _SuccessPainter(_controller.value)),
        ),
      ),
    );
  }
}

class _SuccessPainter extends CustomPainter {
  final double t;

  const _SuccessPainter(this.t);

  /// Progress of the [from]..[to] slice of the timeline, eased and clamped.
  static double _slice(
    double t,
    double from,
    double to, [
    Curve c = Curves.easeOut,
  ]) => c.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  static const _burstColors = [
    AppColors.success,
    AppColors.primary,
    AppColors.accent,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.34;

    // Soft filled disc pops in first.
    final pop = _slice(t, 0, 0.35, Curves.easeOutBack);
    canvas.drawCircle(
      center,
      radius * pop,
      Paint()..color = AppColors.success.withOpacity(0.12),
    );

    final stroke = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.05;

    // Ring sweeps a full turn from the top.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * _slice(t, 0, 0.5),
      false,
      stroke,
    );

    // Tick strokes in once the ring is mostly drawn.
    final tick = Path()
      ..moveTo(size.width * 0.36, size.height * 0.52)
      ..lineTo(size.width * 0.46, size.height * 0.62)
      ..lineTo(size.width * 0.65, size.height * 0.40);
    final tickProgress = _slice(t, 0.45, 0.8);
    // Skipped at zero: a zero-length path with a round cap still paints a dot.
    if (tickProgress > 0) {
      final metric = tick.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * tickProgress),
        stroke,
      );
    }

    _paintBurst(canvas, center, size.width, _slice(t, 0.6, 1));
  }

  void _paintBurst(Canvas canvas, Offset center, double width, double q) {
    if (q <= 0 || q >= 1) return;
    const dots = 10;
    for (var i = 0; i < dots; i++) {
      final angle = 2 * math.pi * i / dots;
      final distance = width * (0.40 + 0.09 * q);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        width * 0.02 * (1 - q) + 1,
        Paint()
          ..color = _burstColors[i % _burstColors.length].withOpacity(1 - q),
      );
    }
  }

  @override
  bool shouldRepaint(_SuccessPainter old) => old.t != t;
}
