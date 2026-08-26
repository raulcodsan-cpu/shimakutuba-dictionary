import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

abstract class IShareService {
  Future<ShareResult> shareImageWithText({
    required File imageFile,
    required String text,
    String? subject,
  });
}

class SystemShareService implements IShareService {
  @override
  Future<ShareResult> shareImageWithText({
    required File imageFile,
    required String text,
    String? subject,
  }) async {
    try {
      final xFile = XFile(imageFile.path, mimeType: 'image/png');
      return await SharePlus.instance.share(
        ShareParams(files: [xFile], text: text, subject: subject ?? '見てください！'),
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
      rethrow;
    }
  }
}
