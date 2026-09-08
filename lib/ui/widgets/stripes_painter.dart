import 'package:material_ui/material_ui.dart';

class StripesPainter extends CustomPainter {
  const StripesPainter({
    required this.backgroundColor,
    required this.stripeColor,
    this.stripeWidth = 7,
    this.gap = 10,
  });

  final Color backgroundColor;
  final Color stripeColor;
  final double stripeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaint = Paint()..color = stripeColor;
    final period = stripeWidth + gap;
    final diagonal = size.width + size.height;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (double x = -diagonal; x < diagonal; x += period) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + size.height, size.height)
        ..lineTo(x + size.height + stripeWidth, size.height)
        ..lineTo(x + stripeWidth, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripesPainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        stripeColor != oldDelegate.stripeColor ||
        stripeWidth != oldDelegate.stripeWidth ||
        gap != oldDelegate.gap;
  }
}
