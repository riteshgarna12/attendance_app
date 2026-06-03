// lib/widgets/attendance_meter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AttendanceMeter extends StatefulWidget {
  final double percentage;
  final double size;
  final bool showLabel;
  final String? label;

  const AttendanceMeter({
    super.key,
    required this.percentage,
    this.size = 180,
    this.showLabel = true,
    this.label,
  });

  @override
  State<AttendanceMeter> createState() => _AttendanceMeterState();
}

class _AttendanceMeterState extends State<AttendanceMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AttendanceMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
              begin: _animation.value, end: widget.percentage / 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(double pct) {
    if (pct >= 75) return AppTheme.success;
    if (pct >= 65) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final pct = _animation.value * 100;
        final color = _getColor(pct);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _MeterPainter(
              progress: _animation.value,
              color: color,
              backgroundColor: AppTheme.border,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.label ??
                          (pct >= 75
                              ? 'Safe'
                              : pct >= 65
                                  ? 'Warning'
                                  : 'Danger'),
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _MeterPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Tick marks
    final tickPaint = Paint()
      ..color = Color.fromRGBO(
          backgroundColor.red, backgroundColor.green, backgroundColor.blue, 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i <= 20; i++) {
      final angle = startAngle + (sweepAngle * i / 20);
      final isMajor = i % 5 == 0;
      final outerR = radius - strokeWidth / 2 - 4;
      final innerR = outerR - (isMajor ? 10 : 5);
      canvas.drawLine(
        center + Offset(math.cos(angle) * outerR, math.sin(angle) * outerR),
        center + Offset(math.cos(angle) * innerR, math.sin(angle) * innerR),
        tickPaint,
      );
    }

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Danger zone (0-65%)
    final dangerPaint = Paint()
      ..color = Color.fromRGBO(AppTheme.danger.red, AppTheme.danger.green, AppTheme.danger.blue, 0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 0.65,
      false,
      dangerPaint,
    );

    // Warning zone (65-75%)
    final warnPaint = Paint()
      ..color = Color.fromRGBO(AppTheme.warning.red, AppTheme.warning.green, AppTheme.warning.blue, 0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.65,
      sweepAngle * 0.10,
      false,
      warnPaint,
    );

    // Safe zone (75-100%)
    final safePaint = Paint()
      ..color = Color.fromRGBO(AppTheme.success.red, AppTheme.success.green, AppTheme.success.blue, 0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.75,
      sweepAngle * 0.25,
      false,
      safePaint,
    );

    // 75% marker
    final markerAngle = startAngle + sweepAngle * 0.75;
    final markerPaint = Paint()
      ..color = AppTheme.success
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      center + Offset(math.cos(markerAngle) * (radius - strokeWidth / 2 - 2),
          math.sin(markerAngle) * (radius - strokeWidth / 2 - 2)),
      center + Offset(math.cos(markerAngle) * (radius + strokeWidth / 2 + 2),
          math.sin(markerAngle) * (radius + strokeWidth / 2 + 2)),
      markerPaint,
    );

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle * progress,
        colors: [
          Color.fromRGBO(color.red, color.green, color.blue, 0.7),
          color,
        ],
        transform: GradientRotation(startAngle),
      );
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);

      final tipAngle = startAngle + sweepAngle * progress;
      final tipCenter = center +
          Offset(math.cos(tipAngle) * radius, math.sin(tipAngle) * radius);
      canvas.drawCircle(tipCenter, strokeWidth / 2 + 2,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(tipCenter, strokeWidth / 2,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_MeterPainter old) =>
      old.progress != progress || old.color != color;
}
