import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uchinaguchi_jisho/data/services/screenshot_service.dart';
import 'package:uchinaguchi_jisho/data/services/share_service.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';
import 'package:uchinaguchi_jisho/widgets/icons/share_content_card.dart';

class InstagramShareScreen extends StatefulWidget {
  final IShareInstaService shareService;
  final WordItem word;

  const InstagramShareScreen({
    super.key,
    required this.shareService,
    required this.word,
  });

  @override
  State<InstagramShareScreen> createState() => _InstagramShareScreenState();
}

class _InstagramShareScreenState extends State<InstagramShareScreen> {
  final GlobalKey _previewContainerKey = GlobalKey();
  bool _isProcessing = false;

  Future<void> _handleCaptureAndShare() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Capture the widget inside RepaintBoundary to a temp PNG file
      final File? imageFile = await ScreenshotService.captureToTempFile(
        boundaryKey: _previewContainerKey,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      if (imageFile == null || !mounted) return;

      // 2. Share image file and text
      const String exampleCaption = '🚀 うちなーぐちで新しい言葉をまなびました！';

      await widget.shareService.shareImageWithText(
        imageFile: imageFile,
        text: exampleCaption,
        subject: 'アプリ：沖縄語辞典',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ソーシャルメディア投稿',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  // Wrap the target area in RepaintBoundary
                  child: RepaintBoundary(
                    key: _previewContainerKey,
                    child: ShareableContentCard(word: widget.word),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _handleCaptureAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1306C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    _isProcessing ? 'ロード中...' : 'シェア',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
