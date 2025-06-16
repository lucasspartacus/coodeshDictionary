import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_details.dart';

class DictionaryApi {
  static final Map<String, WordDetails> _cache = {};

  static Future<WordDetails?> fetchWordDetails(String word) async {
    if (_cache.containsKey(word)) return _cache[word];

    final url = 'https://api.dictionaryapi.dev/api/v2/entries/en/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final wordDetails = WordDetails.fromJson(data[0]);
      _cache[word] = wordDetails;
      return wordDetails; //sucesso
    } else {
      return null;
    }
  }
}
