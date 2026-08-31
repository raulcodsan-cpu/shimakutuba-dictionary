import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uchinaguchi_jisho/data/fav_provider.dart';
import 'package:uchinaguchi_jisho/data/services/share_service.dart';
import 'package:uchinaguchi_jisho/screens/entry_screen.dart';
import 'package:uchinaguchi_jisho/widgets/search_entry.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key, required this.linkShareService});
  final IWordLinkService linkShareService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(favouritesProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: savedAsync.when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => SearchEntry(
                word: data[index],
                onTap: () async {
                  //ref.read(selectedWordProvider.notifier).select(data[index]);
                  await Navigator.of(context).push(
                    DialogRoute(
                      context: context,
                      builder: (context) => EntryScreen(
                        word: data[index],
                        linkShareService: linkShareService,
                      ),
                    ),
                  );
                  ref.invalidate(favouritesProvider);
                },
              ),
            );
          },
          error: (error, stackTrace) =>
              Center(child: Text('Error on loading: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
