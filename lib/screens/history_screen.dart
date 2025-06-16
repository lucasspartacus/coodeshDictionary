import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import '../services/dictionary_api.dart';
import '../services/firebase_service.dart';
import 'word_detail_screen.dart';
import 'dart:developer' as developer;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreen();
}

class _HistoryScreen extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {

    final store = StoreProvider.of<AppState>(context, listen: false);
    final userId = store.state.currentUserId;

    if (userId.isEmpty) return;

    try {
      final history = await FirebaseService.getHistory();
      if (!mounted) return; 
      store.dispatch(SetHistoryAction(userId, history));
    } catch (e) {
      developer.log('Erro ao buscar histórico', error: e, name: 'HistoryScreen');
    }
  }

  void _openWord(String word) async {
    final details = await DictionaryApi.fetchWordDetails(word);
    if (!mounted) return;
    if (details != null) {
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
      onInit: (store) async {
        await _fetchHistory(); 
      },
      converter: (store) {
        final userId = store.state.currentUserId;
        return store.state.historyByUser[userId] ?? [];
      },
      builder: (context, history) {
        return Scaffold(
          appBar: AppBar(title: const Text("Histórico de Palavras")),
          body: history.isEmpty
              ? const Center(child: Text("Nenhuma palavra no histórico."))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final word = history[index];
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

