/*

This is a example of a polar plot. The plot is drawn using a CustomPainter.

In this version, the path for each data series is drawn using a Catmull-Rom spline. 

*/

import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      home: Scaffold(
          body: Center(
              child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: PolarPlot()))))));
}

class PolarPlot extends CustomPainter {
  Offset catmullRomSpline(
      double t, Offset p0, Offset p1, Offset p2, Offset p3) {
    double t2 = t * t;
    double t3 = t2 * t;

    return Offset(
      0.5 *
          ((2 * p1.dx) +
              (-p0.dx + p2.dx) * t +
              (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
              (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3),
      0.5 *
          ((2 * p1.dy) +
              (-p0.dy + p2.dy) * t +
              (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
              (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    const numCircles = 5;
    final rr =
        List.generate(numCircles + 2, (i) => i / (numCircles + 1) * 2 * radius);

    // Draw mid-circles
    for (int k = 1; k <= numCircles; k++) {
      final r = rr[k];
      canvas.drawCircle(center, r, paint);
    }

    // Draw labels
    final labels = List.generate(30, (i) => i + 1);
    final rLabel = rr.last * 1.2;
    for (var i = 0; i < labels.length; i++) {
      final radian = i / labels.length * 2 * math.pi - math.pi / 2;
      final labelOffset = Offset(center.dx + rLabel * math.cos(radian),
          center.dy + rLabel * math.sin(radian));
      TextPainter(
        text: TextSpan(
            text: labels[i].toString(),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, labelOffset);
    }

    // Draw the actual series
    final data = [
      List.generate(30, (i) => 0.2 * math.Random().nextDouble() + 1),
      List.generate(30, (i) => 0.2 * math.Random().nextDouble() + 2),
      List.generate(30, (i) => 0.2 * math.Random().nextDouble() + 3),
    ];

    final colors = [Colors.red, Colors.green, Colors.blue];
    for (var k = 0; k < data.length; k++) {
      paint.color = colors[k];
      final path = Path();
      final points = List.generate(data[k].length + 3, (i) {
        final index = (i - 1) % data[k].length;
        final radian = index / data[k].length * 2 * math.pi - math.pi / 2;
        return Offset(center.dx + data[k][index] * radius * math.cos(radian),
            center.dy + data[k][index] * radius * math.sin(radian));
      });

      for (var i = 0; i < points.length - 3; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final p2 = points[i + 2];
        final p3 = points[i + 3];

        if (i == 0) {
          path.moveTo(p1.dx, p1.dy);
        }

        for (var t = 0.0; t <= 1; t += 0.01) {
          final pointOnCurve = catmullRomSpline(t, p0, p1, p2, p3);
          path.lineTo(pointOnCurve.dx, pointOnCurve.dy);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
