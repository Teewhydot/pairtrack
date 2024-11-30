import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarker(String? url) async {
  if (url == null) {
    return BitmapDescriptor.defaultMarker;
  }
  final response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const size = Size(100, 150);

  // Draw the default marker shape
  final paint = Paint()..color = Colors.blue;
  final path = Path()
    ..moveTo(size.width / 2, size.height)
    ..lineTo(size.width, size.height * 0.6)
    ..arcToPoint(Offset(0, size.height * 0.6),
        radius: Radius.circular(size.width / 2))
    ..close();
  canvas.drawPath(path, paint);

  // Draw the circular image
  final rect = Rect.fromLTWH(0, 0, size.width, size.width);
  canvas.clipPath(Path()..addOval(rect));
  paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.cover);

  final picture = pictureRecorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = data!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(buffer);
}
