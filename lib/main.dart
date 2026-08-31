import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uchinaguchi_jisho/data/services/deep_link_service.dart';
import 'package:uchinaguchi_jisho/data/services/share_service.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';
import 'package:uchinaguchi_jisho/screens/entry_screen.dart';
import 'package:uchinaguchi_jisho/screens/search_screen.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 4, 42, 73),
  ),
  textTheme: TextTheme(
    //titleLarge for EntryScreen's main word.
    titleLarge: TextStyle(
      fontSize: 40,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal,
    ),
    //titeMedium for SearchScreen's word list's words title.
    titleMedium: TextStyle(
      fontSize: 20,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal,
      overflow: TextOverflow.ellipsis,
    ),
    //labelSmall for EntryScreen adjacent word id.
    labelSmall: TextStyle(
      fontSize: 15,
      color: Colors.white54,
      overflow: TextOverflow.ellipsis,
    ),
    //labelLarge for EntryScreen main word id.
    labelLarge: TextStyle(
      fontSize: 20,
      color: const Color.fromARGB(96, 255, 255, 255),
    ),
    //headlineMedium for adjacent words link (word).
    headlineMedium: TextStyle(
      color: Colors.blue.shade200,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MyAppState();
}

class _MyAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final DeeplinkService _deeplinkService = DeeplinkService();
  final IWordLinkService _linkShareService = WordLinkService();

  @override
  void initState() {
    _initDeepLinks();
    super.initState();
  }

  void _initDeepLinks() {
    _deeplinkService.init();

    // When a link event is received, push WordScreen.
    _deeplinkService.onWordReceived.listen((WordItem wordItemEvent) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => EntryScreen(
            word: wordItemEvent,
            linkShareService: _linkShareService,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _deeplinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: theme,
      home: SearchScreen(linkShareService: _linkShareService),
    );
  }
}
