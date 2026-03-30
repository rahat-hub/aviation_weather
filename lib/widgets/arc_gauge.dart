import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ArcGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;
  final String subLabel;
  final List<Color> gradientColors;
  final Color trackColor;
  final double size;
  final bool showNeedle;

  const ArcGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.unit,
    this.subLabel = '',
    required this.gradientColors,
    this.trackColor = const Color(0xFF1E293B),
    this.size = 110,
    this.showNeedle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value,
          min: min,
          max: max,
          gradientColors: gradientColors,
          trackColor: trackColor,
          showNeedle: showNeedle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (subLabel.isNotEmpty)
              Text(
                subLabel,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final List<Color> gradientColors;
  final Color trackColor;
  final bool showNeedle;

  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.gradientColors,
    required this.trackColor,
    required this.showNeedle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.9;
    final radius = size.width * 0.43;
    const startAngle = pi;
    const sweepAngle = pi;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Gradient arc
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final shader = SweepGradient(
      colors: gradientColors,
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    final progressPaint = Paint()
      ..shader = shader
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );

    // Tick marks
    for (int i = 0; i <= 4; i++) {
      final angle = startAngle + (sweepAngle / 4) * i;
      final innerR = radius - 12;
      final outerR = radius + 2;
      final x1 = cx + innerR * cos(angle);
      final y1 = cy + innerR * sin(angle);
      final x2 = cx + outerR * cos(angle);
      final y2 = cy + outerR * sin(angle);
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = AppTheme.textMuted
          ..strokeWidth = 1.5,
      );
    }

    // Min/max labels
    const labelStyle = TextStyle(
      color: AppTheme.textMuted,
      fontSize: 9,
      fontFamily: 'JetBrainsMono',
    );

    _drawText(canvas, min.toInt().toString(), Offset(cx - radius - 4, cy - 8),
        labelStyle);
    _drawText(canvas, max.toInt().toString(), Offset(cx + radius - 8, cy - 8),
        labelStyle);

    // Needle
    if (showNeedle) {
      final needleAngle = startAngle + sweepAngle * progress;
      final nx = cx + (radius - 10) * cos(needleAngle);
      final ny = cy + (radius - 10) * sin(needleAngle);

      canvas.drawCircle(
        Offset(nx, ny),
        4,
        Paint()..color = Colors.white,
      );
      canvas.drawLine(
        Offset(cx, cy),
        Offset(nx, ny),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.gradientColors != gradientColors;
}

class WindRoseWidget extends StatelessWidget {
  final double windDeg;
  final double windSpeed;
  final String direction;

  const WindRoseWidget({
    super.key,
    required this.windDeg,
    required this.windSpeed,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(90, 82),
            painter: _WindRosePainter(windDeg: windDeg),
          ),
          Positioned(
            bottom: 0,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: windSpeed.toInt().toString(),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text: ' kt',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindRosePainter extends CustomPainter {
  final double windDeg;
  _WindRosePainter({required this.windDeg});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.4;
    final r = min(size.width, size.height * 0.8) * 0.4;

    // Outer circle
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = AppTheme.accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Cross lines
    final crossPaint = Paint()
      ..color = AppTheme.textMuted.withValues(alpha: 0.4)
      ..strokeWidth = 0.8;

    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 2;
      canvas.drawLine(
        Offset(cx + (r - 4) * cos(angle), cy + (r - 4) * sin(angle)),
        Offset(cx + r * cos(angle), cy + r * sin(angle)),
        crossPaint,
      );
    }

    // N/S/E/W labels
    const dirs = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 2;
      final tx = cx + (r - 8) * cos(angle);
      final ty = cy + (r - 8) * sin(angle) - 4;
      final tp = TextPainter(
        text: TextSpan(
          text: dirs[i],
          style: const TextStyle(
            fontSize: 7,
            color: AppTheme.textMuted,
            fontFamily: 'JetBrainsMono',
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
    }

    // Wind arrow
    final arrowAngle = (windDeg - 90) * pi / 180;
    final arrowLen = r * 0.65;
    final ax = cx + arrowLen * cos(arrowAngle);
    final ay = cy + arrowLen * sin(arrowAngle);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(ax, ay),
      Paint()
        ..color = AppTheme.windCyan
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead
    const headLen = 8.0;
    const headAngle = 0.5;
    canvas.drawLine(
      Offset(ax, ay),
      Offset(
        ax - headLen * cos(arrowAngle - headAngle),
        ay - headLen * sin(arrowAngle - headAngle),
      ),
      Paint()
        ..color = AppTheme.windCyan
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(ax, ay),
      Offset(
        ax - headLen * cos(arrowAngle + headAngle),
        ay - headLen * sin(arrowAngle + headAngle),
      ),
      Paint()
        ..color = AppTheme.windCyan
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = AppTheme.windCyan);
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter old) =>
      old.windDeg != windDeg;
}
