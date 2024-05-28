import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getPieChartMarkerBitmap(
    int size, int greenCount, int redCount, int totalCount) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final total = greenCount + redCount;
  final greenSweep = (greenCount / total) * 360;
  final redSweep = (redCount / total) * 360;
  final center = Offset(size / 2, size / 2);
  final radius = size / 2;

  // Increase segment thickness
  final segmentThickness = size / 5; // Making the segments thicker

  // Paint definitions for pie chart segments
  final Paint greenPaint = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke
    ..strokeWidth = segmentThickness;
  final Paint redPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = segmentThickness;

  // Paint for the white circle
  final Paint whitePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  // Draw segments
  canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -90 * (pi / 180), greenSweep * (pi / 180), false, greenPaint);
  canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      (-90 + greenSweep) * (pi / 180), redSweep * (pi / 180), false, redPaint);

  // Smaller white circle
  canvas.drawCircle(center, radius * 0.75,
      whitePaint); // Decrease the size of the white circle

  // Draw text (number) larger and bolder
  TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: '$totalCount',
      style: TextStyle(
          color: Colors.black,
          fontSize: size / 3, // Increase font size
          fontWeight: FontWeight.bold // Make the font bold
          ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2));

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  // ignore: deprecated_member_use
  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}
