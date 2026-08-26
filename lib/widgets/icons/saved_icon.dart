import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';

class SavedIcon extends ConsumerStatefulWidget {
  const SavedIcon({
    super.key,
    required this.currentWord,
    required this.isFavourite,
  });
  final WordItem currentWord;
  final bool isFavourite;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SavedIcon();
  }
}

class _SavedIcon extends ConsumerState<SavedIcon>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      //----------------------- TODO: take note.----------------
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
          child: child,
        );
      },
      child: Icon(
        widget.isFavourite
            ? Icons.bookmark_added_sharp
            : Icons.bookmark_outline_sharp,
        key: ValueKey(widget.isFavourite),
      ),
    );
  }
}


/* return IconButton(
      onPressed: () => _toggleFavourite(widget.currentWord),
      icon: ScaleTransition(scale: _animation, child: ,)
    ); */