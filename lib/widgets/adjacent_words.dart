import 'package:flutter/material.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';

class AdjacentWords extends StatelessWidget {
  const AdjacentWords({super.key, required this.words, required this.goToPage});
  final List<WordItem> words;
  final void Function(int) goToPage;

  @override
  Widget build(BuildContext context) {
    WordItem? previousWord;
    WordItem? nextWord;

    //--------------------------------------- Adding case for first/last words.
    if (words.length == 2) {
      if (words[0].id == 1) {
        previousWord = null;
        nextWord = words[1];
      } else {
        previousWord = words[0];
        nextWord = null;
      }
    } else {
      previousWord = words[0];
      nextWord = words[2];
    }

    final previousHasComma = (previousWord == null)
        ? false
        : previousWord.kana.contains(',');
    final nextHasComma = (nextWord == null)
        ? false
        : nextWord.kana.contains(',');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('前の単語', textAlign: TextAlign.start),
            Text(
              (previousWord == null) ? '' : '(${previousWord.id.toString()})',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        AdjacentDisplay(
          word: previousWord,
          goToPage: goToPage,
          hasComma: previousHasComma,
        ),

        Row(
          children: [
            Text('次の単語', textAlign: TextAlign.start),
            Text(
              (nextWord == null) ? '' : '(${nextWord.id.toString()})',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),

        AdjacentDisplay(
          word: nextWord,
          goToPage: goToPage,
          hasComma: nextHasComma,
        ),
      ],
    );
  }
}

class AdjacentDisplay extends StatelessWidget {
  const AdjacentDisplay({
    super.key,
    required this.word,
    required this.goToPage,
    this.hasComma = false,
  });
  final bool hasComma;
  final WordItem? word;
  final void Function(int) goToPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 30),
        if (word != null)
          TextButton(
            style: ButtonStyle(
              alignment: AlignmentGeometry.topLeft,
              padding: WidgetStatePropertyAll(EdgeInsetsGeometry.only(top: 8)),
            ),
            child: Text(
              hasComma ? word!.kana.split(',')[0] : word!.kana,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            onPressed: () => goToPage(word!.id),
          ),
      ],
    );
  }
}
