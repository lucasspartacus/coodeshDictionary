class WordDetails {
  final String word;
  final List<String> meanings;
  final List<String> examples;
  final List<String> synonyms;
  final String? origin;

  WordDetails({
    required this.word,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    this.origin,
  });

  factory WordDetails.fromJson(Map<String, dynamic> json) {
    final meanings = <String>[];
    final examples = <String>[];
    final synonyms = <String>[];

    if (json['meanings'] != null) {
      for (var meaning in json['meanings']) {
        if (meaning['definitions'] != null) {
          for (var def in meaning['definitions']) {
            if (def['definition'] != null) meanings.add(def['definition']);
            if (def['example'] != null) examples.add(def['example']);
            if (def['synonyms'] != null) {
              synonyms.addAll(List<String>.from(def['synonyms']));
            }
          }
        }
      }
    }

    return WordDetails(
      word: json['word'],
      meanings: meanings,
      examples: examples,
      synonyms: synonyms,
      origin: json['origin'],
    );
  }
}
