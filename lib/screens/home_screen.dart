import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/dictionary_api.dart';
import 'word_detail_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> allWords = [];
  List<String> filteredWords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWords();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadWords() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/words_dictionary.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<String> wordList = jsonMap.keys.toList();

    setState(() {
      allWords = wordList;
      filteredWords = wordList;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredWords = allWords
          .where((word) => word.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onWordTap(BuildContext context, String word) async {
    final wordDetails = await DictionaryApi.fetchWordDetails(word);
    if (wordDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordDetailScreen(details: wordDetails),
        ),
      );
    }
  }
  //Log out button e dialog
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair"),
        content: const Text("Deseja realmente sair da sua conta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Sair"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Palavras em Inglês"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Sair",
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar palavra...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredWords.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhuma palavra encontrada.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : StoreConnector<AppState, List<String>>(
                        converter: (store) {
                          final userId = store.state.currentUserId;
                          return store.state.favoritesByUser[userId] ?? [];
                        },
                        builder: (context, favorites) {
                          return ListView.builder(
                            itemCount: filteredWords.length,
                            itemBuilder: (context, index) {
                              final word = filteredWords[index];
                              final isFavorite = favorites.contains(word);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      word,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isFavorite ? Icons.star : Icons.star_border,
                                          color: isFavorite ? Colors.amber : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_ios, size: 16),
                                      ],
                                    ),
                                    onTap: () => _onWordTap(context, word),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),

        ],
      ),
    );
  }
}
