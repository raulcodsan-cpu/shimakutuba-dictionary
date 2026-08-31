import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uchinaguchi_jisho/data/new_db_provider.dart';
import 'package:uchinaguchi_jisho/data/services/deep_link_service.dart';
import 'package:uchinaguchi_jisho/data/services/share_service.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';
import 'package:uchinaguchi_jisho/screens/favourites_screen.dart';
import 'package:uchinaguchi_jisho/screens/entry_screen.dart';
import 'package:uchinaguchi_jisho/widgets/search_entry.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.linkShareService});
  final IWordLinkService linkShareService;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  Timer? _inputTimer;
  final bool _isLoading = false;

  //Forms OnChange passes the value to the function even if its only the Func. pointer.
  void _onInputChange(String newQuery) {
    //Check if the timer is active, if is cancel because a new input has been made
    //When using null check operator ??, you can conditionally access the variable with ? (as opposed to !)
    if (_inputTimer?.isActive ?? false) {
      _inputTimer!.cancel();
    }

    _inputTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = newQuery.trim();
      });
    });
  }

  //Timer disposal if null
  @override
  void dispose() {
    _inputTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Reactively watch the search query. If empty, return an empty list immediately.
    final searchResultsAsync = _searchQuery.isEmpty
        ? const AsyncValue<List<WordItem>>.data([])
        : ref.watch(searchWordsProvider(_searchQuery));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '沖縄語辞典',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 30),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 0),
              child: Center(
                child: Text(
                  'メニュー',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontSize: 25),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark_outlined),
              title: Text('保存リスト'),
              onTap: () {
                //----------------------- TODO: Take note of pop b4 push -------------------------
                Navigator.pop(context);
                Navigator.of(context).push(
                  DialogRoute(
                    context: context,
                    builder: (context) => FavouritesScreen(
                      linkShareService: widget.linkShareService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fillColor: Colors.white60,
                  filled: true,
                  focusColor: Colors.white,
                ),
                onChanged: _onInputChange,
                //The changed value is being passed to the function.
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: searchResultsAsync.when(
                data: (words) {
                  return ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];

                      return SearchEntry(
                        word: word,
                        onTap: () {
                          //ref.read(selectedWordProvider.notifier).select(word);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EntryScreen(
                                word: word,
                                linkShareService: widget.linkShareService,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Error on fetch: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
