import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word_details.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../services/firebase_service.dart';

class WordDetailScreen extends StatefulWidget {
  final WordDetails details;

  const WordDetailScreen({super.key, required this.details});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  bool _historyAdded = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_historyAdded) {
        await _addToHistory(context, widget.details.word);
        _historyAdded = true;
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakWord(String word) async {
    await flutterTts.speak(word);
  }

  Future<void> _addToHistory(BuildContext context, String word) async {
    final store = StoreProvider.of<AppState>(context);
    final userId = store.state.currentUserId;

    if (userId.isEmpty) return;

    try {
      await FirebaseService.addToHistory(word);
      store.dispatch(AddToHistoryAction(word, userId));
    } catch (e) {
      print('Erro ao adicionar ao histórico: $e');
    }
  }

  Future<void> _toggleFavorite(BuildContext context, String word, bool isFavorite) async {
    final store = StoreProvider.of<AppState>(context);
    final userId = store.state.currentUserId;

    if (userId.isEmpty) return;

    if (isFavorite) {
      store.dispatch(RemoveFromFavoritesAction(word, userId));

      try {
        await FirebaseService.removeFavorite(word);
      } catch (e) {
        print('Erro ao remover dos favoritos no Firebase: $e');
      }
    } else {
      store.dispatch(AddToFavoritesAction(word, userId));

      try {
        await FirebaseService.addFavorite(word);
      } catch (e) {
        print('Erro ao adicionar aos favoritos no Firebase: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<String>>(
      converter: (store) {
        final userId = store.state.currentUserId;
        if (userId.isEmpty) return [];
        return store.state.favoritesByUser[userId] ?? [];
      },
      builder: (context, favorites) {
        final isFavorite = favorites.contains(widget.details.word);

        //Icone para ouvir a palavra usadn flutter tts e icone de favorito
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.details.word),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                tooltip: 'Ouvir',
                onPressed: () => _speakWord(widget.details.word),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => _toggleFavorite(context, widget.details.word, isFavorite),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  widget.details.word,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                if (widget.details.origin != null) ...[
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: const Text("Origem"),
                      subtitle: Text(widget.details.origin!),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                if (widget.details.meanings.isNotEmpty) ...[
                  const Text(
                    "Significados",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ...widget.details.meanings
                      .map((m) => ListTile(title: Text("- $m"))),
                ],

                if (widget.details.examples.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Exemplos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ...widget.details.examples.map(
                    (e) => ListTile(
                      leading: const Icon(Icons.circle, size: 8),
                      title: Text(e),
                    ),
                  ),
                ],

                if (widget.details.synonyms.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Sinônimos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      widget.details.synonyms.join(', '),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
