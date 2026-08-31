import 'dart:convert';

class WordItem {
  WordItem({
    required this.id,
    required this.word,
    required this.ipa,
    required this.kana,
    required this.meanings,
  });
  final int id;
  final String word;
  final String ipa;
  final List<String> meanings;
  String kana;

  // Serialization to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'ipa': ipa,
    'kana': kana,
    'meanings': meanings,
  };
  factory WordItem.fromJson(Map<String, dynamic> json) => WordItem(
    id: json['id'] as int,
    word: json['word'] as String,
    ipa: json['ipa'] as String,
    kana: json['kana'] as String,
    meanings: List.from(json['meanings'] as List),
  );

  //The brackets are for named param.
  Uri toDeepLink({String scheme = 'wordapp', String host = 'word'}) {
    // We call toJson method to conver object to JSON str.
    final String jsonStr = jsonEncode(toJson());

    // Enconde to Base64 (URL to avoid chars like + and /)
    final String base64Payload = base64Url.encode(utf8.encode(jsonStr));

    return Uri(
      scheme: scheme,
      host: host,
      queryParameters: {'payload': base64Payload},
    );
  }

  // Reverse whats done in the toDeepLink
  // WordItem needs ? as we will return null in some cases.
  static WordItem? fromPayload(String? base64Payload) {
    if (base64Payload == null) return null;
    try {
      // Decodes from: base64URL > rawBytes to UTF-8 > JSON str > Map
      final String jsonStr = utf8.decode(base64Url.decode(base64Payload));
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return WordItem.fromJson(map);
      //Wildcar _ catches any exception/error.
    } catch (_) {
      return null;
    }
  }

  static WordItem? fromDeepLink(Uri uri) {
    return fromPayload(uri.queryParameters['payload']);
  }
}
