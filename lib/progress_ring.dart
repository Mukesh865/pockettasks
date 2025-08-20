import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final int total;
  final int done;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.total,
    required this.done,
    this.size = 56,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
    total <= 0 ? 0.0 : (done.clamp(0, total)) / total.toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          background: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          foreground: Theme.of(context).colorScheme.secondary,
          progress: progress,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Text(
            total == 0 ? '0%' : '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white, // ensure visible on gradient
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color background;
  final Color foreground;
  final double progress;
  final double strokeWidth;

  _RingPainter({
    required this.background,
    required this.foreground,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = background
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = foreground
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius);
    // Background circle
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bgPaint);

    // Foreground arc for progress
    final sweep = (math.pi * 2) * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweep, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.background != background ||
        oldDelegate.foreground != foreground ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
