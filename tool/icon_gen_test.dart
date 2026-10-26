// Generates the Mirada app icon. Run once with:
//   flutter test tool/icon_gen_test.dart
// Not part of the normal test suite (lives outside test/).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void paintIcon(Canvas canvas, double s) {
  final bg = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4C5BD4), Color(0xFF8A3FD4)],
    ).createShader(Rect.fromLTWH(0, 0, s, s));
  final rr = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.22));
  canvas.drawRRect(rr, bg);

  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.045
    ..color = Colors.white;
  final phone = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(s / 2, s / 2),
      width: s * 0.4,
      height: s * 0.66,
    ),
    Radius.circular(s * 0.08),
  );
  canvas.drawRRect(phone, stroke);
  canvas.drawLine(
    Offset(s * 0.44, s * 0.24),
    Offset(s * 0.56, s * 0.24),
    Paint()
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round
      ..color = Colors.white,
  );

  final eye = Path();
  final cx = s / 2, cy = s * 0.52, ew = s * 0.13, eh = s * 0.085;
  eye.moveTo(cx - ew, cy);
  eye.quadraticBezierTo(cx, cy - eh * 1.9, cx + ew, cy);
  eye.quadraticBezierTo(cx, cy + eh * 1.9, cx - ew, cy);
  canvas.drawPath(eye, Paint()..color = Colors.white);
  canvas.drawCircle(Offset(cx, cy), s * 0.045, Paint()..color = const Color(0xFF8A3FD4));
}

Future<void> render(int size, String path) async {
  final recorder = ui.PictureRecorder();
  paintIcon(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
}

void main() {
  test('generates icon pngs', () async {
    await render(512, 'assets/icon.png');
    await render(192, 'web/icons/Icon-192.png');
    await render(512, 'web/icons/Icon-512.png');
    await render(512, 'web/icons/Icon-maskable-512.png');
    await render(192, 'web/icons/Icon-maskable-192.png');
    await render(32, 'web/favicon.png');
    await render(256, 'packaging/linux/mirada.png');
    expect(File('assets/icon.png').lengthSync(), greaterThan(1000));
  });
}
