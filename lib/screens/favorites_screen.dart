import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../services/dictionary_api.dart';
import 'word_detail_screen.dart';
import '../services/firebase_service.dart';
import '../redux/actions.dart';
import 'dart:developer' as developer;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFavorites(); 
  }

  Future<void> _fetchFavorites() async {
    final store = StoreProvider.of<AppState>(context);
    final userId = store.state.currentUserId;

    if (userId.isEmpty) return;

    try {
      final favorites = await FirebaseService.getFavorites();
      if (!mounted) return;
      store.dispatch(SetFavoritesAction(userId, favorites));
    } catch (e) {
      developer.log('Erro ao buscar favoritos', error: e, name: 'FavoritesScreen');
    }
  }

  void _openWord(String word) async {
    final details = await DictionaryApi.fetchWordDetails(word);
    if (details != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordDetailScreen(details: details),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<String>>(
      converter: (store) {
        final userId = store.state.currentUserId;
        return store.state.favoritesByUser[userId] ?? [];
      },
      builder: (context, favorites) {
        return Scaffold(
          appBar: AppBar(title: const Text("Palavras Favoritas")),
          body: favorites.isEmpty
              ? const Center(child: Text("Nenhuma palavra favoritada ainda."))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final word = favorites[index];
                    return ListTile(
                      title: Text(word),
                      onTap: () => _openWord(word),
                    );
                  },
                ),
        );
      },
    );
  }
}

