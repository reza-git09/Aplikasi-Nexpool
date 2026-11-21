import 'dart:math' as math;

import 'package:flutter/material.dart';

class TicketReceiptTearClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const toothStep = 5.0;
    const toothDepth = 8.0;
    final path = Path()..moveTo(0, toothDepth);

    for (var x = toothStep; x < size.width; x += toothStep) {
      final y = (x / toothStep).round().isOdd ? 0.0 : toothDepth;
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, toothDepth)
      ..lineTo(size.width, size.height - toothDepth);

    for (var x = size.width - toothStep; x > 0; x -= toothStep) {
      final y = (x / toothStep).round().isOdd
          ? size.height
          : size.height - toothDepth;
      path.lineTo(x, y);
    }

    path
      ..lineTo(0, size.height - toothDepth)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketReceiptTearClipper oldClipper) => false;
}

class TicketReceiptDashedLinePainter extends CustomPainter {
  const TicketReceiptDashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;

    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + 4, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TicketReceiptDashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
