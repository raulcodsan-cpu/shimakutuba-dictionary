import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uchinaguchi_jisho/data/fav_provider.dart';
import 'package:uchinaguchi_jisho/data/new_db_provider.dart';
import 'package:uchinaguchi_jisho/data/services/share_service.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';
import 'package:uchinaguchi_jisho/screens/share_screen.dart';
import 'package:uchinaguchi_jisho/widgets/entry_widget.dart';
import 'package:uchinaguchi_jisho/widgets/icons/saved_icon.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.word});
  final WordItem word;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EntryScreen();
  }
}

class _EntryScreen extends ConsumerState<EntryScreen> {
  late final PageController _pageController;
  bool _isFavourite = false;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    // Convert 1-based ID to 0-based page index
    _currentPageIndex = widget.word.id - 1;
    _pageController = PageController(initialPage: _currentPageIndex);
    _checkFavourite(widget.word);
  }

  Future<void> _checkFavourite(WordItem word) async {
    final favourite = await ref
        .read(favouritesProvider.notifier)
        .isFavourite(word);
    if (mounted) {
      setState(() {
        _isFavourite = favourite;
      });
    }
  }

  // -------------------------------------------- Trash?
  void _goToPage(int id) {
    _pageController.jumpToPage(id - 1);
  }
  //---------------------------------------------------

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    // Resolve current word from provider cache and update favourite status ----------- ??
    final currentWordId = index + 1;
    final asyncWords = ref.read(wordFromIdProvider(currentWordId));

    asyncWords.whenData((words) {
      final activeWord = words.firstWhere(
        (w) => w.id == currentWordId,
        orElse: () => words.isNotEmpty ? words.first : widget.word,
      );
      _checkFavourite(activeWord);
    });
  }

  void _toggleFavourite(WordItem currentWord) async {
    final favNotifier = ref.read(favouritesProvider.notifier);
    if (_isFavourite) {
      await favNotifier.removeFavWord(currentWord);
      if (mounted) setState(() => _isFavourite = false);
    } else {
      await favNotifier.addFavouriteWord(currentWord);
      if (mounted) setState(() => _isFavourite = true);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavourite ? '言葉を保存しました' : '言葉を保存リストから削除しました'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentWordId = _currentPageIndex + 1;
    // Reactively watch current word state to get the active WordItem for AppBar actions
    final currentWordAsync = ref.watch(wordFromIdProvider(currentWordId));
    //-----------------------------------------------------------------------------------------Check code
    final activeWord =
        currentWordAsync.value?.firstWhere(
          (element) => element.id == currentWordId,
          orElse: () => widget.word,
        ) ??
        widget.word;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _toggleFavourite(activeWord),
            icon: SavedIcon(currentWord: activeWord, isFavourite: _isFavourite),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InstagramShareScreen(
                    shareService: SystemShareService(),
                    word: widget.word,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, globalIndex) {
          final pageWordId = globalIndex + 1;
          return Consumer(
            builder: (context, ref, child) {
              final wordAsync = ref.watch(wordFromIdProvider(pageWordId));

              return wordAsync.when(
                data: (words) {
                  if (words.isEmpty) {
                    return const Center(child: Text('No word found'));
                  }
                  return EntryWidget(words: words, goToPage: _goToPage);
                },
                error: (error, stackTrace) =>
                    Center(child: Text('Error loading word: $error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
    );
  }
}
