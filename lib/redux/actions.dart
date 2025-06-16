import '../models/word_details.dart';

class LoadWordsAction {
  final List<String> words;
  LoadWordsAction(this.words);
}

class SelectWordAction {
  final String word;
  SelectWordAction(this.word);
}

class SetWordDetailsAction {
  final WordDetails details;
  SetWordDetailsAction(this.details);
}

class AddToFavoritesAction {
  final String word;
  final String userId;
  AddToFavoritesAction(this.word, this.userId);
}

class RemoveFromFavoritesAction {
  final String word;
  final String userId;
  RemoveFromFavoritesAction(this.word, this.userId);
}

class AddToHistoryAction {
  final String word;
  final String userId;
  AddToHistoryAction(this.word, this.userId);
}

class SetCurrentUserAction {
  final String userId;
  SetCurrentUserAction(this.userId);
}

class SetFavoritesAction {
  final String userId;
  final List<String> favorites;
  SetFavoritesAction(this.userId, this.favorites);
}

class SetHistoryAction {
  final String userId;
  final List<String> history;
  SetHistoryAction(this.userId, this.history);
}