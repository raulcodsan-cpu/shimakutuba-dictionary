import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ScreenshotService {
  /// Captures a widget wrapped in a [RepaintBoundary] identified by [boundaryKey]
  /// and saves it as a temporary PNG file.
  static Future<File?> captureToTempFile({
    required GlobalKey boundaryKey,
    double pixelRatio = 3.0,
    String fileNamePrefix = 'screenshot',
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('RepaintBoundary not found for key: $boundaryKey');
      }

      // Convert the RenderObject to an Image with high pixel ratio
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to ByteData.');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Write to a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
      rethrow;
    }
  }
}
