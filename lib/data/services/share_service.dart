import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';

abstract class IShareInstaService {
  Future<ShareResult> shareImageWithText({
    required File imageFile,
    required String text,
    String? subject,
  });
}

class SystemShareService implements IShareInstaService {
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

abstract class IWordLinkService {
  Future<void> shareWord(WordItem item, {Rect? sharePositionOrigin});
}

class WordLinkService implements IWordLinkService {
  @override
  // The Rect argument is req. for IOS for screen anchor point
  Future<void> shareWord(WordItem item, {Rect? sharePositionOrigin}) async {
    final Uri link = item.toDeepLink();

    final String message =
        '新しい言葉を覚えました！:\n\n'
        '📖 ${item.kana}(${item.word})\n'
        '意味: ${item.meanings.join(", ")}\n\n'
        'タップしてアプリ内で確認: $link';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'シェアした言葉${item.kana}',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
